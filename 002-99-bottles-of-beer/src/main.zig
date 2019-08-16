const std = @import("std");

pub fn main() anyerror!void {
    // If this program is run without stdout attached, exit with an error.
    //This does not work: var out_stream = try std.io.getStdOut().outStream();
    const out_file = try std.io.getStdOut();
    var out_stream = out_file.outStream();
    var out = &out_stream.stream;
    
    var bottles: u8 = 99;
    while(bottles > 2){
        // If this program encounters pipe failure when printing to stdout, exit
        // with an error.
        try out.print("{} bottles of beer on the wall, ", bottles);
        try out.print("{} bottles of beer.\n", bottles);
        try out.print("Take one down and pass it around, ");
        bottles -= 1;       
        try out.print("{} bottles of beer on the wall.\n\n", bottles);  
    }
    
    try out.print("{} bottles of beer on the wall, ", bottles);
    try out.print("{} bottles of beer.\n", bottles);
    try out.print("Take one down and pass it around, ");
    bottles -= 1;
    try out.print("{} bottle of beer on the wall.\n\n", bottles); 
    
    try out.print("{} bottle of beer on the wall, ", bottles);
    try out.print("{} bottle of beer.\n", bottles); 
    try out.print("Take one down and pass it around, ");
    bottles -= 1;
    try out.print("{} bottles of beer on the wall.\n\n", "no more");
    
    try out.print("{} bottles of beer on the wall, ", "No more");
    try out.print("{} bottles of beer.\n", "no more");
    try out.print("Go to the store and buy some more, ");
    try out.print("{} bottles of beer on the wall.\n\n", u8(99)); 
}
