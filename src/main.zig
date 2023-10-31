const std = @import("std");
const testing = std.testing;
const toml_to_json = @cImport({
    @cInclude("toml-to-json.h");
});

fn toSlice(str: [*c]u8) []u8 {
    const len = std.mem.indexOfSentinel(u8, 0, str);
    return str[0..len];
}

pub fn parseToml(comptime T: type, a: std.mem.Allocator, input_string: [:0]const u8) !std.json.Parsed(T) {
    //convert toml to json with rust
    const raw_string = toml_to_json.tomlToJson(input_string.ptr);
    defer toml_to_json.tomlToJsonFree(raw_string);

    //check for failure
    if (raw_string == null) {
        return error.toml_cannot_be_converted_to_json;
    }

    //convert to zig friendly slice
    const string = toSlice(raw_string);

    //parse and return as parsed json
    return std.json.parseFromSlice(T, a, string, .{ .allocate = .alloc_always });
}

test {
    const toml =
        \\[data]
        \\author = "Robert"
        \\github = "VisenDev"
        \\#heres a comment
        \\
        \\[numbers]
        \\list = [1, 2, 3]
    ;
    const toml_type = struct {
        data: struct {
            author: []const u8,
            github: []const u8,
        },
        numbers: struct {
            list: []const u32,
        },
    };
    const parsed = try parseToml(toml_type, std.testing.allocator, toml);
    defer parsed.deinit();
}

test "failing" {
    const toml =
        \\[data]
        \\author = "Robert"sldfkajs;ldkfj;af[a][][a]sdf[]"""""""
        \\github = "VisenDev"
        \\#heres a commentalksd;flakjsdf[]s[df][][]
        \\
        \\[numbers]
        \\list = [1, 2, 3]
    ;
    const toml_type = struct {
        data: struct {
            author: []const u8,
            github: []const u8,
        },
        numbers: struct {
            list: []const u32,
        },
    };
    const parsed = parseToml(toml_type, std.testing.allocator, toml) catch return;
    defer parsed.deinit();
}
