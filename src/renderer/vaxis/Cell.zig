const vaxis = @import("vaxis");
const Style = @import("theme").Style;
const Color = @import("theme").Color;
const FontStyle = @import("theme").FontStyle;
const color = @import("color");

const Cell = @This();

cell: vaxis.Cell = .{},

pub inline fn set_style(self: *Cell, style_: Style) void {
    self.set_style_fg(style_);
    self.set_style_bg(style_);
    if (style_.fs) |fs| self.set_font_style(fs);
}

pub inline fn set_font_style(self: *Cell, fs: FontStyle) void {
    self.cell.style.ul = .default;
    self.cell.style.ul_style = .off;
    self.cell.style.bold = false;
    self.cell.style.dim = false;
    self.cell.style.italic = false;
    self.cell.style.blink = false;
    self.cell.style.reverse = false;
    self.cell.style.invisible = false;
    self.cell.style.strikethrough = false;

    switch (fs) {
        .normal => {},
        .bold => self.cell.style.bold = true,
        .italic => self.cell.style.italic = true,
        .underline => self.cell.style.ul_style = .single,
        .undercurl => self.cell.style.ul_style = .curly,
        .strikethrough => self.cell.style.strikethrough = true,
    }
}

pub inline fn set_under_color(self: *Cell, arg_rgb: c_uint) void {
    self.cell.style.ul = vaxis.Cell.Color.rgbFromUint(@intCast(arg_rgb));
}

inline fn apply_alpha(base_vaxis: vaxis.Cell.Color, over_theme: Color) vaxis.Cell.Color {
    const alpha = over_theme.alpha;
    return if (alpha == 0xFF or base_vaxis != .rgb)
        vaxis.Cell.Color.rgbFromUint(over_theme.color)
    else blk: {
        const base = color.RGB.from_u8s(base_vaxis.rgb);
        const over = color.RGB.from_u24(over_theme.color);
        const result = color.apply_alpha(base, over, alpha);
        break :blk .{ .rgb = result.to_u8s() };
    };
}

pub inline fn set_style_fg(self: *Cell, style_: Style) void {
    if (style_.fg) |fg| self.cell.style.fg = apply_alpha(self.cell.style.bg, fg);
}

pub inline fn set_style_bg_opaque(self: *Cell, style_: Style) void {
    if (style_.bg) |bg| self.cell.style.bg = vaxis.Cell.Color.rgbFromUint(bg.color);
}

pub inline fn set_style_bg(self: *Cell, style_: Style) void {
    if (style_.bg) |bg| self.cell.style.bg = apply_alpha(self.cell.style.bg, bg);
}

pub inline fn set_fg_rgb(self: *Cell, arg_rgb: c_uint) !void {
    self.cell.style.fg = vaxis.Cell.Color.rgbFromUint(@intCast(arg_rgb));
}
pub inline fn set_bg_rgb(self: *Cell, arg_rgb: c_uint) !void {
    self.cell.style.bg = vaxis.Cell.Color.rgbFromUint(@intCast(arg_rgb));
}

pub fn columns(self: *const Cell) usize {
    // return if (self.cell.char.width == 0) self.window.gwidth(self.cell.char.grapheme) else self.cell.char.width; // FIXME?
    return self.cell.char.width;
}

pub fn dim(self: *Cell, alpha: u8) void {
    self.dim_fg(alpha);
    self.dim_bg(alpha);
}

pub fn dim_bg(self: *Cell, alpha: u8) void {
    self.cell.style.bg = apply_alpha_value(self.cell.style.bg, alpha);
}

pub fn dim_fg(self: *Cell, alpha: u8) void {
    self.cell.style.fg = apply_alpha_value(self.cell.style.fg, alpha);
}

fn apply_alpha_value(c: vaxis.Cell.Color, a: u8) vaxis.Cell.Color {
    var rgb = if (c == .rgb) c.rgb else return c;
    rgb[0] = @intCast((@as(u32, @intCast(rgb[0])) * a) / 256);
    rgb[1] = @intCast((@as(u32, @intCast(rgb[1])) * a) / 256);
    rgb[2] = @intCast((@as(u32, @intCast(rgb[2])) * a) / 256);
    return .{ .rgb = rgb };
}
