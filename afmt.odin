package afmt //	ANSI Format printing library.

import cfmt "core:fmt" // renamed "c" for core to prevent name collision with "fmt" in procedure definitions
import "core:strings"
import "core:strconv"
import "core:terminal"
import "core:terminal/ansi"

//	Aliases of all the below structures to help reduce syntax
//	This is here for advanced users who are already familiar with the types


AF     :: ANSI_Format
AT     :: Attribute
A3BIT  :: ANSI_3Bit
A4BIT  :: ANSI_4Bit
A8BIT  :: ANSI_8Bit
A24BIT :: ANSI_24Bit
FG3BIT :: FG_Color_3Bit
BG3BIT :: BG_Color_3Bit
FG4BIT :: FG_Color_4Bit
BG4BIT :: BG_Color_4Bit

//	Attributes - independent of ANSI_Format variants
Attribute :: enum u8 {
	NONE                    = 0,
	BOLD                    = 1,
	FAINT                   = 2,
	ITALIC                  = 3,
	UNDERLINE               = 4,
	BLINK_SLOW              = 5,
	BLINK_RAPID             = 6, // Not widely supported.
	INVERT                  = 7, // Also known as reverse video.
	HIDE                    = 8, // Not widely supported.
	STRIKE                  = 9,
	FONT_PRIMARY            = 10,
	FONT_ALT1               = 11,
	FONT_ALT2               = 12,
	FONT_ALT3               = 13,
	FONT_ALT4               = 14,
	FONT_ALT5               = 15,
	FONT_ALT6               = 16,
	FONT_ALT7               = 17,
	FONT_ALT8               = 18,
	FONT_ALT9               = 19,
	FONT_FRAKTUR            = 20, // Rarely supported.
	UNDERLINE_DOUBLE        = 21, // May be interpreted as "disable bold."
	NO_BOLD_FAINT           = 22,
	NO_ITALIC_BLACKLETTER   = 23,
	NO_UNDERLINE            = 24,
	NO_BLINK                = 25,
	PROPORTIONAL_SPACING    = 26,
	NO_REVERSE              = 27,
	NO_HIDE                 = 28,
	NO_STRIKE               = 29,
	NO_PROPORTIONAL_SPACING = 50,
	FRAMED                  = 51, // Not widely supported.
	ENCIRCLED               = 52, // Not widely supported.
	OVERLINED               = 53,
	NO_FRAME_ENCIRCLE       = 54,
	NO_OVERLINE             = 55,
}

//	Union variants of ANSI_Format
ANSI_Format :: union {
	ANSI_3Bit,
	ANSI_4Bit,
	ANSI_8Bit,
	ANSI_24Bit,
}

//	3 Bit Color data structure - 8 colors
ANSI_3Bit :: struct {
	fg: FG_Color_3Bit,      // foreground
	bg: BG_Color_3Bit,      // background
	at: bit_set[Attribute], // attributes
}
//	Foreground 3 Bit Colors
FG_Color_3Bit :: enum u8 {
	NONE       = 0,
	FG_BLACK   = 30,
	FG_RED     = 31,
	FG_GREEN   = 32,
	FG_YELLOW  = 33,
	FG_BLUE    = 34,
	FG_MAGENTA = 35,
	FG_CYAN    = 36,
	FG_WHITE   = 37,
	FG_DEFAULT = 39,
}
//	Background 3 Bit Colors
BG_Color_3Bit :: enum u8 {
	NONE       = 0,
	BG_BLACK   = 40,
	BG_RED     = 41,
	BG_GREEN   = 42,
	BG_YELLOW  = 43,
	BG_BLUE    = 44,
	BG_MAGENTA = 45,
	BG_CYAN    = 46,
	BG_WHITE   = 47,
	BG_DEFAULT = 49,
}

