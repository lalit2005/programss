const std = @import("std");

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

    pub fn free_rope(self: *Rope, allocator: std.mem.Allocator) void {
        if (self.left) |left_node| {
            free_rope(left_node, allocator);
        }

        if (self.right) |right_node| {
            free_rope(right_node, allocator);
        }

        allocator.destroy(self);
    }

    pub fn print_rope(self: *Rope) void {
        if (self.is_leaf()) {
            std.debug.print("{s}", .{self.content});
        } else {
            self.left.?.print_rope();
            self.right.?.print_rope();
        }
    }

    fn is_leaf(self: *Rope) bool {
        return self.left == null and self.right == null;
    }
};

pub fn main() !void {
    const a = "abcdefghij";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("memory leak detected");
        }
    }
    const r = try Rope.create_rope(allocator, undefined, a, 0, a.len - 1);
    defer r.free_rope(allocator);

    r.*.print_rope();
    std.debug.print("\n===========================\n", .{});
    std.debug.print("{d}\n", .{r.length});
}
