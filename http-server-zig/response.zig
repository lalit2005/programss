const std = @import("std");

const Connection = std.net.Server.Connection;

pub fn send_200(connection: Connection) !void {
    const response =
        \\HTTP/1.1 200 OK
        \\Content-Type: text/html
        \\Connection: Closed
        \\
        \\
        \\<html><body><h1>Hello World</h1></body></html>
    ;
    _ = try connection.stream.write(response);
}

pub fn send_404(connection: Connection) !void {
    const response =
        \\HTTP/1.1 404 Not Found
        \\Content-Type: text/html
        \\Connection: Closed
        \\
        \\
        \\<html><body><h1>Oops, it's missing</h1></body></html>
    ;
    _ = try connection.stream.write(response);
}
