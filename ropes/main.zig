const std = @import("std");
const print = std.debug.print;

const LEAF_MAX_LENGTH = 4;

const node_color = enum { red, black, doubleblack, redblack };

const Rope = struct {
    parent: *Rope,
    left: ?*Rope,
    right: ?*Rope,
    weight: usize, // total length of string on the left subtree
    size: usize,
    content: []const u8,

    // create rope from input string
    pub fn create_rope(allocator: std.mem.Allocator, parent: ?*Rope, str: []const u8, l: usize, r: usize) !*Rope {
        const node = try allocator.create(Rope);
        node.parent = parent orelse node;
        node.size = r + 1 - l;
        if (r + 1 - l <= LEAF_MAX_LENGTH) {
            node.content = str[l .. r + 1];
            node.left = null;
            node.right = null;
            node.weight = r + 1 - l;
        } else {
            const mid = (l + r) / 2;
            node.left = try create_rope(allocator, node, str, l, mid);
            node.right = try create_rope(allocator, node, str, mid + 1, r);
            node.weight = mid - l + 1;
        }

        return node;
    }

    pub fn concat_rope(self: *Rope, allocator: std.mem.Allocator, rope: *Rope) !*Rope {
        var parent = try allocator.create(Rope);
        parent.left = self;
        parent.right = rope;
        parent.parent = parent;
        parent.weight = self.size;
        parent.size = self.size + rope.size;

        const old_parent = parent;
        const left_size = parent.left.?.size;
        const right_size = parent.right.?.size;
        const diff = @as(isize, @intCast(left_size)) - @as(isize, @intCast(right_size));
        if (@abs(diff) > 10) {
            if (parent.left.?.size / 2 > parent.right.?.size) {
                parent = parent.left.?;
                parent.right.?.parent = old_parent;
                old_parent.left.? = parent.right.?;
                parent.right.? = old_parent;
                parent.parent = parent;
            } else if (parent.right.?.size / 2 > parent.left.?.size) {
                parent = parent.right.?;
                parent.left.?.parent = old_parent;
                old_parent.right.? = parent.left.?;
                parent.left.? = old_parent;
                parent.parent = parent;
            }
        }

        return parent;
    }

    // puts the result leaf that contains the index in the pointer, is optional
    pub fn search_rope(self: *Rope, index: usize, leaf: ?**Rope, index_in_substr: ?*usize) u8 {
        if (index + 1 > self.size) {
            print("index: {d}; len: {d}\n", .{ index, self.size });
            @panic("index overflow while searching rope.\n");
        }
        var node = self;
        var i = index;
        while (!node.is_leaf()) {
            if (i + 1 > node.weight) {
                i -= node.weight;
                node = node.right.?;
            } else {
                node = node.left.?;
            }
        }

        if (leaf) |l| {
            l.* = node;
        }
        if (index_in_substr) |v| {
            v.* = i;
        }

        return node.content[i % LEAF_MAX_LENGTH];
    }

    // returns the new parent that has 2 split substrings
    pub fn split_rope_after(self: *Rope, allocator: std.mem.Allocator, index: usize) !*Rope {
        if (index + 1 > self.size) {
            print("index: {d}; len: {d}\n", .{ index, self.size });
            @panic("index overflow while splitting rope.\n");
        }
        var parent: *Rope = undefined;
        var index_in_substr: usize = undefined;
        _ = search_rope(self, index, &parent, &index_in_substr);
        const new_node_1 = try create_rope(allocator, parent, parent.content, 0, index_in_substr);
        const new_node_2 = try create_rope(allocator, parent, parent.content, index_in_substr + 1, parent.weight - 1);
        parent.left = new_node_1;
        parent.right = new_node_2;
        parent.weight = new_node_1.size;
        // parent.size remains same
        return parent;
    }

    pub fn free_rope(self: *Rope, allocator: std.mem.Allocator) void {
        if (self.left) |left_node| {
            free_rope(left_node, allocator);
        }
        if (self.right) |right_node| {
            free_rope(right_node, allocator);
        }
        allocator.destroy(self);
    }

    pub fn print_rope(self: *Rope, depth_indent: usize) void {
        var temp = depth_indent;
        if (self.is_leaf()) {
            while (temp > 0) : (temp -= 1) print("   ", .{});
            print(" |-[{d:^3}] ", .{self.weight});
            print("{s}\n", .{self.content});
        } else {
            temp = depth_indent;
            while (temp > 0) : (temp -= 1) print("   ", .{});
            print("+-[{d:^3}]\n", .{self.weight});

            if (self.left) |left_node| {
                left_node.print_rope(depth_indent + 1);
            }

            if (self.right) |right_node| {
                right_node.print_rope(depth_indent + 1);
            }
            print("\n", .{});
        }
    }

    fn is_leaf(self: *Rope) bool {
        return self.left == null and self.right == null;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }

    const str1 = "abcd";
    const left = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    const str2 = "helko_this_is_a_really_huge_but_should_get_normalized_ig_in_this_";
    // const str2 = " world but this is an extremely unbalanced tree!!";
    const right = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    const str = try left.concat_rope(allocator, right);
    defer str.free_rope(allocator);

    // _ = try str.split_rope_after(allocator, 1);
    // _ = try str.split_rope_after(allocator, 6);
    // _ = try str.split_rope_after(allocator, 0);
    // _ = try str.split_rope_after(allocator, 5);

    str.print_rope(0);
    // _ = str.search_rope(4);
    // for (0..str1.len + str2.len) |i| {
    //     const a = str.search_rope(i, null, null);
    //     print("{c}", .{a});
    // }
}
