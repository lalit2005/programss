const std = @import("std");
const rl = @import("raylib");
const Rope = @import("./ropes.zig").Rope;

const SCREEN_HEIGHT = 900;
const SCREEN_WIDTH = 1600;
const SIDEBAR_WIDTH = 300;
const REGULAR_FONT = 24;

fn convert_to_ctext(allocator: std.mem.Allocator, text: []const u8) ![:0]const u8 {
    if (text.len > 0 and text[text.len - 1] == 0) {
        return text[0 .. text.len - 1 :0];
    } else {
        var buf = try allocator.allocSentinel(u8, text.len + 1, 0);
        @memcpy(buf[0..text.len], text);
        buf[text.len] = 0;
        return buf;
    }
}

fn draw_tree(allocator: std.mem.Allocator, node: *Rope, font: *const rl.Font, x: *f32, depth: f32) !void {
    if (node.is_leaf()) {
        const str = try convert_to_ctext(allocator, node.content);
        defer allocator.free(str);
        rl.drawTextEx(font.*, str, .{ .x = x.* - 10, .y = depth * 35 }, REGULAR_FONT, 0, .black);
        x.* = x.* + 75;
        return;
    }

    const circle_x = @as(i32, @intFromFloat(x.*));
    const circle_y = @as(i32, @intFromFloat(depth * 35));

    const left_child_x = @as(i32, @intFromFloat(x.*));
    const left_child_y = @as(i32, @intFromFloat((depth + 1) * 35));
    rl.drawLine(circle_x, circle_y, left_child_x, left_child_y, .black);

    try draw_tree(allocator, node.left.?, font, x, depth + 1);

    // const right_child_x = @as(i32, @intFromFloat(x.*)) + @as(i32, @intCast((node.size - node.weight))) * @as(i32, @intFromFloat(75 * 0.5));
    const right_child_x = @as(i32, @intFromFloat(x.*));
    const right_child_y = @as(i32, @intFromFloat((depth + 1) * 35));
    rl.drawLine(circle_x, circle_y, right_child_x, right_child_y, .black);

    try draw_tree(allocator, node.right.?, font, x, depth + 1);

    rl.drawCircle(circle_x, circle_y, 10, .blue);
}

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ropes visualizer");
    rl.setTargetFPS(60);

    const FONT = rl.loadFontEx("./media/JetBrainsMono-Regular.ttf", REGULAR_FONT, null) catch unreachable;
    // defer rl.unloadFont(FONT);
    defer rl.closeWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const str = "hey raylib - this is a really long string";
    // const str = "helloworld";
    var str_rope = try Rope.create_rope(allocator, null, str, 0, str.len - 1);
    defer str_rope.free_rope(allocator);

    var buffer = try allocator.alloc(u8, 1);
    buffer = try str_rope.get_string(allocator, buffer);
    defer allocator.free(buffer);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.white);
        rl.drawTextEx(FONT, "TEST STRING: ", .{ .x = 10, .y = 10 }, REGULAR_FONT, 0, .black);
        rl.drawTextEx(FONT, convert_to_ctext(allocator, buffer) catch unreachable, .{ .x = 10, .y = 35 }, REGULAR_FONT, 0, .black);
        var x: f32 = 10; // initial padding
        // var x: f32 = (SCREEN_WIDTH - @as(f32, @floatFromInt(str_rope.size)) * 35) / 2; // initial padding
        try draw_tree(allocator, str_rope, &FONT, &x, 10);
        rl.drawTextEx(FONT, "written by lalit.", .{ .x = 1400, .y = 870 }, REGULAR_FONT, 0, .red);
    }
}
