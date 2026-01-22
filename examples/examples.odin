package examples

import "core:strings"

import "shared:tracker"

import "../../afmt"		// replace with location of library
//import "shared:afmt"	// could place afmt folder in the default collection location odin/shared

main :: proc() {

	when ODIN_DEBUG {
		t := tracker.init_tracker()
		context.allocator = tracker.tracking_allocator(&t)
		defer tracker.print_and_destroy_tracker(&t)
	}
	
	afmt.println()
	//	All print procedures in afmt work the same as their respective fmt version when not using ANSI.
	//	If using ANSI, then the ANSI format is the first arg of the ..args variatic parameter for each procedure. i.e. arg[0]
	//	Then the remaining args are passed to the appropriate procedure. i.e. ..args[1:]
	//	There are two ways to define an ANSI format.
	//		1. Using ANSI struct, which has 4 variants. ANSI3, ANSI4, ANSI8, and ANSI24.
	//		2. Using a single string:
	//			ANSI4  -> "-f[blue] -b[black] -a[bold, underline]"
	//			ANSI8  -> "-f[255] -b[50] -a[bold, underline]"
	//			ANSI24 -> "-f[200, 220, 250] -b[0, 0, 0] -a[bold, underline]"
	//
	//	Rules:
	//		- Cannot combine color types between foreground and background in the same ANSI format definition.
	//			i.e. cannot do "-f[blue] -b[0, 0, 0]". This combines 4bit with 24bit.
	//		- Attributes are independant of foreground and background colors and will be applied even if color definitions are invalid.
	//		- Not all fields must be set. Fields not set are ignored, and the terminal will use it's default.
	//
	//	Notes: If you are using a terminal with a custom theme defined when using 3bit, or 4bit, the colors will be converted by your terminal
	//	to the theme's version of those colors. afmt has no control over this. To over-ride themes, use either 8bit or 24bit colors.
	//	afmt applies standard ANSI sequences. The accuracy of output depends on your terminal's support. If an ANSI sequence is not
	//	supported, the terminal should ignore it.

	//
	//	The Basics
	//
{
	//	A variable can be initialized with the top level union, then asigned to a variant.
	//	This can be handy for dynamic assignments
	//	We start by creating a variable with the top level union name ANSI
	//	Then refine it to the specific struct definition of ANSI3 (3Bit)
	ansi: afmt.ANSI
	ansi = afmt.ANSI3 {
  	fg = .FG_BLUE,            // foreground
  	bg = .BG_BLACK,           // background
  	at = {.BOLD, .UNDERLINE}, // atributes
	}
	afmt.println(ansi, "01. Hellope from println using ANSI3")

	//	The same thing using string formatting instead
	afmt.println("-f[blue] -b[black] -a[bold, underline]", "01. Hellope from println using -f[blue] -b[black] -a[bold, underline]")

	afmt.println()

	//	What does the ANSI string look like without the text?
	afmt.print_raw_ansi(ansi)
	//	or with the text?
	aformat_string := afmt.tprint(ansi, "01. Hellope from tprint using ANSI3")
	afmt.print_raw_ansi(aformat_string)
}
	afmt.println()
{
	//	Not all fields are required. Empty fields are ignored.
	ansi := afmt.ANSI4 {
		fg = .FG_BRIGHT_BLUE,
	}
	afmt.println(ansi, "02. Hellope from println using ANSI4")

	//	The same thing using string formatting instead
	afmt.println("-f[bright_blue]", "02. Hellope from println using -f[bright_blue]")
}
	afmt.println()
{
	//	8bit uses 0-255 for colors
	ansi := afmt.ANSI8 {
		fg = 12,
		at = {.ITALIC},
	}
	afmt.println(ansi, "03. Hellope from println using ANSI8")

	//	The same thing using string formatting instead
	afmt.println("-f[12] -a[italic]", "03. Hellope from println using -f[12] -a[italic]")
}
	afmt.println()
{
	//	printf formatting works the same as expected with one exception...
	//	If the first arg in the arg list is an ansi format, that will be used, otherwise,
	//	the procedure acts the same as usual.

	ansi := afmt.ANSI24 {
		fg = afmt.RGB{77, 196, 255}, // ANSI colors can be nil, so a type must be specified
		bg = [3]u8{35, 52, 71},      // afmt.RGB is just an alias for [3]u8
		at = {.UNDERLINE},
	}

	afmt.printfln("%2i. %-8s%-6s%s", ansi, 4, "Hellope", "World", "from printfln using ANSI24")

	//	The same thing using string formatting instead
	afmt.printfln("%2i. %-8s%-6s%s", "-f[77, 196, 255]-b[35, 52, 71]-a[underline]", 4, "Hellope", "World", "from printfln using -f[77, 196, 255]-b[35, 52, 71]-a[underline]")
}
	afmt.println()

	//
	//	Creating useful structures
	//
{
	//	Say we want a format for printing errors and warnings, that excepts dynamic input
	ansi_e := afmt.ANSI4{ fg = .FG_RED }
	ansi_w := afmt.ANSI4{ fg = .FG_YELLOW }

	//	Create an ansi format with color and store %v variable for future use
	error := afmt.tprintf("%s%s", ansi_e, "Error: ", "%v")
	warning := afmt.tprintf("%s%s", ansi_w, "Warning: ", "%v")

	//	Now that we generated the ansi and inserted a %v in the string,
	//	we can use it as the print format for any one variable given.
	afmt.printfln(error, "This is an error message.")
	afmt.printfln(warning, "This is a warning message.")
}
	afmt.println()
{
	//	Do we want to create a format that has 2 different ansi formats in one line?
	ansi01 := afmt.ANSI4{
		fg = .FG_RED,
		at = {.BOLD, .UNDERLINE},
	}
  
	ansi02 := afmt.ANSI4{
		fg = .FG_MAGENTA,
	}

	string01 := afmt.tprint(ansi01, "Error:")
	string02 := afmt.tprint(ansi02, " %v")
	//	Join the strings with afmt.tprintf
	multi_format_error := afmt.tprintf("%s%s", string01, string02)

	//	Now we have a string with 2 different ansi sequences, and a %v inserted to print variable data.
	afmt.printfln(multi_format_error, "This is a multi ansi formated error message.")
}
	afmt.println()
{
	//	aprint works the same as tprint, but allocates dynamic memory
	pf := afmt.aprintf("%2i. %s", "-f[cyan]", 5, "dynamically allocated ansi string using aprintf", allocator = context.allocator)
	afmt.println(pf)
	delete(pf)
}
	afmt.println()
{
	//	bprint also works similar to tprint and aprint, but you give it a backing buffer
	buf: [1024]byte
	res1 := afmt.bprintln(buf[:], "-f[blue]", "06.", "hellope1", "world1", "from bprintln")
	res2 := afmt.bprintln(buf[len(res1):], "-f[green]", "06.", "hellope2", "world2", "from bprintln")
	afmt.print(string(buf[:]))
	//	or
	afmt.print(res1)
	afmt.print(res2)
}
	afmt.println()	
{
	//	sbprint using a strings.Builder
	buf: strings.Builder
	defer strings.builder_destroy(&buf)
	afmt.sbprintln(&buf, "-f[cyan]", "07", "hellope1", "world1", "from sbprintln")
	afmt.sbprintln(&buf, "-f[green]", "07", "hellope2", "world2", "from sbprintln")
	afmt.print(string(buf.buf[:]))
}
	afmt.println()
{
	//	ctprint is like tprint, but returns a cstring instead
	ctemp := afmt.ctprintfln("%2i %s %s %s", "-f[blue]", 8, "hellope", "world", "from ctprintln")
	afmt.print(ctemp)
}
	afmt.println()
{
	//	caprint is like aprint, but returns a dynamically allocated cstring instead
	catemp := afmt.caprintfln("%2i %s %s %s", "-f[blue]", 9, "hellope", "world", "from caprintln")
	afmt.print(catemp)
	delete (catemp)
}
	afmt.println()
{
	//	Don't like using the ANSI struct and prefer the string method,
	//	but want to dynamically define your ansi without string parsing or using strings.concatenate?
	fg := "bright_magenta"
	bg := "black"
	at := "italic,underline"
	pf := afmt.tprintf("-f[%s]-b[%s]-a[%s] %s", fg, bg, at, "%v")
	afmt.println(pf, "10. My dynamically created ansi format using the string method.")
}
	afmt.println()

	//
	//	Now let's get crazy ...
	//	Using afmt to create colorful tables
	//

{
	//	The basic method
	Table :: struct {
		col_label: [4]afmt.ANSI4,
		col_data:  [4]afmt.ANSI4,
		args:      [4]string,
	}

	tbl := Table {
		col_label = {
			{fg = .FG_BLACK, bg = .BG_YELLOW,  at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_GREEN,   at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_BLUE,    at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_MAGENTA, at = {.BOLD}},
		},
		col_data = {
			{fg = .FG_BLACK,   bg = .BG_BRIGHT_YELLOW, at = {.BOLD}},
			{fg = .FG_GREEN,   bg = .BG_BLACK},
			{fg = .FG_BLUE,    bg = .BG_BLACK},
			{fg = .FG_MAGENTA, bg = .BG_BLACK},
		},
		args = { "%-10v", "%-20v", "%-20v", "%-20v" },
	}

	//	Now we can use the ansi and args together to print a table
	afmt.printf(  tbl.args[0], tbl.col_label[0], " table 01")
	afmt.printf(  tbl.args[1], tbl.col_label[1], " column 1")
	afmt.printf(  tbl.args[2], tbl.col_label[2], " column 2")
	afmt.printfln(tbl.args[3], tbl.col_label[3], " column 3")

	afmt.printf(  tbl.args[0], tbl.col_data[0], " row 01")
	afmt.printf(  tbl.args[1], tbl.col_data[1], " column data")
	afmt.printf(  tbl.args[2], tbl.col_data[2], " column data")
	afmt.printfln(tbl.args[3], tbl.col_data[3], " column data")

	afmt.printf(  tbl.args[0], tbl.col_data[0], " row 02")
	afmt.printf(  tbl.args[1], tbl.col_data[1], " column data")
	afmt.printf(  tbl.args[2], tbl.col_data[2], " column data")
	afmt.printfln(tbl.args[3], tbl.col_data[3], " column data")
  
	afmt.printf(  tbl.args[0], tbl.col_data[0], " row 03")
	afmt.printf(  tbl.args[1], tbl.col_data[1], " column data")
	afmt.printf(  tbl.args[2], tbl.col_data[2], " column data")
	afmt.printfln(tbl.args[3], tbl.col_data[3], " column data")

	afmt.printf(  tbl.args[0], tbl.col_data[0], " row 04")
	afmt.printf(  tbl.args[1], tbl.col_data[1], " column data")
	afmt.printf(  tbl.args[2], tbl.col_data[2], " column data")
	afmt.printfln(tbl.args[3], tbl.col_data[3], " column data")
}
	afmt.println()
{
	//	We can make this even easier to use and re-use by doing a little extra work up front
	//	Save the formats into a string with tprintf ...
	Table :: struct {
		col_label: [4]afmt.ANSI4,
		col_data:  [4]afmt.ANSI4,
		args:      [4]string,
	}

	tbl := Table {
		col_label = {
			{fg = .FG_BLACK, bg = .BG_YELLOW,  at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_GREEN,   at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_BLUE,    at = {.BOLD}},
			{fg = .FG_BLACK, bg = .BG_MAGENTA, at = {.BOLD}},
		},
		col_data = {
			{fg = .FG_BLACK,   bg = .BG_BRIGHT_YELLOW, at = {.BOLD}},
			{fg = .FG_GREEN,   bg = .BG_BLACK},
			{fg = .FG_BLUE,    bg = .BG_BLACK},
			{fg = .FG_MAGENTA, bg = .BG_BLACK},
		},
		args = { "%-10v", "%-20v", "%-20v", "%-20v" },
	}

	col_label := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%s", tbl.col_label[0], tbl.args[0]),
		afmt.tprintf("%s", tbl.col_label[1], tbl.args[1]),
		afmt.tprintf("%s", tbl.col_label[2], tbl.args[2]),
		afmt.tprintf("%s", tbl.col_label[3], tbl.args[3]),
	)

	row := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%s", tbl.col_data[0], tbl.args[0]),
		afmt.tprintf("%s", tbl.col_data[1], tbl.args[1]),
		afmt.tprintf("%s", tbl.col_data[2], tbl.args[2]),
		afmt.tprintf("%s", tbl.col_data[3], tbl.args[3]),
	)

	//	Now with the ansi and args saved together in each string,
	//	we can easily print table elements with one-liners.
	afmt.printfln(col_label, " table 02", " column 01", " column 02", " column 03")
	afmt.printfln(row, " row 01", " column data", " column data", " column data")
	afmt.printfln(row, " row 02", " column data", " column data", " column data")
	afmt.printfln(row, " row 03", " column data", " column data", " column data")
	afmt.printfln(row, " row 04", " column data", " column data", " column data")

	afmt.println()

	//	When data is mixed, but still needs to be column-ized, it must be converted to strings
	//	This is true for fmt also, when formating ints, floats, etc.
	
	for r in 0..=4 {
		if r == 0 {
			afmt.printfln(col_label, " table 03", " column 01 title", " column 02 title", " column 03 title")
		} else {
			row_label := afmt.tprintf(" Row %2i", r) // format number to have 2 digits and save as string
			col01 := afmt.tprintf(" column 01 data %2i", r)
			col02 := afmt.tprintf(" column 02 data %2i", r)
			col03 := afmt.tprintf(" column 03 data %2i", r)
			afmt.printfln(row, row_label, col01, col02, col03) // print the whole row
		}
	}
}
	afmt.println()
{
	//	Let's try this another way with string formating and rgb
	col_label := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[0,0,0]-b[167, 168, 009]-a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 194, 113]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 141, 194]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[235, 050, 180]-a[bold]", "%-20s"),
	)

	row := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[000, 000, 000] -b[193, 195, 100] -a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[016, 194, 113] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[016, 141, 194] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[235, 050, 180] -b[000, 000, 000]",          "%-20s"),
	)

	for r in 0..=4 {
		if r == 0 {
			afmt.printfln(col_label, " table 04", " column 01 title", " column 02 title", " column 03 title")
		} else {
			row_label := afmt.tprintf(" Row %2i", r) // format number to have 2 digits and save as string
			col01 := afmt.tprintf(" column 01 data %2i", r)
			col02 := afmt.tprintf(" column 02 data %2i", r)
			col03 := afmt.tprintf(" column 03 data %2i", r)
			afmt.printfln(row, row_label, col01, col02, col03)
		}
	}
}
	afmt.println()
{
	//	There is even an easier way to make tables using some utilities provided by afmt
	//	Width is respected. Input is truncated if it is wider than the column definition.

	//	Create a label row with 4 columns
	label := [4]afmt.Column(afmt.ANSI24) {
		{10, .CENTER, {fg = afmt.black, bg = afmt.khaki,      at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.lightgreen, at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.skyblue,    at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.orchid,     at = {.BOLD}}},
	}
	//	Create a row for data records with 4 columns to match label
	row := [4]afmt.Column(afmt.ANSI24) {
		{10, .CENTER, {fg = afmt.black, bg = afmt.khaki + 15,      at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.lightgreen, bg = afmt.black}},
		{20, .LEFT,   {fg = afmt.skyblue,    bg = afmt.black}},
		{20, .LEFT,   {fg = afmt.orchid,     bg = afmt.black}},
	}

	afmt.printrow(label, "Table 05", " Easiest method", " using utilities", " from afmt")
	afmt.printrow(row, "Row 01", " Hellope", " to all the", " peeps in the world")
	afmt.printrow(row, "Row 02", " To all the", " peeps in the world", " hellope!!!")
	afmt.printrow(row, "Row 03", " Input will be", " truncated if it's too", " long to fit the column")
}

	afmt.println()

	//
	//	Some more advanced things you can do...
	//

