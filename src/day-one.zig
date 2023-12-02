const std = @import("std");

pub fn dayOne() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-one.txt", 1 << 20);
    defer a.free(contents);

    var sum: usize = 0;

    var iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    while (iter.next()) |token| {
        var digits = [_]u8{0} ** 2;
        var foundFirst = false;

        var i: usize = 0;
        while (i < token.len) : (i += 1) {
            if (digitAtStart(token[i..])) |digit| {
                if (!foundFirst) {
                    digits[0] = digit;
                    foundFirst = true;
                }

                digits[1] = digit;
            }
        }

        const cal = try std.fmt.parseInt(usize, &digits, 10);
        sum += cal;
    }

    std.log.info("Sum: {d}", .{sum});
}

const number_words = [_][]const u8{
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
};

fn digitAtStart(text: []const u8) ?u8 {
    if (text.len == 0) {
        return null;
    }

    const char = text[0];
    if (std.ascii.isDigit(char)) {
        return char;
    }

    inline for (number_words, 0..) |word, digit| {
        if (std.mem.startsWith(u8, text, word)) {
            return '0' + digit;
        }
    }

    return null;
}
