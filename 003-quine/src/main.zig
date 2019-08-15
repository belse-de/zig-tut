const std = @import("std");

pub fn main() anyerror!void {
    const out_file = try std.io.getStdOut();
    
    const src = @embedFile("main.zig");
    try out_file.write(src);
}
