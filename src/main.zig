const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-four.txt", 1 << 20);
    defer a.free(contents);

    var point_sum: usize = 0;
    var line_iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    var buf = std.ArrayList(usize).init(a);

    while (line_iter.next()) |line| {
        buf.clearRetainingCapacity();
        var card_iter = std.mem.splitSequence(u8, line, ": ");
        _ = card_iter.next() orelse unreachable;
        const card = card_iter.next() orelse unreachable;
        var num_iter = std.mem.splitScalar(u8, card, ' ');
        var state: usize = 0;
        var value: usize = 0;
        while (num_iter.next()) |num| {
            if (num.len == 0) continue;
            if (std.mem.eql(u8, num, "|")) {
                state = 1;
                continue;
            }

            const n = std.fmt.parseInt(usize, num, 10) catch continue;

            if (state == 0) {
                try buf.append(n);
            } else {
                if (std.mem.indexOf(usize, buf.items, &[_]usize{n})) |_| {
                    if (value == 0) {
                        value = 1;
                    } else {
                        value = value << 1;
                    }
                }
            }
        }

        point_sum += value;
    }

    std.log.info("point sum: {d}", .{point_sum});
}
