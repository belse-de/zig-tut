const std = @import("std");

/// Was submitted to:
///     http://www.99-bottles-of-beer.net
/// Look out for it on:
///     http://www.99-bottles-of-beer.net/z.html
pub fn main() anyerror!void {
    // If this program is run without stdout attached, exit with an error.
    const out = std.io.getStdOut().writer();

    var bottles: u8 = 99;
    var text_buffer: [16]u8 = "99 bottles".* ++ [_]u8{0} ** 6;
    var text = text_buffer[0..10];
    const text_slice = text_buffer[0..];
    while (bottles > 0) {
        // If this program encounters pipe failure when printing to stdout,
        // exit with an error.
        try out.print("{s} of beer on the wall, ", .{text});
        try out.print("{s} of beer.\n", .{text});
        try out.writeAll("Take one down and pass it around, ");

        bottles -= 1;
        _ = switch (bottles) {
            0 => try std.fmt.bufPrint(text_slice, "{s} bottles", .{"no more"}),
            1 => try std.fmt.bufPrint(text_slice, "{} bottle", .{bottles}),
            else => try std.fmt.bufPrint(text_slice, "{} bottles", .{bottles}),
        };

        try out.print("{s} of beer on the wall.\n\n", .{text});
    }

    try out.print("{s} bottles of beer on the wall, ", .{"No more"});
    try out.print("{s} bottles of beer.\n", .{"no more"});
    try out.writeAll("Go to the store and buy some more, ");
    try out.print("{} bottles of beer on the wall.\n\n", .{99});
}
