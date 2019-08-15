const std = @import("std");

pub fn main() anyerror!void {
    // If this program is run without stdout attached, exit with an error.
    const out_file = try std.io.getStdOut();
    var out_stream = out_file.outStream();
    var out = &out_stream.stream;
    
    var bottles: i8 = 99;
    while(bottles >= 0){
        // If this program encounters pipe failure when printing to stdout, exit
        // with an error.
        switch (bottles) {
            1 => {
                try out.print("{} bottle of beer on the wall, ", bottles);
                try out.print("{} bottle of beer.\n", bottles); 
            },
            0 => {
                try out.print("{} bottles of beer on the wall, ", "No more");
                try out.print("{} bottles of beer.\n", "no more");
            },
            else => {
                try out.print("{} bottles of beer on the wall, ", bottles);
                try out.print("{} bottles of beer.\n", bottles);
            },
        }
        
        switch (bottles) {
            0 => {
                try out.print("Go to the store and buy some more, ");
            },
            else => {
                try out.print("Take one down and pass it around, ");
            },
        }
        
        bottles -= 1;
        
        switch (bottles) {
            1 => {
                try out.print("{} bottle of beer on the wall.\n\n", bottles);    
            },
            0 => {
                try out.print("{} bottles of beer on the wall.\n\n", "no more");    
            },
            -1 => {
                try out.print("{} bottles of beer on the wall.\n\n", i8(99));    
            },
            else => {
                try out.print("{} bottles of beer on the wall.\n\n", bottles);  
            },
        }
    }
}