//	4 Bit Color Printing - 16 colors
ANSI_4Bit :: struct {
	fg: FG_Color_4Bit,      // foreground
	bg: BG_Color_4Bit,      // background
	at: bit_set[Attribute], // attributes
}
//	Foreground 4 Bit Colors
FG_Color_4Bit :: enum u8 {
	NONE              = 0,
	FG_BLACK          = 30,
	FG_RED            = 31,
	FG_GREEN          = 32,
	FG_YELLOW         = 33,
	FG_BLUE           = 34,
	FG_MAGENTA        = 35,
	FG_CYAN           = 36,
	FG_WHITE          = 37,
	FG_DEFAULT        = 39,
	FG_BRIGHT_BLACK   = 90, // Also known as grey.
	FG_BRIGHT_RED     = 91,
	FG_BRIGHT_GREEN   = 92,
	FG_BRIGHT_YELLOW  = 93,
	FG_BRIGHT_BLUE    = 94,
	FG_BRIGHT_MAGENTA = 95,
	FG_BRIGHT_CYAN    = 96,
	FG_BRIGHT_WHITE   = 97,
}
//	Background 4 Bit Colors
BG_Color_4Bit :: enum u8 {
	NONE              = 0,
	BG_BLACK          = 40,
	BG_RED            = 41,
	BG_GREEN          = 42,
	BG_YELLOW         = 43,
	BG_BLUE           = 44,
	BG_MAGENTA        = 45,
	BG_CYAN           = 46,
	BG_WHITE          = 47,
	BG_DEFAULT        = 49,
	BG_BRIGHT_BLACK   = 100, // Also known as grey.
	BG_BRIGHT_RED     = 101,
	BG_BRIGHT_GREEN   = 102,
	BG_BRIGHT_YELLOW  = 103,
	BG_BRIGHT_BLUE    = 104,
	BG_BRIGHT_MAGENTA = 105,
	BG_BRIGHT_CYAN    = 106,
	BG_BRIGHT_WHITE   = 107,
}

//	8 Bit Color Printing - 256 colors
ANSI_8Bit :: struct {
	fg: Maybe(u8),          // foreground - 0-255 - can be nil
	bg: Maybe(u8),          // background - 0-255 - can be nil
	at: bit_set[Attribute], // attributes
}

//	24 Bit (TrueColor) Color Printing - 16.7 million colors
ANSI_24Bit :: struct {
	fg: RGB,                // foreground - {r, g, b} can be nil
	bg: RGB,                // background - {r, g, b} can be nil
	at: bit_set[Attribute], // attributes
}
//	RGB type for ANSI_24Bit Colors
RGB :: distinct [3]Maybe(u8)
//
//	ANSI Control Sequence formatter
//
//	Input:
//	- afmt: ANSI_Format struct containing the defined ANSI sequence to apply to fmt.
//	- fmt: In many cases (not all), a format string with placeholders for the provided print arguments.
//
//	Returns: the fmt string wrapped in the specified ANSI sequence
@(require_results)
afmt :: proc(afmt: ANSI_Format, fmt: string) -> string {
	acs: string // ANSI Control Sequence

	if terminal.color_enabled {

		// Delimitor - Specialized for internal use only - assumes acs is also in args[0]
		delimit :: proc(acs: ^string, args: ..any) {
			if len(acs^) == 0 { // exclude acs when it is empty - prevent extra semi-colon
				acs^ = cfmt.tprint(..args[1:], sep = ";")
			} else { // include acs when it is not empty
				acs^ = cfmt.tprint(..args, sep = ";")
			}
		}

		// Process ANSI_Format variants
		switch a in afmt {
		case ANSI_3Bit:	if terminal.color_depth >= .Three_Bit {
				if .NONE not_in a.at {
					for a in a.at {
						delimit(&acs, acs, u8(a))
					}
				}
				if a.fg != .NONE {
					delimit(&acs, acs, u8(a.fg))
				}
				if a.bg != .NONE {
					delimit(&acs, acs, u8(a.bg))
				}
			}
		case ANSI_4Bit:	if terminal.color_depth >= .Four_Bit {
				if .NONE not_in a.at {
					for a in a.at {
						delimit(&acs, acs, u8(a))
					}
				}
				if a.fg != .NONE {
					delimit(&acs, acs, u8(a.fg))
				}
				if a.bg != .NONE {
					delimit(&acs, acs, u8(a.bg))
				}
			}
		case ANSI_8Bit:	if terminal.color_depth >= .Eight_Bit {
				if .NONE not_in a.at {
					for a in a.at {
						delimit(&acs, acs, u8(a))
					}
				}
				if a.fg != nil {
					delimit(&acs, acs, ansi.FG_COLOR_8_BIT, a.fg)
				}
				if a.bg != nil {
					delimit(&acs, acs, ansi.BG_COLOR_8_BIT, a.bg)
				}
			}
		case ANSI_24Bit: if terminal.color_depth >= .True_Color {
				if .NONE not_in a.at {
					for a in a.at {
						delimit(&acs, acs, u8(a))
					}
				}
				if a.fg.r != nil && a.fg.g != nil && a.fg.b != nil {
					delimit(&acs, acs, ansi.FG_COLOR_24_BIT, a.fg.r, a.fg.g, a.fg.b)
				}
				if a.bg.r != nil && a.bg.g != nil && a.bg.b != nil {
					delimit(&acs, acs, ansi.BG_COLOR_24_BIT, a.bg.r, a.bg.g, a.bg.b)
				}
			}
		}
	}

	return len(acs) > 0 ? cfmt.tprint(ansi.CSI, acs, ansi.SGR, fmt, ansi.CSI, ansi.RESET, ansi.SGR, sep = "") : fmt

}


