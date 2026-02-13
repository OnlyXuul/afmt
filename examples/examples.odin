package examples

import "core:strings"

import "../../afmt"		// replace with location of library
//import "shared:afmt"	// could place afmt folder in the default collection location odin/shared

main :: proc() {

	afmt.println()
	//	All print procedures in afmt work the same as their respective fmt version when not using ANSI.
	//	If using ANSI, then the ANSI format is the first arg of the ..args variatic parameter for each procedure. i.e. arg[0]
	//	Then the remaining args are passed to the appropriate procedure. i.e. ..args[1:]
	//	There are two ways to define an ANSI format.
	//		1. Using ANSI struct, which has 4 variants. ANSI3, ANSI4, ANSI8, and ANSI24.
	//		2. Using a single string:
	//			ANSI4  -> "-f[blue] -b[black] -a[bold, underline]"
	//			ANSI8  -> "-f[255] -b[50] -a[bold, underline]"
	//			ANSI24 -> 3 ways
	//				- "-f[200, 220, 250] -b[0, 0, 0] -a[bold, underline]" // r, g, b
	//				- "-f[#ff00ff] -b[#000000] -a[bold, underline]"       // hex prefixed with #. i.e. #RRGGBB
	//				- "-f[#orchid] -b[#black] -a[bold, underline]"        // predefined rgb color name found in colors.odin
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
		col_title: [4]afmt.ANSI4,
		col_data:  [4]afmt.ANSI4,
		args:      [4]string,
	}

	tbl := Table {
		col_title = {
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

	title := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%s", tbl.col_title[0], tbl.args[0]),
		afmt.tprintf("%s", tbl.col_title[1], tbl.args[1]),
		afmt.tprintf("%s", tbl.col_title[2], tbl.args[2]),
		afmt.tprintf("%s", tbl.col_title[3], tbl.args[3]),
	)

	cols := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%s", tbl.col_data[0], tbl.args[0]),
		afmt.tprintf("%s", tbl.col_data[1], tbl.args[1]),
		afmt.tprintf("%s", tbl.col_data[2], tbl.args[2]),
		afmt.tprintf("%s", tbl.col_data[3], tbl.args[3]),
	)

	//	Now with the ansi and args saved together in each string,
	//	we can easily print table elements with one-liners.
	afmt.printfln(title, " table 02", " column 01", " column 02", " column 03")
	afmt.printfln(cols, " row 01", " column data", " column data", " column data")
	afmt.printfln(cols, " row 02", " column data", " column data", " column data")
	afmt.printfln(cols, " row 03", " column data", " column data", " column data")
	afmt.printfln(cols, " row 04", " column data", " column data", " column data")

	afmt.println()

	//	When data is mixed, but still needs to be column-ized, it must be converted to strings
	//	This is true for fmt also, when formating ints, floats, etc.
	
	for r in 0..=4 {
		if r == 0 {
			afmt.printfln(title, " table 03", " column 01 title", " column 02 title", " column 03 title")
		} else {
			row_label := afmt.tprintf(" Row %2i", r) // format number to have 2 digits and save as string
			col01 := afmt.tprintf(" column 01 data %2i", r)
			col02 := afmt.tprintf(" column 02 data %2i", r)
			col03 := afmt.tprintf(" column 03 data %2i", r)
			afmt.printfln(cols, row_label, col01, col02, col03) // print the whole row
		}
	}
}
	afmt.println()
{
	//	Let's try this another way with string formating and rgb
	cols_title := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[0,0,0]-b[167, 168, 009]-a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 194, 113]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 141, 194]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[235, 050, 180]-a[bold]", "%-20s"),
	)

	cols_data := afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[000, 000, 000] -b[193, 195, 100] -a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[016, 194, 113] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[016, 141, 194] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[235, 050, 180] -b[000, 000, 000]",          "%-20s"),
	)

	for r in 0..=4 {
		if r == 0 {
			afmt.printfln(cols_title, " table 04", " column 01 title", " column 02 title", " column 03 title")
		} else {
			row_label := afmt.tprintf(" Row %2i", r) // format number to have 2 digits and save as string
			col01 := afmt.tprintf(" column 01 data %2i", r)
			col02 := afmt.tprintf(" column 02 data %2i", r)
			col03 := afmt.tprintf(" column 03 data %2i", r)
			afmt.printfln(cols_data, row_label, col01, col02, col03)
		}
	}
}
	afmt.println()
{
	//	There is even an easier way to make tables using some utilities provided by afmt
	//	Width is respected. Input is truncated if it is wider than the column definition.

	//	Create a label row with 4 columns
	cols_title := [4]afmt.Column(afmt.ANSI24) {
		{10, .CENTER, {fg = afmt.black, bg = afmt.khaki,      at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.lightgreen, at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.skyblue,    at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.black, bg = afmt.orchid,     at = {.BOLD}}},
	}
	//	Create a row for data records with 4 columns to match label
	cols_data := [4]afmt.Column(afmt.ANSI24) {
		{10, .CENTER, {fg = afmt.black,      bg = afmt.khaki + 15, at = {.BOLD}}},
		{20, .LEFT,   {fg = afmt.lightgreen, bg = afmt.black}},
		{20, .LEFT,   {fg = afmt.skyblue,    bg = afmt.black}},
		{20, .LEFT,   {fg = afmt.orchid,     bg = afmt.black}},
	}

	afmt.printrow(cols_title, "Table 05", " Easiest method", " using utilities", " from afmt")
	afmt.printrow(cols_data, "Row 01", " Hellope", " to all the", " peeps in the world")
	afmt.printrow(cols_data, "Row 02", " To all the", " peeps in the world", " hellope!!!")
	afmt.printrow(cols_data, "Row 03", " Input will be", " truncated if it's too", " long to fit the column")
}

