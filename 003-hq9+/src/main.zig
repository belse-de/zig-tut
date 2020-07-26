const std = @import("std");

pub fn main() anyerror!void {
    //std.debug.warn("All your base are belong to us.\n");

    // If this program is run without stdin or stdout attached, exit with an error.
    const stdin_file = std.io.getStdIn();
    const out = std.io.getStdOut().outStream();

    var buffer: [1000]u8 = undefined;
    var read_bytes = try stdin_file.read(buffer[0..]);
    var accumulator: u128 = 0;

    while (read_bytes > 0) : (read_bytes = try stdin_file.read(buffer[0..])) {
        for (buffer[0..(read_bytes - 1)]) |c| {
            switch (c) {
                'h', 'H' => {
                    try out.writeAll("Hello, world!\n");
                },
                'q', 'Q' => {
                    try out.writeAll(buffer[0..(read_bytes - 1)]);
                    try out.writeAll("\n");
                },
                '9' => {
                    var bottles: u8 = 99;
                    var text_buffer: [16]u8 = "99 bottles".* ++ [_]u8{0} ** 6;
                    var text = text_buffer[0..10];
                    while (bottles > 0) {
                        // If this program encounters pipe failure when printing to stdout,
                        // exit with an error.
                        try out.print("{} of beer on the wall, ", .{text});
                        try out.print("{} of beer.\n", .{text});
                        try out.writeAll("Take one down and pass it around, ");

                        bottles -= 1;
                        _ = switch (bottles) {
                            0 => try std.fmt.bufPrint(text_buffer[0..], "{} bottles", .{"no more"}),
                            1 => try std.fmt.bufPrint(text_buffer[0..], "{} bottle", .{bottles}),
                            else => try std.fmt.bufPrint(text_buffer[0..], "{} bottles", .{bottles}),
                        };

                        try out.print("{} of beer on the wall.\n\n", .{text});
                    }

                    try out.print("{} bottles of beer on the wall, ", .{"No more"});
                    try out.print("{} bottles of beer.\n", .{"no more"});
                    try out.writeAll("Go to the store and buy some more, ");
                    try out.print("{} bottles of beer on the wall.\n\n", .{99});
                },
                '+' => {
                    accumulator += 1;
                },
                else => {},
            }
        }
    }
}