//
//	Parsing procedures and structures for afmt to support input in the form of:
//	- 4bit  -> "-f[fg_color] -b[bg_color] -a[attribute,attribute]"
//	- 8bit  -> "-f[255] -b[0] -a[attribute,attribute]"
//	- 24bit -> "-f[255,0,0] -b[0,0,0] -a[attribute,attribute]"
//


//	Attribute to string look-up-table
//	Enforcing lowercase to avoid regular use of to_upper or to_lower
@(rodata)
attribute := #sparse [Attribute]string {
	.NONE                    = "none",
	.BOLD                    = "bold",
	.FAINT                   = "faint",
	.ITALIC                  = "italic",
	.UNDERLINE               = "underline",
	.BLINK_SLOW              = "blink_slow",
	.BLINK_RAPID             = "blink_rapid",
	.INVERT                  = "invert",
	.HIDE                    = "hide",
	.STRIKE                  = "strike",
	.FONT_PRIMARY            = "font_primary",
	.FONT_ALT1               = "font_alt1",
	.FONT_ALT2               = "font_alt2",
	.FONT_ALT3               = "font_alt3",
	.FONT_ALT4               = "font_alt4",
	.FONT_ALT5               = "font_alt5",
	.FONT_ALT6               = "font_alt6",
	.FONT_ALT7               = "font_alt7",
	.FONT_ALT8               = "font_alt8",
	.FONT_ALT9               = "font_alt9",
	.FONT_FRAKTUR            = "font_fraktur",            // Rarely supported.
	.UNDERLINE_DOUBLE        = "underline_double",        // May be interpreted as "disable bold."
	.NO_BOLD_FAINT           = "no_bold_faint",
	.NO_ITALIC_BLACKLETTER   = "no_italic_blackletter",
	.NO_UNDERLINE            = "no_underline",
	.NO_BLINK                = "no_blink",
	.PROPORTIONAL_SPACING    = "proportional_spacing",
	.NO_REVERSE              = "no_reverse",
	.NO_HIDE                 = "no_hide",
	.NO_STRIKE               = "no_strike",
	.NO_PROPORTIONAL_SPACING = "no_proportional_spacing",
	.FRAMED                  = "framed",                  // Not widely supported.
	.ENCIRCLED               = "encircled",               // Not widely supported.
	.OVERLINED               = "overlined",
	.NO_FRAME_ENCIRCLE       = "no_frame_encircle",
	.NO_OVERLINE             = "no_overline",
}
//	Foreground 4 Bit Color to string look-up-table 
//	Enforcing lowercase to avoid regular use of to_upper or to_lower
@(rodata)
fg_color_4bit := #partial #sparse [FG_Color_4Bit]string {
	.FG_BLACK          = "black",
	.FG_RED            = "red",
	.FG_GREEN          = "green",
	.FG_YELLOW         = "yellow",
	.FG_BLUE           = "blue",
	.FG_MAGENTA        = "magenta",
	.FG_CYAN           = "cyan",
	.FG_WHITE          = "white",
	.FG_DEFAULT        = "default",
	.FG_BRIGHT_BLACK   = "bright_black",
	.FG_BRIGHT_RED     = "bright_red",
	.FG_BRIGHT_GREEN   = "bright_green",
	.FG_BRIGHT_YELLOW  = "bright_yellow",
	.FG_BRIGHT_BLUE    = "bright_blue",
	.FG_BRIGHT_MAGENTA = "bright_magenta",
	.FG_BRIGHT_CYAN    = "bright_cyan",
	.FG_BRIGHT_WHITE   = "bright_white",
}
//	Background 4 Bit Color to string look-up-table
//	Enforcing lowercase to avoid regular use of to_upper or to_lower
@(rodata)
bg_color_4bit := #partial #sparse [BG_Color_4Bit]string {
	.BG_BLACK          = "black",
	.BG_RED            = "red",
	.BG_GREEN          = "green",
	.BG_YELLOW         = "yellow",
	.BG_BLUE           = "blue",
	.BG_MAGENTA        = "magenta",
	.BG_CYAN           = "cyan",
	.BG_WHITE          = "white",
	.BG_DEFAULT        = "default",
	.BG_BRIGHT_BLACK   = "bright_black",
	.BG_BRIGHT_RED     = "bright_red",
	.BG_BRIGHT_GREEN   = "bright_green",
	.BG_BRIGHT_YELLOW  = "bright_yellow",
	.BG_BRIGHT_BLUE    = "bright_blue",
	.BG_BRIGHT_MAGENTA = "bright_magenta",
	.BG_BRIGHT_CYAN    = "bright_cyan",
	.BG_BRIGHT_WHITE   = "bright_white",
}
//	Parses an input string and builds an ANSI_Format struct.
//
//	All parsing done with slicing and no dynamic allocations.
//
//	Input is in the form of:
//	- 3bit	-> Not supported since 4bit makes it redundant
//	- 4bit  -> "-f[bright_blue] -b[black] -a[attribute,attribute]"
//	- 8bit  -> "-f[12] -b[0] -a[attribute,attribute]"
//	- 24bit -> "-f[77, 196, 255] -b[0,0,0] -a[attribute,attribute]"
//
//	Returns: ANSI_Format variant struct based on input string.
afmt_parse :: proc(afmt: string) -> (af: ANSI_Format) {

	aset: bit_set[Attribute]
	
	f4bit: FG_Color_4Bit
	f8bit: Maybe(u8)
	frgb:  RGB
	
	b4bit: BG_Color_4Bit
	b8bit: Maybe(u8)
	brgb:  RGB

	ctype :: enum u8 { c4bit,	c8bit, crgb	}
	cset: bit_set[ctype]

	// attributes
	if at, ok := _parse_option(afmt, "-a"); ok {
		aset = _parse_attributes(at)
	}

	// foreground color
	if fg, ok := _parse_option(afmt, "-f"); ok {
		if frgb, ok = _parse_rgb(fg); ok {
			cset += {.crgb}
		} else if f8bit, ok = _parse_u8(fg); ok {
			cset += {.c8bit}
		} else if _parse_color_4bit(fg, &f4bit) {
			cset += {.c4bit}
		}
	}
		
	// background color
	if bg, ok := _parse_option(afmt, "-b"); ok {
		if brgb, ok = _parse_rgb(bg); ok {			
			cset += {.crgb}
		} else if b8bit, ok = _parse_u8(bg); ok {
			cset += {.c8bit}
		} else if _parse_color_4bit(bg, &b4bit) {
			cset += {.c4bit}
		}
	}
  
	//	- mixed types not allowed - color is ignored if types are mixed
	//	- default to ANSI_4Bit for attributes if no fg or bg
	//	- attributes are independent of colors
	//	- if all fails, return nil
	if card(cset) == 1 {
		switch cset {
		case {.c4bit}:
			af = ANSI_4Bit{ f4bit, b4bit, aset }
		case {.c8bit}:
			af = ANSI_8Bit{ f8bit, b8bit, aset }
		case {.crgb}:
			af = ANSI_24Bit{ frgb, brgb, aset }
		}
	}	else if card(aset) > 0 {
		af = ANSI_4Bit{ at = aset }
	}	else {
		af = nil
	}

	return
}

