const std = @import("std");

const io = std.io;

const warn = std.debug.warn;
const assert = std.debug.assert;

fn bf(prog: []const u8, mem: []u8) !void {
    const in_file = try io.getStdIn();
    const out_file = try io.getStdOut();

    var mem_ptr: usize = 0;
    var prog_ptr: usize = 0;

    while (prog_ptr < prog.len) {
        switch (prog[prog_ptr]) {
            '+' => mem[mem_ptr] +%= 1,
            '-' => mem[mem_ptr] -%= 1,
            '>' => mem_ptr += 1,
            '<' => mem_ptr -= 1,
            '.' => {
                try out_file.write(mem[mem_ptr..mem_ptr]);
            },
            ',' => {
                _ = try in_file.read(mem[mem_ptr..mem_ptr]);
            },
            //'[' => {},
            //']' => {},
            else => {},
        }
        prog_ptr += 1;
    }
}

pub fn main() anyerror!void {
    std.debug.warn("Zig brainfuck interpreter.\n");

    const prog = "+[,.]"; // cat
    var mem = []u8{0} ** 1024;
    try bf(prog, mem[0..]);
}

test "all instructions once -> no crash" {
    const prog = "+-><.,[]";
    var mem = []u8{0} ** 1024;
    try bf(prog, mem[0..]);
}

test "add" {
    std.debug.warn("\n");
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.debug.warn("{}.", count);

        const prog = []u8{'+'} ** count;
        var mem = []u8{0} ** 1;
        try bf(prog, &mem);

        assert(mem[0] == count);
    }
    std.debug.warn("\n");
}

test "sub" {
    std.debug.warn("\n");
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.debug.warn("{}.", count);

        const prog = []u8{'-'} ** count;
        var mem = []u8{0} ** 1;
        try bf(prog, &mem);

        assert(mem[0] == 256 - count);
    }
    std.debug.warn("\n");
}

test "add ** 256 = 0" {
    comptime const count: usize = 256;
    const prog = []u8{'+'} ** count;
    var mem = []u8{0} ** 1;

    try bf(prog, &mem);

    assert(mem[0] == 0);
}

test "sub ** 256 = 0" {
    comptime const count: usize = 256;
    const prog = []u8{'-'} ** count;
    var mem = []u8{0} ** 1;

    try bf(prog, &mem);

    assert(mem[0] == 0);
}

test ">>>" {
    var mem = []u8{0} ** 4;
    const src = ">>>+++";
    try bf(src, &mem);
    assert(mem[3] == 3);
}

test "<<<" {
    var mem = []u8{0} ** 4;
    const src = ">>>>>><<<+++";
    try bf(src, &mem);
    assert(mem[3] == 3);
}

test "shift right" {
    std.debug.warn("\n");
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.debug.warn("{}.", count);

        const prog = []u8{'>'} ** count ++ []u8{'+'} ** count;
        var mem = []u8{0} ** 256;
        try bf(prog, &mem);

        assert(mem[count] == count);
    }
    std.debug.warn("\n");
}

test "shift left" {
    std.debug.warn("\n");
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.debug.warn("{}.", count);

        const prog = []u8{'>'} ** 256 ++ []u8{'<'} ** count ++ []u8{'+'} ** count;
        var mem = []u8{0} ** 256;
        try bf(prog, &mem);

        assert(mem[256 - count] == count);
    }
    std.debug.warn("\n");
}

test "reset [+]" {
    var mem = []u8{128} ** 1;
    const prog = "[-]";

    try bf(prog, &mem);

    assert(mem[0] == 0);
}

test "reset [-]" {
    var mem = []u8{128} ** 1;
    const prog = "[+]";

    try bf(prog, &mem);

    assert(mem[0] == 0);
}
