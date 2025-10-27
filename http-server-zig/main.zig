const std = @import("std");
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");

var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    var server = try socket._address.listen(.{});
    var id: usize = 0;
    while (true) {
        var buffer: [1024]u8 = undefined;
        const connection = try server.accept();
        id += 1;
        for (0..buffer.len) |i| {
            buffer[i] = 0;
        }
        try Request.read_request(connection, buffer[0..buffer.len]);

        const req = Request.parse_request(buffer[0..buffer.len]);

        const now = std.time.timestamp();
        std.debug.print("[{d}] start request {d}\n", .{ now, id });
        // std.Thread.sleep(2 * std.time.ns_per_s);
        const now_end = std.time.timestamp();
        std.debug.print("[{d}] end   request {d}\n", .{ now_end, id });

        // try stdout.print("{f}\n", .{request});
        // try stdout.flush();

        if (req.method != .INVALID) {
            if (std.mem.eql(u8, req.uri, "/")) {
                try Response.send_200(connection);
            } else {
                try Response.send_404(connection);
            }
        } else {
            try Response.send_404(connection); // should be unsupported method's response
        }
        connection.stream.close();
    }
}