//	Internal, but not private so can be used if needed/wanted
//	Parse attribute list seperated by ',' and add to bit_set
_parse_attributes :: proc(att: string) -> (aset: bit_set[Attribute]) {
	at := att
	for it in strings.split_iterator(&at, ",") {
		if t := strings.trim_space(it); t != "" {
			loop: for a, id in attribute {
				if a != "" && a == t {
					aset += {id}
					break loop
				}
			}
		}
	}
	return
}

//	Internal, but not private so can be used if needed/wanted
//	Overload: parse 4bit color for either foreground or background colors
_parse_color_4bit :: proc { _parse_fg_color_4bit, _parse_bg_color_4bit }

//	Internal, but not private so can be used if needed/wanted
//	Parse foreground 4bit color - matches string to fg_color_4bit := [FG_Color_4Bit]string
_parse_fg_color_4bit :: proc(c: string, fg: ^FG_Color_4Bit) -> (ok: bool) {
	loop: for f, id in fg_color_4bit {
		if f != "" && f == c {
			fg^ = id
			ok = true
			break loop
		}
	}
	return
}

//	Internal, but not private so can be used if needed/wanted
//	Parse background 4bit color - matches string to bg_color_4bit := [BG_Color_4Bit]string
_parse_bg_color_4bit :: proc(c: string, bg: ^BG_Color_4Bit) -> (ok: bool) {
	loop: for b, id in bg_color_4bit {
		if b != "" && b == c {
			bg^ = id
			ok = true
			break loop
		}
	}
	return	
}

