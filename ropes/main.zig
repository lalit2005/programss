const std = @import("std");
const print = std.debug.print;

const LEAF_MAX_LENGTH = 4;

const Rope = struct {
    parent: *Rope,
    left: ?*Rope,
    right: ?*Rope,
    length: usize, // total length of string on the left subtree
    content: []const u8,

    pub fn create_rope(allocator: std.mem.Allocator, parent: ?*Rope, str: []const u8, l: usize, r: usize) !*Rope {
        const node = try allocator.create(Rope);
        node.parent = parent orelse node;
        if (r - l + 1 <= LEAF_MAX_LENGTH) {
            node.content = str[l .. r + 1];
            node.left = null;
            node.right = null;
            node.length = r - l + 1;
        } else {
            const mid = (l + r) / 2;
            node.left = try create_rope(allocator, node, str, l, mid);
            node.right = try create_rope(allocator, node, str, mid + 1, r);
            node.length = mid - l + 1;
        }

        return node;
    }

    pub fn concat_rope(self: *Rope, allocator: std.mem.Allocator, rope: *Rope) !*Rope {
        const parent = try allocator.create(Rope);
        parent.left = self;
        parent.right = rope;
        parent.parent = parent;
        parent.length = 2 * parent.left.?.length;
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
            print("  |- {s}\n", .{self.content});
        } else {
            temp = depth_indent;
            while (temp > 0) : (temp -= 1) print("   ", .{});
            print("+- [{d:^3}]\n", .{self.length});

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

    const str1 = "hello";
    const left = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    const str2 = " world but this is an extremely unbalanced tree!!";
    const right = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    const str = try left.concat_rope(allocator, right);
    defer str.free_rope(allocator);
    str.print_rope(0);
}
