const std = @import("std");
const Connection = std.net.Server.Connection;
const Map = std.static_string_map.StaticStringMap;

pub const Method = enum {
    INVALID,
    GET,
    // POST,
    // OPTIONS,
    // PATCH,
    // DELETE,

    pub fn init(text: []const u8) Method {
        return MethodMap.get(text) orelse .INVALID;
    }

    pub fn is_supported_str(m: []const u8) bool {
        const method = MethodMap.get(m) orelse .INVALID;
        return (method != .INVALID);
    }
};

const MethodMap = Map(Method).initComptime(.{
    .{ "INVALID", Method.INVALID },
    .{ "GET", Method.GET },
    // .{ "POST", Method.POST },
    // .{ "OPTIONS", Method.OPTIONS },
    // .{ "PATCH", Method.PATCH },
    // .{ "DELETE", Method.DELETE },
});

pub const Request = struct {
    method: Method,
    version: []const u8,
    uri: []const u8,

    pub fn init(method: Method, version: []const u8, uri: []const u8) Request {
        return Request{ .method = method, .version = version, .uri = uri };
    }

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print(
            \\Request:
            \\method: {s}
            \\version: {s}
            \\uri: {s}
            \\
        , .{ @tagName(self.method), self.version, self.uri });
    }
};

pub fn read_request(connection: Connection, buffer: []u8) !void {
    _ = try connection.stream.read(buffer);
}

pub fn parse_request(text: []const u8) Request {
    const line_end_index = std.mem.indexOfScalar(u8, text, '\n') orelse text.len;
    var iterator = std.mem.splitScalar(u8, text[0..line_end_index], ' ');
    const method = Method.init(iterator.next().?);
    if (method == Method.INVALID) @panic("cannot process incorrect http method");
    const uri = iterator.next().?;
    const version = iterator.next().?;
    const request = Request.init(method, version, uri);
    return request;
}
