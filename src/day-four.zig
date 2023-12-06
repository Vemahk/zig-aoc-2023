const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    const contents = try cwd.readFileAlloc(a, "inputs/day-four.txt", 1 << 20);
    defer a.free(contents);

    var card_count = CardCounter.init(a);
    defer card_count.deinit();

    var line_iter = std.mem.tokenizeAny(u8, contents, "\n\r");
    var buf = std.ArrayList(usize).init(a);
    defer buf.deinit();

    var card_num: usize = 0;
    while (line_iter.next()) |line| : (card_num += 1) {
        buf.clearRetainingCapacity();
        try card_count.add(card_num);
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
                    value += 1;
                }
            }
        }

        try card_count.win(card_num, value);
    }

    std.log.info("point sum: {d}", .{card_count.sum()});
}

const CardCounter = struct {
    cards: std.ArrayList(usize),

    pub fn init(a: std.mem.Allocator) CardCounter {
        return .{
            .cards = std.ArrayList(usize).init(a),
        };
    }

    fn ensure(self: *CardCounter, card: usize) !void {
        while (self.cards.items.len <= card) {
            try self.cards.append(0);
        }
    }

    pub fn add(self: *CardCounter, card: usize) !void {
        try self.ensure(card);
        self.cards.items[card] += 1;
    }

    pub fn win(self: *CardCounter, card: usize, num: usize) !void {
        try self.ensure(card + num);
        const c = self.cards.items[card];

        var i: usize = 0;
        while (i < num) : (i += 1) {
            self.cards.items[card + i + 1] += c;
        }
    }

    pub fn sum(self: CardCounter) usize {
        var s: usize = 0;
        for (self.cards.items) |card| {
            s += card;
        }
        return s;
    }

    pub fn deinit(self: CardCounter) void {
        self.cards.deinit();
    }
};
