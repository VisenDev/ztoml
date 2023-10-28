const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-toml",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // =============TOML TO JSON LINKING=================
    const rust_compile = b.addSystemCommand(&[_][]const u8{
        "cargo",
        "build",
        "--release",
    });
    b.default_step.dependOn(&rust_compile.step);

    lib.addLibraryPath(.{ .path = "target/release" });
    lib.linkSystemLibrary("toml_to_json");

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.addLibraryPath(.{ .path = "target/release" });
    main_tests.linkSystemLibrary("toml_to_json");
    main_tests.addIncludePath(.{ .path = "src" });
    main_tests.step.dependOn(b.getInstallStep());

    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
