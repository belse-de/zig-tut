const std = @import("std");

const io = std.io;

const warn = std.log.warn;
const assert = std.debug.assert;

fn jumpForward(prog: []const u8, prog_ptr: usize) usize {
    var bracket_stack: usize = 1;
    var ptr: usize = prog_ptr;

    while (bracket_stack > 0) {
        ptr += 1;
        // if (ptr >= prog.len) // expected matching
        switch (prog[ptr]) {
            '[' => bracket_stack += 1,
            ']' => bracket_stack -= 1,
            else => {},
        }
    }

    return ptr;
}

test "jumpForward" {
    assert(jumpForward("[]", 0) == 1);
    assert(jumpForward("[[]]", 0) == 3);
    assert(jumpForward("[[]]", 1) == 2);
    assert(jumpForward("[[][]]", 0) == 5);
    assert(jumpForward("[[][]]", 1) == 2);
    assert(jumpForward("[[][]]", 3) == 4);
}

fn jumpBackward(prog: []const u8, prog_ptr: usize) usize {
    var bracket_stack: usize = 1;
    var ptr: usize = prog_ptr;

    while (bracket_stack > 0) {
        ptr -= 1;
        // if (ptr >= prog.len) // expected matching
        switch (prog[ptr]) {
            '[' => bracket_stack -= 1,
            ']' => bracket_stack += 1,
            else => {},
        }
    }

    return ptr;
}

test "jumpBackward" {
    assert(jumpBackward("[]", 1) == 0);
    assert(jumpBackward("[[]]", 3) == 0);
    assert(jumpBackward("[[]]", 2) == 1);
    assert(jumpBackward("[[][]]", 5) == 0);
    assert(jumpBackward("[[][]]", 2) == 1);
    assert(jumpBackward("[[][]]", 4) == 3);
}

// TODO: for test:
//       add out_file and in_file as argument
//       add caching for jump destinations
fn bf(prog: []const u8, mem: []u8) !void {
    const in_file = io.getStdIn();
    const out_file = io.getStdOut();

    var mem_ptr: usize = 0;
    var prog_ptr: usize = 0;

    while (prog_ptr < prog.len) {
        switch (prog[prog_ptr]) {
            '+' => mem[mem_ptr] +%= 1,
            '-' => mem[mem_ptr] -%= 1,
            '>' => mem_ptr += 1,
            '<' => mem_ptr -= 1,
            '.' => {
                _ = try out_file.write(mem[mem_ptr..mem_ptr]); // FIXME
            },
            ',' => {
                _ = try in_file.read(mem[mem_ptr..mem_ptr]); // FIXME
            },
            '[' => if (mem[mem_ptr] == 0) {
                prog_ptr = jumpForward(prog, prog_ptr);
            },
            ']' => if (mem[mem_ptr] != 0) {
                prog_ptr = jumpBackward(prog, prog_ptr);
            },
            else => {},
        }
        prog_ptr += 1;
    }
}

pub fn main() anyerror!void {
    std.log.warn("Zig brainfuck interpreter.\n", .{});

    const allocator_impl = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(allocator_impl);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args, 0..) |arg, arg_i| {
        std.log.warn("{}: {s}\n", .{ arg_i, arg });
    }
    
    // TODO: add pramater validation
    const prog_path = args[1];
    const cwd = std.fs.cwd();
    const prog = try cwd.readFileAlloc(allocator, prog_path, 1024);
    std.log.warn("{s}\n", .{prog});
    defer allocator.free(prog);

    // const prog = "+[,.]"; // cat
    var mem = [_]u8{0} ** 1024;
    try bf(prog, mem[0..]);
}

test "all instructions once -> no crash" {
    const prog = "+-><.,[]";
    var mem = [_]u8{0} ** 1024;
    try bf(prog, mem[0..]);
}

test "add" {
    std.log.warn("\n", .{});
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.log.warn("{}.", .{count});

        const prog = [_]u8{'+'} ** count;
        var mem = [_]u8{0} ** 1;
        try bf(&prog, &mem);

        assert(mem[0] == count);
    }
    std.log.warn("\n", .{});
}

test "sub" {
    std.log.warn("\n", .{});
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.log.warn("{}.", .{count});

        const prog = [_]u8{'-'} ** count;
        var mem = [_]u8{0} ** 1;
        try bf(&prog, &mem);

        assert(mem[0] == 256 - count);
    }
    std.log.warn("\n", .{});
}

test "add ** 256 = 0" {
    const count: usize = 256;
    const prog = [_]u8{'+'} ** count;
    var mem = [_]u8{0} ** 1;

    try bf(&prog, &mem);

    assert(mem[0] == 0);
}

test "sub ** 256 = 0" {
    const count: usize = 256;
    const prog = [_]u8{'-'} ** count;
    var mem = [_]u8{0} ** 1;

    try bf(&prog, &mem);

    assert(mem[0] == 0);
}

test ">>>" {
    var mem = [_]u8{0} ** 4;
    const src = ">>>+++";
    try bf(src, &mem);
    assert(mem[3] == 3);
}

test "<<<" {
    var mem = [_]u8{0} ** 4;
    const src = ">>>>>><<<+++";
    try bf(src, &mem);
    assert(mem[3] == 3);
}

test "shift right" {
    std.log.warn("\n", .{});
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.log.warn("{}.", .{count});

        const prog = [_]u8{'>'} ** count ++ [_]u8{'+'} ** count;
        var mem = [_]u8{0} ** 256;
        try bf(&prog, &mem);

        assert(mem[count] == count);
    }
    std.log.warn("\n", .{});
}

test "shift left" {
    std.log.warn("\n", .{});
    comptime var count: usize = 256;
    inline while (count > 1) {
        count -= 1;
        std.log.warn("{}.", .{count});

        const prog = [_]u8{'>'} ** 256 ++ [_]u8{'<'} ** count ++ [_]u8{'+'} ** count;
        var mem = [_]u8{0} ** 256;
        try bf(&prog, &mem);

        assert(mem[256 - count] == count);
    }
    std.log.warn("\n", .{});
}

test "reset [+]" {
    var mem = [_]u8{128} ** 1;
    const prog = "[-]";

    try bf(prog, &mem);

    assert(mem[0] == 0);
}

test "reset [-]" {
    var mem = [_]u8{128} ** 1;
    const prog = "[+]";

    try bf(prog, &mem);

    assert(mem[0] == 0);
}

test "hallo world" {
    const prog = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.";
    var mem = [_]u8{0} ** 1024;
    try bf(prog, &mem);
}
