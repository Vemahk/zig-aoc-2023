const std = @import("std");

const RGB = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,

    pub fn power(self: RGB) u32 {
        var pwr: u32 = 1;
        pwr *= self.r;
        pwr *= self.g;
        pwr *= self.b;
        return pwr;
    }
};

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-two.txt", 1 << 20);
    defer a.free(contents);

    var minset_power_sum: u32 = 0;

    const preamble = "Game ";
    var line_iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    while (line_iter.next()) |l| {
        if (!std.mem.startsWith(u8, l, preamble)) unreachable;
        const line = l[preamble.len..];
        var game_iter = std.mem.splitSequence(u8, line, ": ");
        const game_num = try std.fmt.parseInt(usize, game_iter.next() orelse unreachable, 10);
        _ = game_num;
        const game_contents = game_iter.next() orelse unreachable;

        var min_set = RGB{};

        var set_iter = std.mem.splitSequence(u8, game_contents, "; ");

        while (set_iter.next()) |set_str| {
            const set = try parseRGB(set_str);
            if (set.r > min_set.r) min_set.r = set.r;
            if (set.g > min_set.g) min_set.g = set.g;
            if (set.b > min_set.b) min_set.b = set.b;
        }

        minset_power_sum += min_set.power();
        // std.debug.print("Game {d}: {s}\n", .{ game_num, game_contents });
    }

    std.log.info("Min-set Power Sum: {d}", .{minset_power_sum});
}

fn parseRGB(set: []const u8) !RGB {
    var iter = std.mem.splitSequence(u8, set, ", ");

    var rgb = RGB{};

    while (iter.next()) |num_color| {
        var num_iter = std.mem.splitSequence(u8, num_color, " ");
        const num = try std.fmt.parseInt(u8, num_iter.next() orelse return error.Format, 10);
        const color = num_iter.next() orelse return error.Format;

        if (std.mem.eql(u8, color, "red")) {
            rgb.r = num;
        } else if (std.mem.eql(u8, color, "green")) {
            rgb.g = num;
        } else if (std.mem.eql(u8, color, "blue")) {
            rgb.b = num;
        } else return error.InvalidColor;
    }

    return rgb;
}
