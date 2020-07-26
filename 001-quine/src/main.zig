const std = @import("std");

pub fn main() anyerror!void {
    const out_stream = std.io.getStdOut().outStream();

    const src = @embedFile("main.zig");
    try out_stream.writeAll(src);
}