//	Internal, but not private so can be used if needed/wanted
//	Parse u8 color from string 0-255
_parse_u8 :: proc(s: string) -> (u: u8, ok: bool) {
	n, nok := strconv.parse_u64(strings.trim_space(s))
	ok = nok && n >= 0 && n <= 255 ? true : false
	if ok { u = u8(n) }
	return
}

//	Internal, but not private so can be used if needed/wanted
//	Parse rgb delimted as: 'r,g,b'
_parse_rgb :: proc(s: string) -> (rgb: RGB, ok: bool) {
	i := 0
	c := s
	loop: for it in strings.split_iterator(&c, ",") {
		if i > 2 { break loop}
		cu64, cok := strconv.parse_u64(strings.trim_space(it))
		cok = cok && cu64 >= 0 && cu64 <= 255 ? true : false
		if cok { rgb[i] = u8(cu64) }
		i += 1
	}
	ok = rgb.r != nil && rgb.g != nil && rgb.b != nil
	return
}

//	Internal, but not private so can be used if needed/wanted
//	Parse ansi format options that start with '-' and bracketted with '[' ']'
_parse_option :: proc(s, o: string) -> (res: string, found: bool) {
	idx := strings.index(s, o)

	left, right := -1, -1
	if idx >= 0 {
		loop: for i := idx + len(o); i < len(s); i += 1 {
			switch s[i] {
			case '-': // found next option before brackets
				break loop
			case '[': // find left bracket first
				if left == -1 {	left = i }
			case ']': // only if left bracket is found
				if left != -1 {	right = i; break loop }
			}
		}
		if found = left > idx && right > left; found {
			res = strings.trim_space(s[left+1:right])
		}
		if len(res) == 0 { found = false }
	}

	return
}


//
//	Printing procedures
//


