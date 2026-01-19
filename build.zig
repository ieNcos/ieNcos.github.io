const std = @import("std");

pub fn build(b: *std.Build) void {
    const commit_msg = b.option([]const u8, "msg", "Commit message for deployment") orelse "automated deploy";
    const compile_exe = b.addExecutable(.{
        .name = "compile",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });
    const run_cmd = b.addRunArtifact(compile_exe);
    b.getInstallStep().dependOn(&run_cmd.step);

    const git_add = b.addSystemCommand(&.{
        "git",
        "add",
        "--all",
    });
    git_add.step.dependOn(&run_cmd.step);

    const git_commit = b.addSystemCommand(&.{
        "git",
        "commit",
        "-m",
        commit_msg,
    });
    git_commit.step.dependOn(&git_add.step);

    const git_push = b.addSystemCommand(&.{
        "git",
        "push",
    });
    git_push.step.dependOn(&git_commit.step);

    b.step("deploy", "Publish the website").dependOn(&git_push.step);
}
