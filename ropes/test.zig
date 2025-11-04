const std = @import("std");
const testing = std.testing;
const Rope = @import("main.zig").Rope;

test "create_rope" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str = "hello";
    const rope = try Rope.create_rope(allocator, undefined, str, 0, str.len - 1);
    defer rope.free_rope(allocator);

    try testing.expectEqual(rope.size, 5);
    // LEAF_MAX_LENGTH is 4, so it will be split.
    // mid = 2. left("hel"), right("lo")
    try testing.expectEqual(rope.weight, 3);
}

test "concat_rope" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str1 = "hello ";
    const left = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    const str2 = "world";
    const right = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    var str = try left.concat_rope(allocator, right);
    defer str.free_rope(allocator);

    try testing.expectEqual(str.size, str1.len + str2.len);
    try testing.expectEqual(str.weight, str1.len);

    var buffer: [str1.len + str2.len]u8 = undefined;
    var i: usize = 0;
    while (i < buffer.len) : (i += 1) {
        buffer[i] = str.search_rope(i, null, null);
    }

    try testing.expectEqualStrings("hello world", &buffer);
}

test "search_rope" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str1 = "hello beautiful ";
    const left = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    const str2 = "world";
    const right = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    var str = try left.concat_rope(allocator, right);
    defer str.free_rope(allocator);

    try testing.expectEqual(str.search_rope(0, null, null), 'h');
    try testing.expectEqual(str.search_rope(6, null, null), 'b');
    try testing.expectEqual(str.search_rope(16, null, null), 'w');
    try testing.expectEqual(str.search_rope(20, null, null), 'd');
}

test "split_rope_after" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str1 = "helloworld";
    var rope = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);
    defer rope.free_rope(allocator);

    _ = try rope.split_rope_after(allocator, 4);

    var buffer: [10]u8 = undefined;
    for (0..10) |i| {
        buffer[i] = rope.search_rope(i, null, null);
    }
    try testing.expectEqualStrings("helloworld", &buffer);
}

test "tree is approximately balanced" {
    @import("main.zig").SHOULD_BALANCE = true;
    defer @import("main.zig").SHOULD_BALANCE = false;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str1 = "a very long string to test balancing";
    const rope1 = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    const str2 = "short";
    const rope2 = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    var rope = try rope1.concat_rope(allocator, rope2);
    defer rope.free_rope(allocator);

    const left_size = rope.left.?.size;
    const right_size = rope.right.?.size;
    const diff = @as(isize, @intCast(left_size)) - @as(isize, @intCast(right_size));

    try testing.expect(@abs(diff) <= 10);
}