{
	//	Let's print a color spectrum bar using hsl to rgb conversion
	//	We will focus on the primary color spectrum - pure red to pure green to pure blue, etc
	//	Start with hue = 0 - This is the variable we will iterate on
	//  Saturation = 1 (100%) and Luminance = 0.5 (50%) are fixed values to get the main colors
	afmt.println("-a[bold]", "24Bit RGB Color Spectrum Bar")
	hsl  := [3]f64{0, 1, .5}
	ansi := afmt.ANSI24{at = {.INVERT}}
	//	Set an iteration factor to something sensible
	//	i.e. greater than 0 and less than 360 (degrees)
	//	Maybe we want 42 colors? Use decimals to enforce precision
	factor := f64(360.000/42.000)
	//	Iterate around the color wheel, excluding 360 at the end to avoid a repeat of first color (done with: hsl[0] <= 360 - factor)
	for hsl[0] = 0; hsl[0] <= 360 - factor; hsl[0] += factor {
		ansi.fg = afmt.hsl(hsl)
		afmt.print(ansi, " ")
	}
	afmt.println()
	//	Note: The same thing from above can be done with:
	//	afmt.print_24bit_color_spectrum_bar(360.000/42.000)

	afmt.println()

	//	What's the hsl value of the last color used from above?
	//	Must use type assertion with '?' since afmt.RGB can be nil
	//	Since we know pf.fg is not nil from our usage above, there is no need to use or_else statement
	rgb := ansi.fg.? /* or_else {0,0,0} */
	afmt.println("HSL of last color:", afmt.hsl(rgb))

	//	There is a color test availible for each bit depth:
	//	afmt.print_3bit_color_test()
	//	afmt.print_4bit_color_test()
	//	afmt.print_8bit_color_test()
	//	afmt.print_8bit_color_spectrum_bar()
	//	afmt.print_24bit_color_spectrum_bar()
}
	afmt.println()
{
	//	Having some fun with the above concept
	text := "O'Doyle ... I mean, Odin rules!!!"
	ansi := afmt.ANSI24{bg = afmt.RGB{0,0,0}, at={.BOLD}}
	hsl  := [3]f64{0, 1, .5}
	hfactor := 360.000/f64(len(text))
	for t in text {
		ansi.fg = afmt.hsl(hsl)
		afmt.print(ansi, t)
		hsl[0] += hfactor
	}
	afmt.println()
}
	afmt.println()
{
	//	Do you prefer using a [3]u8 like structure, but 8bit is not very friendly to the idea?
	//	afmt provides a procedure that allows use of a rgb array with values in the range 0-5
	//	With this, you can use a base-6 rgb value to convert to an u8 value of 16-231.
	//	This is the range of the main colors which forms a 6x6x6 color cube
	//	Warning, it is a little evil...
	ansi: afmt.ANSI8
	rgb := [3]u8{1, 0, 0}
	ansi.bg, _ = afmt.rgb666(rgb)
	afmt.println(ansi, "Adding evil to 8bit with utility rgb666_to_8bit for to do evils...")

	//	Do we want to undo the evil? Or would this be re-evilling? I suppose evil begets evil...
	rgb, _ = afmt.rgb666(ansi.bg.?)
	afmt.println("-f[226]", "Extracting evil from 8Bit using rgb666_from_8bit:", rgb)
}
	afmt.println()
{
	//	8Bit color spectrum bar, similar to the 24bit example above
	//	Note the specialized hsl_rgb666 procedure for base-6 color system
	afmt.println("-a[bold]", "8Bit RGB Color Spectrum Bar")
	hsl666 := [3]f64{0, 1, .5}
	ansi: afmt.ANSI8
	factor666 := f64(360.000/42.000)
	for hsl666[0] = 0; hsl666[0] <= 360 - factor666; hsl666[0] += factor666 {
		rgb666 := afmt.hsl666(hsl666)
		ansi.bg, _ = afmt.rgb666(rgb666)
		afmt.print(ansi, " ")
	}
	afmt.println()
	//	Note: The same thing from above can be done with:
	//	afmt.print_8bit_color_spectrum_bar(360.000/42.000)

	afmt.println()

	// HSL of last color
	rgb666, ok := afmt.rgb666(ansi.bg.?)
	afmt.println("HSL of last color:", afmt.hsl666(rgb666))
}
	afmt.println()
{
	//	Say we want to find the closest match for 8Bit and 24Bit colors
	//	The great thing about HSL, is it can be used to bridge the gap (very large gap) between 8Bit and 24Bit colors
	//	Note, since the gap is very large - 8Bit(216 colors in 6x6x6 color cube) and 24Bit (16_777_216 colors),
	//	this means that often, a converted color will not match your expectations
	//	It should mathmatically be the closest. It's kinda like rounding 1.5 to 2, but 1.499999 rounds to 1
	color24       := afmt.RGB{255, 0, 175}
	hsl_bridge    := afmt.hsl(color24)
	color666      := afmt.hsl666(hsl_bridge)
	color8, valid := afmt.rgb666(color666)

	ansi24 := afmt.ANSI24{fg = color24}
	afmt.println(ansi24, "Original 24Bit Color")
	ansi8 := afmt.ANSI8{fg = color8}
	afmt.println(ansi8, "8Bit color converted from 24Bit color")
}
	afmt.println()
{
	//	Have color decision paralysis because of 16_777_216 options?
	//	Like using named colors similar to HTML?
	//	This only works with ANSI24 structs, not the string format method
	//	That would add too much parsing overhead to the print procedures
	ansi := afmt.ANSI24{fg = afmt.turquoise}
	color_name, c_ok := afmt.color_name_from_value(ansi.fg.?)
	afmt.println(ansi, "Color from name:", color_name)
}
	afmt.println()
{
	//	Relative luminance is handy for determining brightness of a color to the human eye
	//	normalized to 0 for darkest black and 1 for lightest white
	//	It is not the same lumanance value found in hsl
	ansi := afmt.ANSI24{fg = afmt.white, bg = afmt.royalblue}
	afmt.printfln("%-33s%.8f", ansi, "Relative luminance of royalblue: ", afmt.relative_luminance(afmt.royalblue))
	ansi.bg = afmt.indigo
	afmt.printfln("%-33s%.8f", ansi, "Relative luminance of indigo: ", afmt.relative_luminance(afmt.indigo))
}
	afmt.println()
{
	//	Need to determine the contrast ratio of 2 colors to decide which is best to combine?
	//	This results in a value ranging from 1:1 (no contrast at all) to 21:1 (the highest possible contrast)
	ansi := afmt.ANSI24{bg = afmt.orchid, at = {.BOLD}}

	black_ratio := afmt.contrast_ratio(afmt.black, afmt.orchid)
	white_ratio := afmt.contrast_ratio(afmt.white, afmt.orchid)
	
	if black_ratio > white_ratio {
		ansi.fg = afmt.black
	} else {
		ansi.fg = afmt.white
	}

	afmt.printfln("%-33s%.8f", ansi, "white on orchid contrast ratio:", white_ratio)
	afmt.printfln("%-33s%.8f", ansi, "black on orchid contrast ratio:", black_ratio)

}

{
	//	You can print color guides of all the named rgb colors with the following
	//	afmt.print_color_name_guide("all")
	//	afmt.print_color_name_guide("pinks")
	//	afmt.print_color_name_guide("purples")
	//	afmt.print_color_name_guide("blues")
	//	afmt.print_color_name_guide("greens")
	//	afmt.print_color_name_guide("yellows")
	//	afmt.print_color_name_guide("oranges")
	//	afmt.print_color_name_guide("reds")
	//	afmt.print_color_name_guide("grayscale")
}
	afmt.println()

	//	afmt uses context.temp_allocator to build ANSI sequences ...
	//	This is not required, odin will do this for you periodically and when the program exits.
	//	But you may want to do it yourself when appropriate in long running programs.
	//	free_all(context.temp_allocator)

	//	Wow. You made it all the way to the end. Hope you enjoyed this geek out session.

}