afmt.println()

{
	//	Say we wanted to print a whole table of data all at once
	//	printtable supports both 1D and 2D types
	//	1D is treated as a single row, and 2D as multiple rows
	//	There is also an optional parameter to specific precision which only applies to floats

	cols_label := [4]afmt.Column(afmt.ANSI24) {0..<4 = {8, .CENTER, {fg = afmt.blue, at = {.BOLD, .UNDERLINE}}}}
	cols_data  := [4]afmt.Column(afmt.ANSI24) {0..<4 = {8, .CENTER, {fg = afmt.green}}}

	label := [4]string{"x", "y", "z", "w"}
	data  := [4][4]f32 {
		{42, 43, 44, 45},
		{41, 42, 43, 44},
		{40, 41, 42, 43},
		{39, 40, 41, 42},
	}

	afmt.printtable(cols_label, label)
	afmt.printtable(cols_data, data, precision = 2)

}

	afmt.println()

{
	//	A bit of geeking out for funs. Playing around with possibilities...
	symbol := [11]string{"", "☉", "☿", "♀","♁", "♂", "♃", "♄", "♅", "♆", "♇"}
	
	solar_system := [11][]string{
		{" Objects", "", "10^24 kg ",  "Radius km ", "9.87 m/s^2 ", "To Sol km "},
		{" Sol",     "", "1,988,000 ", "695,700 ",   "27.94 ",      "0 ",},
		{" Mercury", "", "0.330103 ",  "2,440 ",     "0.38 ",       "57,910,000 "},
		{" Venus",   "", "4.86731 ",   "6051 ",      "0.90 ",       "108,200,000 "},
		{" Earth",   "", "5.97217 ",   "6371 ",      "1.00 ",       "149,600,000 "},
		{" Mars",    "", "0.641691 ",  "3389 ",      "0.38 ",       "227,900,000 "},
		{" Jupiter", "", "1898.125 ",  "69,911 ",    "2.53 ",       "778,500,000 "},
		{" Saturn",  "", "568.317 ",   "58,232 ",    "1.07 ",       "1,429,000,000 "},
		{" Uranus",  "", "86.8099 ",   "25,362 ",    "0.89 ",       "2,871,000,000 "},
		{" Neptune", "", "102.4092 ",  "24,622 ",    "1.14 ",       "4,495,000,000 "},
		{" Pluto",   "", "0.01303 ",   "1188 ",      "0.06 ",       "5,906,000,000 "},
	}

	rows := [11]afmt.ANSI24 {
		{afmt.orchid+10, afmt.black, {.UNDERLINE, .OVERLINED}}, // title
		{afmt.RGB{255, 222, 033}, afmt.black+15, {}}, // Sol
		{afmt.RGB{169, 169, 169}, afmt.black+15, {}}, // Mercury
		{afmt.RGB{255, 199, 074}, afmt.black+15, {}}, // Venus
		{afmt.RGB{000, 152, 204}, afmt.black+15, {}}, // Earth
		{afmt.RGB{219, 037, 032}, afmt.black+15, {}}, // Mars
		{afmt.RGB{255, 165, 000}, afmt.black+15, {}}, // Jupiter
		{afmt.RGB{246, 234, 147}, afmt.black+15, {}}, // Saturn
		{afmt.RGB{064, 224, 208}, afmt.black+15, {}}, // Uranus
		{afmt.RGB{093, 126, 247}, afmt.black+15, {}}, // Neptune
		{afmt.RGB{208, 180, 158}, afmt.black+15, {}}, // Pluto
	}

	cols := [6]afmt.Column(afmt.ANSI24) {
		{10, .LEFT,  {}}, {01, .LEFT,  {}}, {12, .RIGHT, {}},
		{11, .RIGHT, {}}, {12, .RIGHT, {}}, {15, .RIGHT, {}},
	}

	for s in 0..<len(solar_system) {
		solar_system[s][1] = symbol[s]
		//	apply a different color for each row that corrisponds to the planet
		for &c in cols {
			c.ansi = rows[s]
		}
		afmt.printrow(cols, solar_system[s])
		// printtable would also work for printing a single row at a time when giving it an index
		// note: printtable can also print an entire 2d slice, array, or dynamic array all at once
		// we did not use it here, because I wanted to loop through and apply different colors to each row
		//afmt.printtable(cols, solar_system[s])
	}
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
	//	This only works with ANSI24
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
{
	//	Can also set a persistant ANSI format and then reset
	afmt.set("-f[blue]")
	afmt.println("All other lines from this point will be the same ANSI format ...")
	afmt.println("... until we reset")
	//	Read the comments for reset() to learn about best practices
	afmt.reset()
	afmt.println("All ANSI now reset.")
}
	afmt.println()
{
	//	Some new features to show off
	//	ANSI24 can now be applied used the string method in 3 different ways. All interchangeable.
	afmt.println("-f[255,0,0]", "Printed using -f[255,0,0]")
	afmt.println("-f[#FF0000]", "Printed using -f[#FF0000]")
	//	This last one requires the name to be prefixed with # to distinguish it from ANSI4
	//	Color names can be reference in colors.odin or afmt.print_color_name_guide("all")
	afmt.println("-f[#crimson]", "Printed using -f[#crimson]")
}
	afmt.println()
	//	afmt uses context.temp_allocator to build ANSI sequences ...
	//	This is not required, odin will do this for you periodically and when the program exits.
	//	But you may want to do it yourself when appropriate in long running programs.
	//	free_all(context.temp_allocator)

	//	Wow. You made it all the way to the end. Hope you enjoyed this geek out session.

}
