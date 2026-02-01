package afmt //	ANSI Format printing library.

import cfmt "core:fmt" // renamed "c" for core to prevent name collision with "fmt" in procedure definitions
import "core:math"
import "core:strings"
import "core:strconv"
import "core:terminal"
import "core:terminal/ansi"
import "base:intrinsics"


//	Depricated names of structures given aliases for now (temporary)


ANSI_Format   :: ANSI
ANSI_3Bit     :: ANSI3
ANSI_4Bit     :: ANSI4
ANSI_8Bit     :: ANSI8
ANSI_24Bit    :: ANSI24
FG_Color_3Bit :: FGColor3
BG_Color_3Bit :: BGColor3
FG_Color_4Bit :: FGColor4
BG_Color_4Bit :: BGColor4

//	Aliases of all the below structures to help reduce syntax
//	This is here for advanced users who are already familiar with the types


AT  :: Attribute
FG3 :: FGColor3
BG3 :: BGColor3
FG4 :: FGColor4
BG4 :: BGColor4

//	HSL type for hsl procedures
HSL :: [3]f64

//	RGB type for ANSI24 Colors
RGB :: [3]u8

//	Attributes - independent of ANSI variants
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

//	Union variants of ANSI
ANSI :: union {
	ANSI3,
	ANSI4,
	ANSI8,
	ANSI24,
}

