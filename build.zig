const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const link = b.addStaticLibrary(.{
        .name = "abl_link",
        .target = target,
        .optimize = optimize,
    });

    const asio = b.dependency("asio", .{
        .target = target,
        .optimize = optimize,
    });
    link.linkLibrary(asio.artifact("asio"));

    const os_tag = target.os_tag orelse
        (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target.os.tag;

    link.installHeader(b.pathJoin(&.{ "extensions", "abl_link", "include", "abl_link.h" }), "abl_link.h");
    const link_macros = switch (os_tag) {
        .macos => "LINK_PLATFORM_MACOSX",
        .windows => "LINK_PLATFORM_WINDOWS",
        else => "LINK_PLATFORM_LINUX",
    };
    link.defineCMacro(link_macros, null);
    link.addCSourceFile(.{
        .file = .{ .path = b.pathJoin(&.{ "extensions", "abl_link", "src", "abl_link.cpp" }) },
        .flags = &.{},
    });
    link.addIncludePath(.{ .path = "include" });
    link.addIncludePath(.{ .path = "extensions/abl_link/include" });
    link.linkLibC();
    link.linkLibCpp();
    b.installArtifact(link);
}
