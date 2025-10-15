const std = @import("std");

const Base64 = struct {
    _table: []const u8,

    pub fn init() Base64 {
        const high = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const low = "abcdefghijklmnopqrstuvwxyz";
        const nums = "0123456789";
        const others = "+/";
        return Base64{ ._table = high ++ low ++ nums ++ others };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }

    pub fn _index_of_char(self: Base64, char: u8) u8 {
        if (char == '=') return 64;
        var i: u8 = 0;
        for (self._table) |c| {
            if (c == char) return i;
            i += 1;
        }
        std.debug.print("INVALID CHARACTER FOUND IN DECODED STRING WHILE ENCODING: {c}", .{char});
        return '$';
    }

    pub fn _calc_encode_length(input: []const u8) !usize {
        if (input.len < 3) return 4;
        const groups_count = try std.math.divCeil(usize, input.len, 3);
        return groups_count * 4;
    }

    pub fn _calc_decode_length(input: []const u8) !usize {
        if (input.len < 4) return 3;
        // const groups_count = try std.math.divFloor(usize, input.len, 4);
        // var final_groups = groups_count;
        // var i = final_groups;
        // while (i > 0) : (i -= 1) {
        //     if (input[i] == '=') {
        //         final_groups -= 1;
        //     } else {
        //         break;
        //     }
        // }
        // return groups_count * 4;
        return (input.len / 4) * 3;
    }

    pub fn decode(self: Base64, input: []const u8, allcoator: std.mem.Allocator) ![]const u8 {
        var window: usize = 0;
        const decoded_len = try Base64._calc_decode_length(input);
        const decoded_buffer = try allcoator.alloc(u8, decoded_len);
        // std.debug.print("leeeneggtthhh: {d}\n", .{decoded_len});
        var decoded_buffer_len: usize = 0;

        while (window + 4 <= input.len) : (window += 4) {
            const inp0: u8 = self._index_of_char(input[window]);
            const inp1: u8 = self._index_of_char(input[window + 1]);
            const inp2: u8 = self._index_of_char(input[window + 2]);
            const inp3: u8 = self._index_of_char(input[window + 3]);

            const out0: u8 = (inp0 << 2) | ((inp1 & 0b00110000) >> 4);
            const out1: u8 = ((inp1 & 0b00001111) << 4) | ((inp2 & 0b00111100) >> 2);
            const out2: u8 = ((inp2 & 0b00000011) << 6) | ((inp3 & 0b00111111));

            // std.debug.print("DECODING...\n", .{});
            // std.debug.print("inp0: {b:0>8}; inp1: {b:0>8} inp2: {b:0>8} inp3: {b:0>8}\n", .{ inp0, inp1, inp2, inp3 });
            // std.debug.print("{d} : {b:0>8} {b:0>8} {b:0>8} \n\n", .{ decoded_len, out0, out1, out2 });

            decoded_buffer[decoded_buffer_len] = out0;
            decoded_buffer[decoded_buffer_len + 1] = out1;
            decoded_buffer[decoded_buffer_len + 2] = out2;

            decoded_buffer_len += 3;
        }
        return decoded_buffer;
    }

    pub fn encode(self: Base64, input: []const u8, allocator: std.mem.Allocator) ![]const u8 {
        var window: usize = 0;
        const encoded_len = try Base64._calc_encode_length(input);
        const encoded_buffer = try allocator.alloc(u8, encoded_len);
        var encoded_buffer_len: usize = 0;

        while (window + 3 <= input.len) : (window += 3) {
            const inp0 = input[window];
            const inp1 = input[window + 1];
            const inp2 = input[window + 2];

            const out0 = inp0 >> 2;
            const out1 = ((inp0 & 0b00000011) << 4) | ((inp1 & 0b11110000) >> 4);
            const out2 = ((inp1 & 0b00001111) << 2) | (inp2 >> 6);
            const out3 = (inp2 & 0b00111111);

            // std.debug.print("ENCODING...", .{});
            // std.debug.print("inp0: {b:0>8}; inp1: {b:0>8} inp2: {b:0>8}\n", .{ inp0, inp1, inp2 });
            // std.debug.print("{d} : {b:0>8} {b:0>8} {b:0>8} {b:0>8} \n\n", .{ encoded_len, (out0), (out1), (out2), (out3) });

            encoded_buffer[encoded_buffer_len] = self._char_at(out0);
            encoded_buffer[encoded_buffer_len + 1] = self._char_at(out1);
            encoded_buffer[encoded_buffer_len + 2] = self._char_at(out2);
            encoded_buffer[encoded_buffer_len + 3] = self._char_at(out3);

            encoded_buffer_len += 4;
        }

        // std.debug.print("\nWindowwww: {d}\n", .{window});

        if (window + 1 == input.len) {
            const remaining_char = input[window];
            encoded_buffer[encoded_buffer_len] = self._char_at((remaining_char) >> 2);
            encoded_buffer[encoded_buffer_len + 1] = self._char_at((remaining_char & 0b00000011) << 4);
            encoded_buffer[encoded_buffer_len + 2] = '=';
            encoded_buffer[encoded_buffer_len + 3] = '=';
        } else if (window + 2 == input.len) {
            const remaining_char0 = input[window];
            const remaining_char1 = input[window + 1];
            // std.debug.print("INPUT: {b:0>8} {b:0>8}\n", .{ remaining_char0, remaining_char1 });
            encoded_buffer[encoded_buffer_len] = self._char_at(remaining_char0 >> 2);
            encoded_buffer[encoded_buffer_len + 1] = self._char_at(((remaining_char0 & 0b00000011) << 4) | (remaining_char1 >> 4));
            encoded_buffer[encoded_buffer_len + 2] = self._char_at((remaining_char1 & 0b00001111) << 2);
            encoded_buffer[encoded_buffer_len + 3] = '=';
            // std.debug.print("OUTPUT: {b:0>8} {b:0>8} {b:0>8} {b:0>8} \n", .{ encoded_buffer[encoded_buffer_len], encoded_buffer[encoded_buffer_len + 1], encoded_buffer[encoded_buffer_len + 2], encoded_buffer[encoded_buffer_len + 3] });
        }

        return encoded_buffer;
    }
};

pub fn main() !void {
    const b = Base64.init();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    const input = "var gpa = std.heap.GeneralPurposeAllocator(.{}){};";
    const str = try b.encode(input, allocator);
    const d_str = try b.decode(str, allocator);
    defer allocator.free(str);
    std.debug.print(" raw: {s}\n encoded: {s}\n decoded: {s}\n", .{ input, str, d_str });
}