//	3 Bit Color data structure - 8 colors
ANSI3 :: struct {
	fg: FGColor3,           // foreground
	bg: BGColor3,           // background
	at: bit_set[Attribute], // attributes
}
//	Foreground 3 Bit Colors
FGColor3 :: enum u8 {
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
BGColor3 :: enum u8 {
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
ANSI4 :: struct {
	fg: FGColor4,           // foreground
	bg: BGColor4,           // background
	at: bit_set[Attribute], // attributes
}
//	Foreground 4 Bit Colors
FGColor4 :: enum u8 {
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
BGColor4 :: enum u8 {
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
ANSI8 :: struct {
	fg: Maybe(u8),          // foreground - u8 or can be nil
	bg: Maybe(u8),          // background - u8 or can be nil
	at: bit_set[Attribute], // attributes
}

//	24 Bit (TrueColor) Color Printing - 16.7 million colors
ANSI24 :: struct {
	fg: Maybe(RGB),         // foreground - {u8, u8, u8} or can be nil
	bg: Maybe(RGB),         // background - {u8, u8, u8} or can be nil
	at: bit_set[Attribute], // attributes
}


//
//	ANSI Control Sequence formatter
//
//	Input:
//	- afmt: ANSI struct containing the defined ANSI sequence to apply to fmt.
//	- fmt: In many cases (not all), a format string with placeholders for the provided print arguments.
//
//	Returns: the fmt string wrapped in the specified ANSI sequence
@(require_results)
afmt :: proc(afmt: ANSI, fmt: string) -> string {
	acs: string // ANSI Control Sequence

	// Delimitor - Specialized for internal use only - assumes acs is also in args[0]
	delimit :: proc(acs: ^string, args: ..any) {
		if len(acs^) == 0 { // exclude acs when it is empty - prevent extra semi-colon
			acs^ = cfmt.tprint(..args[1:], sep = ";")
		} else { // include acs when it is not empty
			acs^ = cfmt.tprint(..args, sep = ";")
		}
	}

	//	Process Attributes independently from colors
	attributes: bit_set[Attribute]
	switch a in afmt {
	case ANSI3:  attributes = a.at
	case ANSI4:  attributes = a.at
	case ANSI8:  attributes = a.at
	case ANSI24: attributes = a.at
	}
	if .NONE not_in attributes {
		for a in attributes {
			delimit(&acs, acs, u8(a))
		}
	}

	// Process ANSI variants
	if terminal.color_enabled {
		switch a in afmt {
		case ANSI3: if terminal.color_depth >= .Three_Bit {
				if a.fg != .NONE {
					delimit(&acs, acs, u8(a.fg))
				}
				if a.bg != .NONE {
					delimit(&acs, acs, u8(a.bg))
				}
			}
		case ANSI4: if terminal.color_depth >= .Four_Bit {
				if a.fg != .NONE {
					delimit(&acs, acs, u8(a.fg))
				}
				if a.bg != .NONE {
					delimit(&acs, acs, u8(a.bg))
				}
			}
		case ANSI8: if terminal.color_depth >= .Eight_Bit {
				if a.fg != nil {
					delimit(&acs, acs, ansi.FG_COLOR_8_BIT, a.fg)
				}
				if a.bg != nil {
					delimit(&acs, acs, ansi.BG_COLOR_8_BIT, a.bg)
				}
			}
		case ANSI24: if terminal.color_depth >= .True_Color {
				if a.fg != nil {
					delimit(&acs, acs, ansi.FG_COLOR_24_BIT, a.fg.(RGB).r, a.fg.(RGB).g, a.fg.(RGB).b)
				}
				if a.bg != nil {
					delimit(&acs, acs, ansi.BG_COLOR_24_BIT, a.bg.(RGB).r, a.bg.(RGB).g, a.bg.(RGB).b)
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
fgcolor4 := #partial #sparse [FGColor4]string {
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
bgcolor4 := #partial #sparse [BGColor4]string {
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
//	Parses an input string and builds an ANSI struct.
//
//	All parsing done with slicing and no dynamic allocations.
//
//	Input is in the form of:
//	- 3bit	-> Not supported since 4bit makes it redundant
//	- 4bit  -> "-f[bright_blue] -b[black] -a[attribute,attribute]"
//	- 8bit  -> "-f[12] -b[0] -a[attribute,attribute]"
//	- 24bit -> "-f[77, 196, 255] -b[0,0,0] -a[attribute,attribute]"
//
//	Returns: ANSI variant struct based on input string.
afmt_parse :: proc(afmt: string) -> (af: ANSI) {

	aset: bit_set[Attribute]
	
	f4bit: FGColor4
	f8bit: Maybe(u8)
	frgb:  Maybe(RGB)
	
	b4bit: BGColor4
	b8bit: Maybe(u8)
	brgb:  Maybe(RGB)

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
	//	- default to ANSI4 for attributes if no fg or bg
	//	- attributes are independent of colors
	//	- if all fails, return nil
	if card(cset) == 1 {
		switch cset {
		case {.c4bit}:
			af = ANSI4{ f4bit, b4bit, aset }
		case {.c8bit}:
			af = ANSI8{ f8bit, b8bit, aset }
		case {.crgb}:
			af = ANSI24{ frgb, brgb, aset }
		}
	}	else if card(aset) > 0 {
		af = ANSI4{ at = aset }
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
_parse_color_4bit :: proc { _parse_fgcolor4, _parse_bgcolor4 }

//	Internal, but not private so can be used if needed/wanted
//	Parse foreground 4bit color - matches string to fg_color_4bit := [FGColor4]string
_parse_fgcolor4 :: proc(c: string, fg: ^FGColor4) -> (ok: bool) {
	loop: for f, id in fgcolor4 {
		if f != "" && f == c {
			fg^ = id
			ok = true
			break loop
		}
	}
	return
}

//	Internal, but not private so can be used if needed/wanted
//	Parse background 4bit color - matches string to bgcolor4 := [BGColor4]string
_parse_bgcolor4 :: proc(c: string, bg: ^BGColor4) -> (ok: bool) {
	loop: for b, id in bgcolor4 {
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
	maybe_u8: [3]Maybe(u8)
	loop: for it in strings.split_iterator(&c, ",") {
		if i > 2 { break loop}
		cu64, cok := strconv.parse_u64(strings.trim_space(it))
		cok = cok && cu64 >= 0 && cu64 <= 255 ? true : false
		if cok { maybe_u8[i] = u8(cu64) }
		i += 1
	}
	ok = maybe_u8.r != nil && maybe_u8.g != nil && maybe_u8.b != nil
	if ok { rgb = RGB{maybe_u8.r.?, maybe_u8.g.?, maybe_u8.b.?} }
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


//	Internal: Used by all print procedures to look for ansi format in args[0]
@(private="file")
interogate_args :: proc(args: ..any) -> (ansi: ANSI, found: bool) {
	if len(args) > 0 {
		switch a in args[0] {
		case ANSI:   ansi = a; found = true
		case ANSI3:  ansi = a; found = true
		case ANSI4:  ansi = a; found = true
		case ANSI8:  ansi = a; found = true
		case ANSI24: ansi = a; found = true
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


//	Shortcut for defining N columns in a row
//
//	Input
//	- typeid of an ANSI variant (ANSI24, ANSI8, ANSI4, or ANSI3)
//
//	Usage Example:
//	- define a row with 2 columns, width 10, justified left, and white foreground text
//		my_row := [2]Column(ANSI24) {
//			{10, .LEFT, {fg = RGB{255, 255, 255}}},
//			{10, .LEFT, {fg = RGB{255, 255, 255}}},
//		}
Column :: struct($V: typeid) where intrinsics.type_is_variant_of(ANSI, V) {
	width:   u8,
	justify: enum {LEFT, CENTER, RIGHT},
	ansi:    V,
}

//	Row printing utility for use with Column struct only
//
//	Print multiple rows of columns
//	- The first slice is rows, and second is columns
//	- i.e. slices[rows][columns]
//
//	Column widths are respected
//	Text is truncated if longer than the width of a column
//
//	Justify to .Center will favor left if padding on left and right is not equal
printrows :: proc(row: [$N]$V/Column, slices: [][]$T) {
	for s in slices {
		printrow(row, s[:])
	}
}

//	Overload: print row by slice or ..any
printrow :: proc {printrow_slice, printrow_any}

//	Row printing utility for use with Column struct only
//
//	Column widths are respected
//	Text is truncated if longer than the width of a column
//
//	Justify to .Center will favor left if padding on left and right is not equal
printrow_slice :: proc(row: [$N]$V/Column, slice: []$T) {
	if len(slice) > 0 {
		for c in 0..<N {
			if c >= len(slice) { break }
			arg := tprint(slice[c])
			if strings.rune_count(arg) >= int(row[c].width) {
				rloop: for _, idx in arg {
					if strings.rune_count(arg[:idx]) >= int(row[c].width) {
						arg = arg[:idx]
						break rloop
					}
				}
			}
			switch row[c].justify {
			case .LEFT:
				printf("%-*v", row[c].ansi, row[c].width, arg)
			case .CENTER:
				delta    := int(row[c].width) - len(arg)
				padleft  := delta % 2 == 1 ? (delta - 1) / 2 : delta / 2
				padright := delta % 2 == 1 ? (delta + 1) / 2 : delta / 2
				printf("%*v%v%*v", row[c].ansi, padleft, "", arg, padright, "")
			case .RIGHT:
				printf("%*v", row[c].ansi, row[c].width, arg)
			}
		}
		println()
	}
}

//	Row printing utility for use with Column struct only
//
//	Column widths are respected
//	Text is truncated if longer than the width of a column
//
//	Justify to .Center will favor left if padding on left and right is not equal
printrow_any :: proc(row: [$N]$V/Column, args: ..any) {
	printrow_slice(row, args[:])
}

//	Overload: Print to terminal ANSI sequence from ANSI struct or from string containing ANSI sequence
print_raw_ansi :: proc { print_raw_ansi_from_ansi_struct, print_raw_ansi_from_string }
//	Print to terminal ANSI sequence string from ANSI struct
print_raw_ansi_from_ansi_struct :: proc(a: ANSI) {
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

//	relative luminance - normalized to 0 for darkest black and 1 for lightest white
//	note: not the same as luminance in hsl
//
//	Input:
//	- rgb = color
//
//	Returns:
//	- relative_luminance of rgb input
relative_luminance ::proc(rgb: RGB) -> (relative_luminance: f64) {
	srgb := [3]f64{f64(rgb.r), f64(rgb.g), f64(rgb.b)} / 255
	srgb[0] = srgb[0] <= 0.04045 ? srgb[0] / 12.920 : math.pow_f64(((srgb[0] + 0.055) / 1.055), 2.400)
	srgb[1] = srgb[1] <= 0.04045 ? srgb[1] / 12.920 : math.pow_f64(((srgb[1] + 0.055) / 1.055), 2.400)
	srgb[2] = srgb[2] <= 0.04045 ? srgb[2] / 12.920 : math.pow_f64(((srgb[2] + 0.055) / 1.055), 2.400)
	relative_luminance = 0.2126 * srgb[0] + 0.7152 * srgb[1] + 0.0722 * srgb[2]
	return
}

//	contrast ratio
//
//	Input:
//	- c1 = RGB color 1
//	- c2 = RGB color 2
//
//	Returns:
//	- contrast ratio of L1:L2 if L1 is brighter
//	- contrast ratio of L2:L1 if L2 is brighter
//
//	Use relative_luminance to determine which color is brighter
//
//	This results in a value ranging from 1:1 (no contrast at all) to 21:1 (the highest possible contrast)
contrast_ratio :: proc(c1, c2: RGB) -> (contrast: f64) {
	L1 := relative_luminance(c1)
	L2 := relative_luminance(c2)
	switch {
	case L1 > L2:  contrast = (L1 + 0.05) / (L2 + 0.05)
	case L1 < L2:  contrast = (L2 + 0.05) / (L1 + 0.05)
	case:          contrast = 1
	}
	return
}

//	Overload: HSL to and from RGB conversion
hsl :: proc {hsl_to_rgb, hsl_from_rgb}

//	Convert hsl to rgb
//
//	Input:
//	- hsl[0] = hue in degrees
//	- hsl[1] = saturation (0-1) in percent where 1 == 100%
//	- hsl[2] = luminance  (0-1) in percent where 1 == 100%
//
//	Input Normalization:
//	- if hue < 0 || hue > 360 then it is converted to corresponding degree in range 0-360
//	- if saturation < 0 || luminance < 0 then they are converted to positive respectively
//	- if saturation > 1 || luminance > 1 then they are assumed to be 1 (i.e. 100%) respectively
//
//	Returns:
//	- rgb = {0-255, 0-255, 0-255}
hsl_to_rgb :: proc(hsl: HSL) -> (rgb: RGB) {
	rnd :: math.round
	_hsl := hsl

	// No saturation, which means rgb is gray, so apply luminance and return
	if _hsl[1] == 0 {
		rgb = {u8(rnd(_hsl[2] * 255)), u8(rnd(_hsl[2] * 255)), u8(rnd(_hsl[2] * 255))}
		return rgb
	}

	// Normalize input
	if _hsl[0] < 0     { for _hsl[0] < 0   { _hsl[0] += 360 } }
	if _hsl[0] > 360   { for _hsl[0] > 360 { _hsl[0] -= 360 } }
	if _hsl[1] < 0     { _hsl[1] *= -1.000 }
	if _hsl[1] > 1.000 { _hsl[1] =   1.000 }
	if _hsl[2] < 0     { _hsl[2] *= -1.000 }
	if _hsl[2] > 1.000 { _hsl[2] =   1.000 }

	// Begin maths...
	rgbf64 := [3]f64 {(_hsl[0]/360.000) + 0.3333333333333333, _hsl[0]/360.000, (_hsl[0]/360.000) - 0.3333333333333333}
	sl1    := _hsl[2] < 0.500 ? _hsl[2] * (1.000 + _hsl[1]) : _hsl[2] + _hsl[1] - (_hsl[2] * _hsl[1])
	sl2    := (2 * _hsl[2]) - sl1

	for _, i in rgbf64 {
		rgbf64[i] = rgbf64[i] < 0 ? rgbf64[i] + 1 : rgbf64[i] > 1 ? rgbf64[i] - 1 : rgbf64[i]
		switch {
		case 6*rgbf64[i] < 1.000: rgbf64[i] = sl2 + ((sl1 - sl2) * 6 * rgbf64[i])
		case 2*rgbf64[i] < 1.000: rgbf64[i] = sl1
		case 3*rgbf64[i] < 2.000: rgbf64[i] = sl2 + ((sl1 - sl2) * (0.6666666666666666 - rgbf64[i]) * 6)
		case:                     rgbf64[i] = sl2
		}
	}

	rgb = { u8(rnd(rgbf64.r * 255)), u8(rnd(rgbf64.g * 255)), u8(rnd(rgbf64.b * 255)) }
	return
}

//	Convert rgb to hsl
//
//	Input:
//	- rgb = {0-255, 0-255, 0-255}
//
//	Returns:
//	- hsl[0] = hue (0-360) in degrees
//	- hsl[1] = saturation (0-1) in percent where 1 == 100%
//	- hsl[2] = luminance (0-1) in percent where 1 == 100%
hsl_from_rgb :: proc(rgb: RGB) -> (hsl: HSL) {
	// Convert rgb to 0:1 range
	rgbf64 := [3]f64{f64(rgb.r), f64(rgb.g), f64(rgb.b)} / 255

	// Find max and min with mega-trinaries - I love these. Sorry if you do not ...
	max := rgbf64.r >= rgbf64.g ? (rgbf64.r >= rgbf64.b ? rgbf64.r : rgbf64.b) : (rgbf64.g >= rgbf64.b ? rgbf64.g : rgbf64.b)
	min := rgbf64.r <= rgbf64.g ? (rgbf64.r <= rgbf64.b ? rgbf64.r : rgbf64.b) : (rgbf64.g <= rgbf64.b ? rgbf64.g : rgbf64.b)

	// Luminance
	hsl[2] = (max + min) / 2

	// Saturation
	switch {
	case max == min:      hsl[1] = 0
	case hsl[2] <= 0.500: hsl[1] = (max - min) / (max + min)
	case:                 hsl[1] = (max - min) / (2.000 - max - min)
	}

	// Hue
	if hsl[1] != 0 { // Hue is 0 degrees if there is no saturation (i.e. hsl[0] stays initialized as 0)
		switch max {
		case rgbf64.r: hsl[0] = ((rgbf64.g - rgbf64.b) / (max - min)) * 60
		case rgbf64.g: hsl[0] = ((rgbf64.b - rgbf64.r) / (max - min) + 2.000) * 60
		case rgbf64.b: hsl[0] = ((rgbf64.r - rgbf64.g) / (max - min) + 4.000) * 60
		}
		if hsl[0] < 0 { hsl[0] += 360.000 }
	}

	return
}

//	Overload for HSL to and from Base6 [3]u8
hsl666 :: proc {hsl_to_rgb666, hsl_from_rgb666}

//	Convert hsl to rgb
//
//	Input:
//	- hsl[0] = hue in degrees
//	- hsl[1] = saturation (0-1) in percent where 1 == 100%
//	- hsl[2] = luminance  (0-1) in percent where 1 == 100%
//
//	Input Normalization:
//	- if hue < 0 || hue > 360 then it is converted to corresponding degree in range 0-360
//	- if saturation < 0 || luminance < 0 then they are converted to positive respectively
//	- if saturation > 1 || luminance > 1 then they are assumed to be 1 (i.e. 100%) respectively
//
//	Returns:
//	- rgb = {0-5, 0-5, 0-5}
hsl_to_rgb666 :: proc(hsl: HSL) -> (rgb: [3]u8) {
	rnd :: math.round
	_hsl := hsl

	// No saturation, which means rgb is gray, so apply luminance and return
	if _hsl[1] == 0 {
		rgb = {u8(rnd(_hsl[2] * 255) / 51), u8(rnd(_hsl[2] * 255) / 51), u8(rnd(_hsl[2] * 255) / 51)}
		return rgb
	}

	// Normalize input
	if _hsl[0] < 0     { for _hsl[0] < 0   { _hsl[0] += 360 } }
	if _hsl[0] > 360   { for _hsl[0] > 360 { _hsl[0] -= 360 } }
	if _hsl[1] < 0     { _hsl[1] *= -1.000 }
	if _hsl[1] > 1.000 { _hsl[1] =   1.000 }
	if _hsl[2] < 0     { _hsl[2] *= -1.000 }
	if _hsl[2] > 1.000 { _hsl[2] =   1.000 }

	// Begin maths...
	rgbf64 := [3]f64 {(_hsl[0]/360.000) + 0.3333333333333333, _hsl[0]/360.000, (_hsl[0]/360.000) - 0.3333333333333333}
	sl1    := _hsl[2] < 0.500 ? _hsl[2] * (1.000 + _hsl[1]) : _hsl[2] + _hsl[1] - (_hsl[2] * _hsl[1])
	sl2    := (2 * _hsl[2]) - sl1

	for _, i in rgbf64 {
		rgbf64[i] = rgbf64[i] < 0 ? rgbf64[i] + 1 : rgbf64[i] > 1 ? rgbf64[i] - 1 : rgbf64[i]
		switch {
		case 6*rgbf64[i] < 1.000: rgbf64[i] = sl2 + ((sl1 - sl2) * 6 * rgbf64[i])
		case 2*rgbf64[i] < 1.000: rgbf64[i] = sl1
		case 3*rgbf64[i] < 2.000: rgbf64[i] = sl2 + ((sl1 - sl2) * (0.6666666666666666 - rgbf64[i]) * 6)
		case:                     rgbf64[i] = sl2
		}
	}

	//	first multiply 255 and round, then divide by 51 (1/5 of 255) without rounding and allow truncation
	//	this imposes a bias towards black, which seems less than the bias towards white when mulitplying by 5
	rgb = { u8(rnd(rgbf64.r * 255) / 51), u8(rnd(rgbf64.g * 255) / 51), u8(rnd(rgbf64.b * 255) / 51) }
	//rgb = { u8(rnd(rgbf64.r * 5)), u8(rnd(rgbf64.g * 5)), u8(rnd(rgbf64.b * 5)) }
	return
}

//	Convert rgb to hsl
//
//	Input:
//	- rgb = {0-5, 0-5, 0-5}
//	- values will be rolled over if greater than five (rgb = rgb % 6)
//
//	Returns:
//	- hsl[0] = hue (0-360) in degrees
//	- hsl[1] = saturation (0-1) in percent where 1 == 100%
//	- hsl[2] = luminance (0-1) in percent where 1 == 100%
hsl_from_rgb666 :: proc(rgb: [3]u8) -> (hsl: HSL) {
	// Max value is 5. Roll over value if above 5
	_rgb := rgb % 6
	// Convert rgb to 0:1 range
	rgbf64 := [3]f64{f64(_rgb.r), f64(_rgb.g), f64(_rgb.b)} / 5

	// Find max and min with mega-trinaries - I love these. Sorry if you do not ...
	max := rgbf64.r >= rgbf64.g ? (rgbf64.r >= rgbf64.b ? rgbf64.r : rgbf64.b) : (rgbf64.g >= rgbf64.b ? rgbf64.g : rgbf64.b)
	min := rgbf64.r <= rgbf64.g ? (rgbf64.r <= rgbf64.b ? rgbf64.r : rgbf64.b) : (rgbf64.g <= rgbf64.b ? rgbf64.g : rgbf64.b)

	// Luminance
	hsl[2] = (max + min) / 2

	// Saturation
	switch {
	case max == min:      hsl[1] = 0
	case hsl[2] <= 0.500: hsl[1] = (max - min) / (max + min)
	case:                 hsl[1] = (max - min) / (2.000 - max - min)
	}

	// Hue
	if hsl[1] != 0 { // Hue is 0 degrees if there is no saturation (i.e. hsl[0] stays initialized as 0)
		switch max {
		case rgbf64.r: hsl[0] = ((rgbf64.g - rgbf64.b) / (max - min)) * 60
		case rgbf64.g: hsl[0] = ((rgbf64.b - rgbf64.r) / (max - min) + 2.000) * 60
		case rgbf64.b: hsl[0] = ((rgbf64.r - rgbf64.g) / (max - min) + 4.000) * 60
		}
		if hsl[0] < 0 { hsl[0] += 360.000 }
	}

	return
}

//	Overload for to and from Base6 [3]u8 to 8Bit
rgb666 :: proc {rgb666_to_8bit, rgb666_from_8bit}

//	Convert rgb value with range 0-5 (6x6x6 color cube) to 8bit color 16-231
//	Excludes system colors 0-15 and grayscale 232-255
//	valid is true if rgb values not truncated from 5 (i.e. rolled over)
rgb666_to_8bit :: proc(rgb666: [3]u8) -> (color: u8, valid: bool) #optional_ok {
	_rgb666 := rgb666
	truncated: bool
	for c, i in _rgb666 {
		if c > 5 {
			_rgb666[i] %= 6
		}
		truncated = true
	}
	valid = !truncated
	//	Base-6 to u8 conversion +16 since main colors are 16-231
	color = (_rgb666.r * 36) + (_rgb666.g * 6) + _rgb666.b + 16
	return
}

//	Convert 8bit color 16-231 to rgb value with range 0-5 (6x6x6 color cube)
//	If system colors 0-15 or grayscale 232-255 is provided, the closest match is returned
//	with valid set to false if it is not an exact match
rgb666_from_8bit :: proc(color: u8) -> (rgb666: [3]u8, valid: bool) #optional_ok {
	_color := color
	if color < 16 || color > 231 {
		switch color {
		case  0: return {0,0,0}, true  // 016 - exact match
		case  1: return {2,0,0}, false // 088 - closest match
		case  2: return {0,2,0}, false // 028 - closest match
		case  3: return {2,2,0}, false // 100 - closest match
		case  4: return {0,0,2}, false // 018 - closest match
		case  5: return {2,0,2}, false // 090 - closest match
		case  6: return {0,2,2}, false // 030 - closest match
		case  7: return {4,4,4}, false // 188 - closest match
		case  8: return {2,2,2}, false // 102 - closest match
		case  9: return {5,0,0}, true  // 196 - exact match
		case 10: return {0,5,0}, true  // 046 - exact match
		case 11: return {5,5,0}, true  // 226 - exact match
		case 12: return {0,0,5}, true  // 021 - exact match
		case 13: return {5,0,5}, true  // 201 - exact match
		case 14: return {0,5,5}, true  // 051 - exact match
		case 15: return {5,5,5}, true  // 231 - exact match
		case 232..=255: // grays closest match
			_color = ((color - 232) * 10) + 8 
			hsl := hsl_from_rgb(RGB{_color, _color, _color}) // slight bias towards black
			return hsl_to_rgb666(hsl), false
		}
	}

	//	6x6x6 color cube starts at 16. Normalize so first color is = {0,0,0} then treat as base 6 number
	_color -= 16

	//	After subtracting 16, 215 is the highest decimal value for a base-6, 3 digit number i.e. {5,5,5}
	for i := 2; _color != 0; i -= 1 {
		rgb666[i] = _color % 6
		_color /= 6
	}

	return rgb666, true
}

//	Print to terminal 3Bit color test
print_3bit_color_test :: proc(background := true) {
	ansi := ANSI3{at = {.BOLD}}
	if background { ansi.at += {.INVERT} }

	println("-a[bold]", "\n3Bit Colors")
	for c := 30; c <= 37; c += 1 {
		ansi.fg = FGColor3(c)
		// using fgcolor4 to get string name since they are the same in this case
		printfln(" %-7s ", ansi, fgcolor4[FGColor4(c)])
	}
	println()
}

//	Print to terminal 4Bit color test
print_4bit_color_test :: proc(background := true) {
	ansi := ANSI4{at = {.BOLD}}
	if background { ansi.at += {.INVERT} }

	println("-a[bold]", "\n4Bit Colors")
	for c := 30; c <= 37; c += 1 {
		ansi.fg = FGColor4(c)
		printf(" %-7s ", ansi, fgcolor4[ansi.fg])
		ansi.fg = FGColor4(c + 60)
		printfln(" %-14s ", ansi, fgcolor4[ansi.fg])
	}
	println()
}

//	Iterate rgb 6x6x6 color wheel by input factor and print bar
//	If factor == 0, then it is set to default 4.5 (80 colors)
//	If factor is greater than 360, it is set to 360 (i.e. 1 color)
print_8bit_color_spectrum_bar :: proc(factor := f64(7.5)) {
	hsl := [3]f64{0, 1, .5}
	f   := factor == 0 ? 4.5 : factor > 360 ? 360 : factor

	ansi: ANSI8
	for hsl[0] = 0; hsl[0] <= 360 - f; hsl[0] += f {
		ansi.bg, _ = rgb666(hsl666(hsl))
		print(ansi, " ")
	}
	println()
}

//	Print to terminal 8Bit color test
print_8bit_color_test :: proc(background := true) {
	ansi := ANSI8{at = {.BOLD}}
	if background { ansi.at += {.INVERT} }

	println("-a[bold]", "\n8Bit System Colors")
	for c in 0..=15 {
		ansi.fg = u8(c)
		_ = c == 7 || c == 15 ? printfln(" %3i ", ansi, c) : printf(" %3i ", ansi, c)
	}

	println("-a[bold]", "\n8Bit Color Cube 6x6x6")
	rgb: [3]u8
	for rgb.g = 0; rgb.g < 6; rgb.g += 1 {
		for rgb.r = 0; rgb.r < 3; rgb.r += 1 {
			for rgb.b = 0; rgb.b < 6; rgb.b += 1 {
				ansi.fg, _ = rgb666(rgb)
				_ = rgb.rb != {2,5} ? printf(" %3i ", ansi, ansi.fg) : printfln(" %3i ", ansi, ansi.fg)
			}
		}
	}
	for rgb.g = 0; rgb.g < 6; rgb.g += 1 {
		for rgb.r = 3; rgb.r < 6; rgb.r += 1 {
			for rgb.b = 0; rgb.b < 6; rgb.b += 1 {
				ansi.fg, _ = rgb666(rgb)
				_ = rgb.rb != {5,5} ? printf(" %3i ", ansi, ansi.fg) : printfln(" %3i ", ansi, ansi.fg)
			}
		}
	}

	println("-a[bold]", "\n8Bit Grayscale")
	for g in 232..=255 {
		ansi.fg = g <= 243 ? u8(g) : 255 - (u8(g) - 244)
		_ = g != 243 && g != 255 ? printf(" %3i ", ansi, ansi.fg) : printfln(" %3i ", ansi, ansi.fg)
	}
	println()
}

//	Iterate rgb color wheel by input factor and print bar
//	If factor == 0, then it is set to default 4.5 (80 colors)
//	If factor is greater than 360, it is set to 360 (i.e. 1 color)
print_24bit_color_spectrum_bar :: proc(factor := f64(7.5)) {
	_hsl := [3]f64{0, 1, .5}
	f   := factor == 0 ? 4.5 : factor > 360 ? 360 : factor

	ansi: ANSI24
	//println("-a[bold]", "RGB Color Spectrum Bar")
	for _hsl[0] = 0; _hsl[0] <= 360 - f; _hsl[0] += f {
		ansi.bg = hsl(_hsl)
		print(ansi, " ")
	}
	println()
}

//	Print to terminal 24Bit color test
//	If factor is less than 8, then set it to 8
//
//	Brute force method of iterating color wheel
//	Saving as reference for debugging hsl_rgb if needed
//	The following should produce the same spectrum bars, respectively:
//
//	- afmt.print_24bit_color_spectrum_bar(30)
//	- afmt.print_24bit_color_test(128)
//
//	- afmt.print_24bit_color_spectrum_bar(15)
//	- afmt.print_24bit_color_test(64)
//
//	- afmt.print_24bit_color_spectrum_bar(7.5)
//	- afmt.print_24bit_color_test(32)
//
//	- afmt.print_24bit_color_spectrum_bar(3.75)
//	- afmt.print_24bit_color_test(16)
//
print_24bit_color_test :: proc(factor := u8(64)) {
	ansi := ANSI24{fg = RGB{0,0,0}, at = {.INVERT}}
	rgb: [3]int //	have to use int, for loops will type overflow on u8 when max is 255
	f := factor < 8 ? 8 : int(factor)

	for rgb = {255, 0, 0}; rgb.g <= 255; rgb.g += rgb.g == 0 ? f - 1 : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	for rgb = {255 - f, 255, 0}; rgb.r >= 0; rgb.r -= rgb.r != 0 && rgb.r < f ? rgb.r : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	for rgb = {0, 255, f - 1}; rgb.b <= 255; rgb.b += rgb.b == 0 ? f - 1 : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	for rgb = {0, 255 - f, 255}; rgb.g >= 0; rgb.g -= rgb.g != 0 && rgb.g < f ? rgb.g : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	for rgb = {f - 1, 0, 255}; rgb.r <= 255; rgb.r += rgb.r == 0 ? f - 1 : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	for rgb = {255, 0, 255 - f}; rgb.b >= f - 1; rgb.b -= rgb.b != 0 && rgb.b < f ? rgb.b : f {
		ansi.fg = RGB{u8(rgb.r), u8(rgb.g), u8(rgb.b)}
		print(ansi, " ")
	}
	println()
}
