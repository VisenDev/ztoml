const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    //create the module
    const module = b.addModule("ztoml", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    // =============TOML TO JSON LINKING=================
    const rust_compile = b.addSystemCommand(&[_][]const u8{
        "cargo",
        "build",
        "--release",
    });
    b.default_step.dependOn(&rust_compile.step);
    module.builder.default_step.dependOn(&rust_compile.step);

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

///This function is required because you can't currenly directly link modules with libraries
pub fn link(b: *std.Build, step: *std.build.CompileStep) void {
    step.addLibraryPath(.{ .path = b.pathFromRoot("target/release") });
    step.linkSystemLibrary("toml_to_json");
    step.addIncludePath(.{ .path = b.pathFromRoot("src") });
}
