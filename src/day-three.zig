const std = @import("std");
const isDigit = std.ascii.isDigit;

const Board = std.ArrayList([]const u8);

const Dir = enum { Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft };
const Dirs = [_]Dir{ Dir.Up, Dir.UpRight, Dir.Right, Dir.DownRight, Dir.Down, Dir.DownLeft, Dir.Left, Dir.UpLeft };

const Coord = struct {
    r: usize,
    c: usize,

    pub fn eq(a: Coord, b: Coord) bool {
        return a.r == b.r and a.c == b.c;
    }

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

    pub fn gearAt(coord: Coord, board: Board) !?usize {
        const ch = coord.of(board) orelse return null;
        if (ch != '*') return null;

        var parts: [Dirs.len]Coord = undefined;
        var parts_len: usize = 0;

        var sum: usize = 1;
        for (Dirs) |dir| {
            var next_coord = coord.step(dir) orelse continue;
            const next_ch = next_coord.of(board) orelse continue;
            if (!isDigit(next_ch)) continue;

            while (next_coord.step(Dir.Left)) |tmp| {
                const tmp_ch = tmp.of(board) orelse break;
                if (!isDigit(tmp_ch)) break;
                next_coord = tmp;
            }

            if (for (parts[0..parts_len]) |part| {
                if (next_coord.eq(part))
                    break true;
            } else false) {
                continue;
            }

            const part = partAt(board, next_coord) orelse return null;
            sum *= try std.fmt.parseInt(usize, part, 10);
            parts[parts_len] = next_coord;
            parts_len += 1;
        }
        if (parts_len != 2) return null;
        return sum;
    }
};

pub fn dayThree() !void {
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
            if (ch != '*')
                continue;

            const loc = Coord{ .r = r, .c = c };
            if (try loc.gearAt(matrix)) |gear_ratio| {
                part_sum += gear_ratio;
            }
        }
    }
    std.log.info("{d}", .{part_sum});
}

fn partAt(mat: Board, loc: Coord) ?[]const u8 {
    const ch = loc.of(mat) orelse return null;
    if (!isDigit(ch))
        return null;

    var next = loc;
    while (next.step(Dir.Left)) |next_loc| {
        const next_ch = next_loc.of(mat) orelse break;
        if (!isDigit(next_ch))
            break;
        next = next_loc;
    }

    var hasNearbySymbol = symbolSurrounds(mat, loc);
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
