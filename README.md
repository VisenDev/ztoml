# ztoml

Easily parse toml into a zig struct

### Usage

```zig
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

```

### Installation

Add this to your build.zig
```zig

    const ztoml_dep = b.dependency("ztoml", .{});
    b.default_step.dependOn(ztoml_dep.builder.default_step);
    exe.addModule("ztoml", ztoml_dep.module("ztoml"));
    @import("ztoml").link(ztoml_dep.builder, exe);

```

And this to your build.zig.zon dependencies
```zig
      .dependencies = .{
         .ztoml = .{
            //zig compiler will suggest the correct hash
            .url = "https://github.com/VisenDev/ztoml/archive/refs/heads/main.tar.gz",
         },
      },
 


```


### Troubleshooting

Make sure you pass a sentinel terminated string to parseToml or the function will fail. You can use the `allocator.dupeZ` to acheive this if your u8 slice isn't null terminated

### Caveats

This package is dependent on rust so you must have `cargo` installed on your system
