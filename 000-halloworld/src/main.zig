const std = @import("std");

pub fn main() anyerror!void {
    // If this program is run without stdout attached, exit with an error.
    const stdout_stream = std.io.getStdOut().outStream();
    // If this program encounters pipe failure when printing to stdout, exit
    // with an error.
    try stdout_stream.writeAll("Hello, world!\n");
}
