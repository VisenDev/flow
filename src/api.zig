const std = @import("std");

const tp = @import("thespian");

pub const VTable = struct {
    sendKeys: *fn (ctx: *anyopaque, msg: tp.message) tp.message,
    executeFunction: *fn (ctx: *anyopaque, msg: tp.message) tp.message,
    executeCommand: *fn (ctx: *anyopaque, msg: tp.message) tp.message,
};

export const PluginInterface = struct {
    ctx: *anyopaque,
    //vtable: *VTable,
    pub fn sendKeys(ctx: *anyopaque, msg: tp.message) void {
        _ = ctx; // autofix
        _ = msg; // autofix
    }
    pub fn sendCommand(ctx: *anyopaque, cmd: []const u8) void {
        _ = ctx; // autofix
        _ = cmd; // autofix
    }
};

pub fn getPluginDir() []const u8 {}

pub fn loadPlugins(interface: *PluginInterface, allocator: std.mem.Allocator) !void {
    var dir = try std.fs.openDirAbsolute(getPluginDir(), .{ .iterate = true });
    var iter = dir.iterate();
    while (iter.next()) |file| {
        const abs_path = std.mem.concat(allocator, u8, &.{ getPluginDir(), file.name });
        const lib = std.DynLib.open(abs_path);
        const InitFn = fn (PluginInterface) *anyopaque;
        const initFn = lib.lookup(InitFn, "init") orelse continue;
        @call(.auto, initFn, .{interface});
    }
    //const plugin =
}
