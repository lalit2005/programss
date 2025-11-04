const std = @import("std");
const print = std.debug.print;

const LEAF_MAX_LENGTH = 4;
pub var SHOULD_BALANCE: bool = false;

const node_color = enum { red, black, doubleblack, redblack };

pub const Rope = struct {
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

    fn balance_node(self: *Rope) *Rope {
        if (!SHOULD_BALANCE or self.is_leaf()) return self;

        var parent = self;
        const old_parent = parent;
        const left_size = parent.left.?.size;
        const right_size = parent.right.?.size;
        const diff = @as(isize, @intCast(left_size)) - @as(isize, @intCast(right_size));

        if (@abs(diff) > 10) {
            if (old_parent.left.?.size > old_parent.right.?.size) {
                parent = parent.left.?;
                parent.right.?.parent = old_parent;
                old_parent.left.? = parent.right.?;
                parent.right.? = old_parent;
                parent.parent = parent;

                // parent.weight does not change
                // old_parent.weight = parent.size - parent.weight;
                parent.size = old_parent.size;
                old_parent.weight = old_parent.left.?.size;
                old_parent.size = old_parent.right.?.size + old_parent.left.?.size;
            } else {
                parent = parent.right.?;
                parent.left.?.parent = old_parent;
                old_parent.right.? = parent.left.?;
                parent.left.? = old_parent;
                parent.parent = parent;

                // old_parent.weight remains same
                parent.size = old_parent.size;
                old_parent.size = old_parent.left.?.size + old_parent.right.?.size;
                parent.weight = old_parent.size;
            }
        }

        if (!parent.left.?.is_leaf()) {
            parent.left = balance_node(parent.left.?);
        }
        if (!parent.right.?.is_leaf()) {
            parent.right = balance_node(parent.right.?);
        }

        return parent;
    }

    // pub fn check_balance(self: *Rope) void {
    //
    // }

    pub fn concat_rope(self: *Rope, allocator: std.mem.Allocator, rope: *Rope) !*Rope {
        var parent = try allocator.create(Rope);
        parent.left = self;
        parent.right = rope;
        parent.parent = parent;
        parent.weight = self.size;
        parent.size = self.size + rope.size;

        const new_parent = balance_node(parent);

        return new_parent;
    }

    // puts the result leaf that contains the index in the pointer, is optional
    pub fn search_rope(self: *Rope, index: usize, leaf: ?**Rope, index_in_substr: ?*usize) u8 {
        if (index + 1 > self.size) {
            print("\nindex: {d}; len: {d}\n", .{ index, self.size });
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
            print("\nindex: {d}; len: {d}\n", .{ index, self.size });
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

    fn print_rope_recursive(self: *Rope, allocator: std.mem.Allocator, prefix: []const u8, is_tail: bool) void {
        print("{s}{s}", .{ prefix, if (is_tail) "└──" else "├──" });

        if (self.is_leaf()) {
            print("-[{d:^3}] \"{s}\"\n", .{ self.weight, self.content });
        } else {
            print("+[{d:^3},{d:^3}]\n", .{ self.weight, self.size });

            const new_prefix = std.fmt.allocPrint(allocator, "{s}{s}", .{ prefix, if (is_tail) "    " else "│   " }) catch @panic("alloc print failed");
            defer allocator.free(new_prefix);

            if (self.left) |left| {
                if (self.right) |right| {
                    left.print_rope_recursive(allocator, new_prefix, false);
                    right.print_rope_recursive(allocator, new_prefix, true);
                } else {
                    left.print_rope_recursive(allocator, new_prefix, true);
                }
            } else if (self.right) |right| {
                right.print_rope_recursive(allocator, new_prefix, true);
            }
        }
    }

    pub fn print_rope(self: *Rope, allocator: std.mem.Allocator) void {
        if (self.is_leaf()) {
            print("-[{d:^3}] \"{s}\"\n", .{ self.weight, self.content });
        } else {
            print("+[{d:^3},{d:^3}]\n", .{ self.weight, self.size });
            if (self.left) |left| {
                if (self.right) |right| {
                    left.print_rope_recursive(allocator, "", false);
                    right.print_rope_recursive(allocator, "", true);
                } else {
                    left.print_rope_recursive(allocator, "", true);
                }
            } else if (self.right) |right| {
                right.print_rope_recursive(allocator, "", true);
            }
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

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len > 1 and std.mem.eql(u8, args[1], "bal")) {
        print("\nBalancing the Tree\n", .{});
        SHOULD_BALANCE = true;
    } else {
        print("\n\n", .{});
    }

    const str1 = "hello beautiful ";
    const left = try Rope.create_rope(allocator, undefined, str1, 0, str1.len - 1);

    // const str2 = "";
    const str2 = "world";
    const right = try Rope.create_rope(allocator, undefined, str2, 0, str2.len - 1);

    var str = try left.concat_rope(allocator, right);
    defer str.free_rope(allocator);

    _ = try str.split_rope_after(allocator, 1);
    _ = try str.split_rope_after(allocator, 6);
    _ = try str.split_rope_after(allocator, 0);
    _ = try str.split_rope_after(allocator, 5);

    const s3 = ".";
    const str3 = try Rope.create_rope(allocator, undefined, s3, 0, s3.len - 1);

    str = try str.concat_rope(allocator, str3);

    str.print_rope(allocator);
    // _ = str.search_rope(4);
    for (0..str1.len + str2.len) |i| {
        const a = str.search_rope(i, null, null);
        print("{c}", .{a});
    }
}
