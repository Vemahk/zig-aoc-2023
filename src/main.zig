const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-two.txt", 1 << 20);
    defer a.free(contents);

    var line_iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    _ = line_iter;
}
