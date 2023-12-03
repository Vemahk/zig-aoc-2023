const std = @import("std");
const isDigit = std.ascii.isDigit;

const Board = std.ArrayList([]const u8);

const Dir = enum { Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft };
const Dirs = [_]Dir{ Dir.Up, Dir.UpRight, Dir.Right, Dir.DownRight, Dir.Down, Dir.DownLeft, Dir.Left, Dir.UpLeft };

const Coord = struct {
    r: usize,
    c: usize,

    pub fn step(coord: Coord, dir: Dir) ?Coord {
        var newcoord = coord;

        switch (dir) {
            .Up, .UpRight, .UpLeft => {
                if (coord.r == 0)
                    return null;
                newcoord.r -= 1;
            },
            .Down, .DownRight, .DownLeft => newcoord.r += 1,
            else => {},
        }

        switch (dir) {
            .UpLeft, .Left, .DownLeft => {
                if (coord.c == 0)
                    return null;
                newcoord.c -= 1;
            },
            .UpRight, .Right, .DownRight => newcoord.c += 1,
            else => {},
        }

        return newcoord;
    }

    pub fn of(coord: Coord, board: Board) ?u8 {
        if (coord.r >= board.items.len)
            return null;

        const row = board.items[coord.r];
        if (coord.c >= row.len)
            return null;

        return row[coord.c];
    }
};

const Part = struct {
    loc: Coord,
    len: usize,
};

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-three.txt", 1 << 20);
    defer a.free(contents);

    var matrix = Board.init(a);
    defer matrix.deinit();

    var lines = std.mem.tokenizeAny(u8, contents, "\n\r");
    while (lines.next()) |line| {
        try matrix.append(line);
    }

    var part_sum: usize = 0;
    for (matrix.items, 0..) |row, r| {
        for (row, 0..) |ch, c| {
            if (!isDigit(ch))
                continue;
            if (c > 0 and isDigit(row[c - 1]))
                continue;

            const loc = Coord{ .r = r, .c = c };
            const part = partAt(matrix, loc) orelse continue;
            const part_num = try std.fmt.parseInt(usize, part, 10);
            part_sum += part_num;
        }
    }
    std.log.info("{d}", .{part_sum});
}

fn partAt(mat: Board, loc: Coord) ?[]const u8 {
    var hasNearbySymbol = symbolSurrounds(mat, loc);

    var next = loc;
    var len: usize = 1;
    while (next.step(Dir.Right)) |next_loc| {
        if (next_loc.of(mat)) |next_ch| {
            if (!isDigit(next_ch))
                break;

            len += 1;
            next = next_loc;
            if (!hasNearbySymbol) {
                hasNearbySymbol = symbolSurrounds(mat, next_loc);
            }
        } else break;
    }

    if (!hasNearbySymbol)
        return null;

    return mat.items[loc.r][loc.c .. loc.c + len];
}

fn symbolSurrounds(mat: Board, loc: Coord) bool {
    inline for (Dirs) |dir| {
        if (loc.step(dir)) |next_loc| {
            if (next_loc.of(mat)) |next_ch| {
                if (isSymbol(next_ch))
                    return true;
            }
        }
    }
    return false;
}

fn isSymbol(ch: u8) bool {
    if (isDigit(ch))
        return false;

    if (ch == '.')
        return false;

    return true;
}
