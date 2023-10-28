const std = @import("std");
const testing = std.testing;
const toml_to_json = @cImport({
    @cInclude("toml-to-json.h");
});

fn toSlice(str: [*c]u8) []u8 {
    const len = std.mem.indexOfSentinel(u8, 0, str);
    return str[0..len];
}

pub fn parseToml(comptime T: type, a: std.mem.Allocator, input_string: []const u8) !std.json.Parsed(T) {
    const raw_string = toml_to_json.tomlToJson(input_string.ptr);
    if (raw_string == null) {
        return error.toml_cannot_be_converted_to_json;
    }
    const string = toSlice(raw_string);
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
