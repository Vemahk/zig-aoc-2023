const std = @import("std");

const RGB = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
};

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-two.txt", 1 << 20);
    defer a.free(contents);

    var game_sum: usize = 0;

    const max = RGB{ .r = 12, .g = 13, .b = 14 };
    const preamble = "Game ";
    var line_iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    while (line_iter.next()) |l| {
        if (!std.mem.startsWith(u8, l, preamble)) unreachable;
        const line = l[preamble.len..];
        var game_iter = std.mem.splitSequence(u8, line, ": ");
        const game_num = try std.fmt.parseInt(usize, game_iter.next() orelse unreachable, 10);
        const game_contents = game_iter.next() orelse unreachable;

        var are_all_sets_possible = true;
        var set_iter = std.mem.splitSequence(u8, game_contents, "; ");
        while (set_iter.next()) |set_str| {
            const set = try parseRGB(set_str);
            if (!isSetPossible(set, max)) {
                are_all_sets_possible = false;
                break;
            }
        }

        if (are_all_sets_possible) {
            game_sum += game_num;
        }

        std.debug.print("Game {d}: {s}\n", .{ game_num, game_contents });
    }

    std.log.info("Game sum: {d}", .{game_sum});
}

fn isSetPossible(set: RGB, max: RGB) bool {
    return set.r <= max.r and set.g <= max.g and set.b <= max.b;
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
