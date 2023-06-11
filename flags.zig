const std = @import("std");
const os = std.os;
const testing = std.testing;

pub fn string(short: []const u8, long: []const u8, default: []const u8) []const u8 {
    var index = flagIndex(short, long);
    // no matched arguments found
    if (index == 0) {
        return default;
    }

    return std.mem.sliceTo(os.argv[index], 0);
}

// flagIndex retrieves an index of a command line argument
// that matches given flag (short or long form)
fn flagIndex(short: []const u8, long: []const u8) usize {
    for (os.argv) |elem, i| {
        // transform argument to a fitting format
        var strArg = std.mem.sliceTo(elem, 0); 

        if (flagCompare(strArg, short)) {
            return i;
        }
        if (flagCompare(strArg, long)) {
            return i;
        }
    }

    return 0;
}


// flagCompare matches argument with flag
fn flagCompare(arg: []const u8, flag: []const u8) bool {
    // argument length can be equal of greater then flag provided
    // in case of equal sign '='
    // --file=example.csv
    if (flag.len > arg.len) {
        return false;
    }

    // same values
    if (strEql(arg, flag)) {
        return true;
    }

    // --flag=value
    if (arg[flag.len] == '=') {
        return true;
    }


    return false;
}

test "flagCompare" {
    // flag greater then arg
    try testing.expect(!flagCompare("file", "--path"));
    try testing.expect(!flagCompare("", "-h"));

    // equal values
    try testing.expect(flagCompare("a", "a"));
    try testing.expect(flagCompare("file", "file"));
    try testing.expect(flagCompare("-f", "-f"));
    try testing.expect(flagCompare("--help", "--help"));
    try testing.expect(flagCompare("", ""));

    // argument with equal sign
    try testing.expect(flagCompare("-f=file", "-f"));
    try testing.expect(flagCompare("--path=/home/user", "--path"));

    // starts the same but with ou equal sign
    try testing.expect(!flagCompare("--path123", "--path"));
    try testing.expect(!flagCompare("-sss", "-s"));
}


// check if 2 strings are equal
fn strEql(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) {
        return false;
    }

    for (a) |_, i| {
        if (a[i] != b[i]) {
            return false;
        }
    }

    return true;
}

test "strEql" {
    // equal values
    try testing.expect(strEql("a", "a"));
    try testing.expect(strEql("file", "file"));
    try testing.expect(strEql("-f", "-f"));
    try testing.expect(strEql("--help", "--help"));
    try testing.expect(strEql("", ""));

    // different values
    try testing.expect(!strEql("a", "bb"));
    try testing.expect(!strEql("", "Hello World!"));
    try testing.expect(!strEql("--file", "--help"));
}