//	Internal: Used by all print procedures to look for ansi format in arg[0]
@(private="file")
interogate_args :: proc(args: ..any) -> (ansi: ANSI_Format, found: bool) {
	if len(args) > 0 {
		switch a in args[0] {
		case ANSI_Format: ansi = a; found = true
		case ANSI_24Bit:  ansi = a; found = true
		case ANSI_8Bit:   ansi = a; found = true
		case ANSI_4Bit:   ansi = a; found = true
		case ANSI_3Bit:   ansi = a; found = true
		case string:
			if ansi = afmt_parse(a); ansi != nil {
				found = true
			}
		}
	}
	return
}
//	print formats using the default print settings and writes to os.stdout
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
print :: proc(args: ..any, sep := " ", flush := true) -> int {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.print(f, sep = "", flush = flush)
	}

	return cfmt.print(..args, sep = sep, flush = flush)
}
//	println formats using the default print settings and writes to os.stdout
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
println :: proc(args: ..any, sep := " ", flush := true) -> int {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.println(f, sep = "", flush = flush)
	}

	return cfmt.println(..args, sep = sep, flush = flush)
}
//	printf formats according to the specified format string and writes to os.stdout
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
printf :: proc(fmt: string, args: ..any, flush := true) -> int {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.printf(f, ..args[1:], flush = flush)
	}

	return cfmt.printf(fmt, ..args, flush = flush)
}
//	printfln formats according to the specified format string and writes to os.stdout, followed by a newline.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
printfln :: proc(fmt: string, args: ..any, flush := true) -> int {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.printfln(f, ..args[1:], flush = flush)
	}

	return cfmt.printfln(fmt, ..args, flush = flush)
}
//	Creates a formatted string
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//
//	Returns: A formatted string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
tprint :: proc(args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.tprint(f, sep = "")
	}

	return cfmt.tprint(..args, sep = sep)
}
//	Creates a formatted string with a newline character at the end
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
tprintln :: proc(args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.tprintln(f, sep = "")
	}

	return cfmt.tprintln(..args, sep = sep)
}
//	Creates a formatted string using a format string and arguments
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments.
//	- args: A variadic list of arguments to be formatted.
//	- newline: Whether the string should end with a newline. (See `tprintfln`.)
//
//	Returns: A formatted string with or without ANSI sequence.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
tprintf :: proc(fmt: string, args: ..any, newline := false) -> string {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.tprintf(f, ..args[1:], newline = newline)
	}

	return cfmt.tprintf(fmt, ..args, newline = newline)
}
//	Creates a formatted string using a format string and arguments, followed by a newline.
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments.
//	- args: A variadic list of arguments to be formatted.
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
tprintfln :: proc(fmt: string, args: ..any) -> string {
	return tprintf(fmt, ..args, newline = true)
}
//	Creates a formatted string
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//	- allocator: (default: context.allocator)
//
//	Returns: A formatted string with or without ANSI sequence. 
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
aprint :: proc(args: ..any, sep := " ", allocator := context.allocator) -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.aprint(f, sep = "", allocator = allocator)
	}

	return cfmt.aprint(..args, sep = sep, allocator = allocator)
}
//	Creates a formatted string with a newline character at the end
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//	- allocator: (default: context.allocator)
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end. The returned string must be freed accordingly.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
aprintln :: proc(args: ..any, sep := " ", allocator := context.allocator) -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.aprintln(f, sep = "", allocator = allocator)
	}

	return cfmt.aprintln(..args, sep = sep, allocator = allocator)
}
//	Creates a formatted string using a format string and arguments
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments.
//	- args: A variadic list of arguments to be formatted.
//	- allocator: (default: context.allocator)
//	- newline: Whether the string should end with a newline. (See `aprintfln`.)
//
//	Returns: A formatted string with or without ANSI sequence. The returned string must be freed accordingly.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
aprintf :: proc(fmt: string, args: ..any, allocator := context.allocator, newline := false) -> string {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.aprintf(f, ..args[1:], allocator = allocator, newline = newline)
	}

	return cfmt.aprintf(fmt, ..args, allocator = allocator, newline = newline)
}
//	Creates a formatted string using a format string and arguments, followed by a newline.
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments.
//	- args: A variadic list of arguments to be formatted.
//	- allocator: (default: context.allocator)
//
//	Returns: A formatted string with or without ANSI sequence and with a newline at the end. The returned string must be freed accordingly.
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
aprintfln :: proc(fmt: string, args: ..any, allocator := context.allocator) -> string {
	return aprintf(fmt, ..args, allocator = allocator, newline = true)
}
//	Creates a formatted string using a supplied buffer as the backing array. Writes into the buffer.
//
//	Inputs:
//	- buf: The backing buffer
//	- args: A variadic list of arguments to be formatted
//	- sep: An optional separator string (default is a single space)
//
//	Returns: A formatted string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied ..args[1:]
//	- then is passed on to core:fmt procedure
bprint :: proc(buf: []byte, args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.bprint(buf, ..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.bprint(buf, f, sep = "")
	}

	return cfmt.bprint(buf, ..args, sep = sep)
}
//	Creates a formatted string using a supplied buffer as the backing array, appends newline. Writes into the buffer.
//
//	Inputs:
//	- buf: The backing buffer
//	- args: A variadic list of arguments to be formatted
//	- sep: An optional separator string (default is a single space)
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
bprintln :: proc(buf: []byte, args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.bprint(buf, ..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.bprintln(buf, f, sep = "")
	}

	return cfmt.bprintln(buf, ..args, sep = sep)
}
//	Creates a formatted string using a supplied buffer as the backing array. Writes into the buffer.
//
//	Inputs:
//	- buf: The backing buffer
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//	- newline: Whether the string should end with a newline. (See `bprintfln`.)
//
//	Returns: A formatted string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
bprintf :: proc(buf: []byte, fmt: string, args: ..any, newline := false) -> string {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.bprintf(buf, f, ..args[1:], newline = newline)
	}

	return cfmt.bprintf(buf, fmt, ..args, newline = newline)
}
//	Creates a formatted string using a supplied buffer as the backing array, followed by a newline. Writes into the buffer.
//
//	Inputs:
//	- buf: The backing buffer
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
bprintfln :: proc(buf: []byte, fmt: string, args: ..any) -> string {
	return bprintf(buf, fmt, ..args, newline = true)
}
//	Formats using the default print settings and writes to the given strings.Builder
//
//	Inputs:
//	- buf: A pointer to a strings.Builder to store the formatted string
//	- args: A variadic list of arguments to be formatted
//	- sep: An optional separator string (default is a single space)
//
//	Returns: A formatted string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied ..args[1:]
//	- then is passed on to core:fmt procedure
sbprint :: proc(buf: ^strings.Builder, args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.sbprint(buf, f, sep = "")
	}

	return cfmt.sbprint(buf, ..args, sep = sep)
}
//	Formats and writes to a strings.Builder buffer using the default print settings
//
//	Inputs:
//	- buf: A pointer to a strings.Builder buffer
//	- args: A variadic list of arguments to be formatted
//	- sep: An optional separator string (default is a single space)
//
//	Returns: The resulting formatted string with or without ANSI sequence and with a newline character at the end
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
sbprintln :: proc(buf: ^strings.Builder, args: ..any, sep := " ") -> string {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.sbprintln(buf, f, sep = "")
	}

	return cfmt.sbprintln(buf, ..args, sep = sep)
}
//	Formats and writes to a strings.Builder buffer according to the specified format string
//
//	Inputs:
//	- buf: A pointer to a strings.Builder buffer
//	- fmt: The format string
//	- args: A variadic list of arguments to be formatted
//	- newline: Whether a trailing newline should be written. (See `sbprintfln`.)
//
//	Returns: The resulting formatted string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
sbprintf :: proc(buf: ^strings.Builder, fmt: string, args: ..any, newline := false) -> string {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.sbprintf(buf, f, ..args[1:], newline = newline)
	}

	return cfmt.sbprintf(buf, fmt, ..args, newline = newline)
}
//	Formats and writes to a strings.Builder buffer according to the specified format string, followed by a newline.
//
//	Inputs:
//	- buf: A pointer to a strings.Builder to store the formatted string
//	- fmt: The format string
//	- args: A variadic list of arguments to be formatted
//
//	Returns: A formatted string with or without ANSI sequence and with a newline character at the end
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
sbprintfln :: proc(buf: ^strings.Builder, fmt: string, args: ..any) -> string {
	return sbprintf(buf, fmt, ..args, newline = true)
}
//	Creates a formatted C string
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
ctprint :: proc(args: ..any, sep := " ") -> cstring {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.ctprint(f, sep = "")
	}

	return cfmt.ctprint(..args, sep = sep)
}
//	Creates a formatted C string
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//	- newline: Whether the string should end with a newline. (See `ctprintfln`.)
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
ctprintf :: proc(fmt: string, args: ..any, newline := false) -> cstring {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.ctprintf(f, ..args[1:], newline = newline)
	}

	return cfmt.ctprintf(fmt, ..args, newline = newline)
}
//	Creates a formatted C string, followed by a newline.
//
//	*Allocates Using Context Temporary Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
ctprintfln :: proc(fmt: string, args: ..any) -> cstring {
	return ctprintf(fmt, ..args, newline = true)
}
//	Creates a formatted C string
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- args: A variadic list of arguments to be formatted.
//	- sep: An optional separator string (default is a single space).
//	- allocator: (default: context.allocator)
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to ..args[1:]
//	- then is passed on to core:fmt procedure
@(require_results)
caprint :: proc(args: ..any, sep := " ", allocator := context.allocator) -> cstring {

	if ansi, found := interogate_args(..args); found {
		p := cfmt.tprint(..args[1:], sep = sep)
		f := afmt(ansi, p)
		return cfmt.caprint(f, sep = "", allocator = allocator)
	}

	return cfmt.caprint(..args, sep = sep, allocator = allocator)
}
//	Creates a formatted C string
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//	- allocator: (default: context.allocator)
//	- newline: Whether the string should end with a newline. (See `caprintfln`.)
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
caprintf :: proc(fmt: string, args: ..any, allocator := context.allocator, newline := false) -> cstring {
	
	if ansi, found := interogate_args(..args); found {
		f := afmt(ansi, fmt)
		return cfmt.caprintf(f, ..args[1:], allocator = allocator, newline = newline)
	}

	return cfmt.caprintf(fmt, ..args, allocator = allocator, newline = newline)
}
//	Creates a formatted C string, followed by a newline.
//
//	*Allocates Using Provided Allocator*
//
//	Inputs:
//	- fmt: A format string with placeholders for the provided arguments
//	- args: A variadic list of arguments to be formatted
//	- allocator: (default: context.allocator)
//
//	Returns: A formatted C string with or without ANSI sequence
//
//	If args[0] of ..args contains an ansi format:
//	- the ansi sequence is applied to fmt
//	- then ..args[1:] is passed on to core:fmt procedure
@(require_results)
caprintfln :: proc(fmt: string, args: ..any, allocator := context.allocator) -> cstring {
	return caprintf(fmt, ..args, allocator = allocator, newline = true)
}


//	Utilities


//	Overload: Print to terminal ANSI sequence from ANSI_Format struct or from string containing ANSI sequence
print_raw_ansi :: proc { print_raw_ansi_from_ansiformat, print_raw_ansi_from_string }
//	Print to terminal ANSI sequence string from ANSI_Format struct
print_raw_ansi_from_ansiformat :: proc(a: ANSI_Format) {
	print_raw_ansi_from_string(tprint(a, ""))
}
//	Print to terminal string containing ANSI sequence
print_raw_ansi_from_string :: proc(a: string) {
	for r in a {
		switch r {
		case '\a': print("\\a")
		case '\b': print("\\b")
		case '\e': print("\\e")
		case '\f': print("\\f")
		case '\n': print("\\n")
		case '\r': print("\\r")
		case '\t': print("\\t")
		case '\v': print("\\v")
		case: print(r)
		}
	}
	println()
}