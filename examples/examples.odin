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
	//		1. Using ANSI_Format struct, which has 4 variants. ANSI_3Bit, ANSI_4Bit, ANSI_8Bit, and ANSI_24Bit.
	//		2. Using a single string:
	//			ANSI_4Bit  -> "-f[blue] -b[black] -a[bold, underline]"
	//			ANSI_8Bit  -> "-f[255] -b[50] -a[bold, underline]"
	//			ANSI_24Bit -> "-f[200, 220, 250] -b[0, 0, 0] -a[bold, underline]"
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

	//	A variable can be initialized with the top level union, then asigned to a variant.
	//	This can be handy for dynamic assignments
	aformat: afmt.ANSI_Format
	aformat = afmt.ANSI_3Bit {
  	fg = .FG_BLUE,            // foreground
  	bg = .BG_BLACK,           // background
  	at = {.BOLD, .UNDERLINE}, // atributes
	}
	afmt.println(aformat, "01. Hellope from println using ANSI_3Bit")

	//	The same thing using string formatting instead
	afmt.println("-f[blue] -b[black] -a[bold, underline]", "01. Hellope from println using -f[blue] -b[black] -a[bold, underline]")

	afmt.println()

	//	What does the ANSI string look like without the text?
	afmt.print_raw_ansi(aformat)
	//	or with the text?
	aformat_string := afmt.tprint(aformat, "01. Hellope from tprint using ANSI_3Bit")
	afmt.print_raw_ansi(aformat_string)

	afmt.println()

	//	Not all fields are required. Empty fields are ignored.
	aformat = afmt.ANSI_4Bit {
		fg = .FG_BRIGHT_BLUE,
	}
	afmt.println(aformat, "02. Hellope from println using ANSI_4Bit")

	//	The same thing using string formatting instead
	afmt.println("-f[bright_blue]", "02. Hellope from println using -f[bright_blue]")

	afmt.println()

	//	8bit uses 0-255 for colors
	aformat = afmt.ANSI_8Bit {
		fg = 12,
		at = {.ITALIC},
	}
	afmt.println(aformat, "03. Hellope from println using ANSI_8Bit")

	//	The same thing using string formatting instead
	afmt.println("-f[12] -a[italic]", "03. Hellope from println using -f[12] -a[italic]")

	afmt.println()

	//	printf formatting works the same as expected with one exception.
	//	If the first arg in the arg list is an ansi format, that will be used, otherwise,
	//	the procedure acts the same as usual.

	aformat = afmt.ANSI_24Bit {
		fg = {77, 196, 255},
		bg = {35, 52, 71},
		at = {.UNDERLINE},
	}

	afmt.printfln("%2i. %-8s%-6s%s", aformat, 4, "Hellope", "World", "from printfln using ANSI_24Bit")

	//	The same thing using string formatting instead
	afmt.printfln("%2i. %-8s%-6s%s", "-f[77, 196, 255]-b[35, 52, 71]-a[underline]", 4, "Hellope", "World", "from printfln using -f[77, 196, 255]-b[35, 52, 71]-a[underline]")

	afmt.println()

	//
	//	Creating useful structures
	//

	//	Say we want a format for printing errors and warnings, that excepts dynamic input
	eformat := afmt.ANSI_4Bit{
		fg = .FG_RED,
	}

	wformat := afmt.ANSI_4Bit{
  	fg = .FG_YELLOW,
	}

	//	Create an ansi format with color and store %v variable for future use
	error := afmt.tprintf("%s%s", eformat, "Error: ", "%v")
	warning := afmt.tprintf("%s%s", wformat, "Warning: ", "%v")

	//	Now that we generated the ansi and inserted a %v in the string,
	//	we can use it as the print format for any one variable given.
	afmt.printfln(error, "This is an error message.")

	afmt.printfln(warning, "This is an warning message.")

	afmt.println()

	//	Do we want to create a format that has 2 different ansi formats in one line?
	eformat01 := afmt.ANSI_4Bit{
		fg = .FG_RED,
		at = {.BOLD, .UNDERLINE},
	}
  
	eformat02 := afmt.ANSI_4Bit{
		fg = .FG_MAGENTA,
	}

	format01 := afmt.tprint(eformat01, "Error:")
	format02 := afmt.tprint(eformat02, " %v")
	//	Join the strings with afmt.tprintf
	multi_format_error := afmt.tprintf("%s%s", format01, format02)

	//	Now we have a string with 2 different ansi sequences, and a %v inserted to print variable data.
	afmt.printfln(multi_format_error, "This is a multi ansi formated error message.")
	
	afmt.println()

	//	aprint works the same as tprint, but allocates dynamic memory
	ansi_allocated := afmt.aprintf("%2i. %s", "-f[cyan]", 5, "dynamically allocated ansi string using aprintf", allocator = context.allocator)
	afmt.println(ansi_allocated)
	delete(ansi_allocated)

	afmt.println()

	//	bprint also works similar to tprint and aprint, but you give it a backing buffer
	buf: [1024]byte
	res1 := afmt.bprintln(buf[:], "-f[blue]", "06.", "hellope1", "world1", "from bprintln")
	res2 := afmt.bprintln(buf[len(res1):], "-f[green]", "06.", "hellope2", "world2", "from bprintln")
	afmt.print(string(buf[:]))
	//	or
	afmt.print(res1)
	afmt.print(res2)

	afmt.println()	

	//	sbprint using a strings.Builder
	sbuf: strings.Builder
	defer strings.builder_destroy(&sbuf)
	afmt.sbprintln(&sbuf, "-f[cyan]", "07", "hellope1", "world1", "from sbprintln")
	afmt.sbprintln(&sbuf, "-f[green]", "07", "hellope2", "world2", "from sbprintln")
	afmt.print(string(sbuf.buf[:]))

	afmt.println()

	//	ctprint is like tprint, but returns a cstring instead
	ctemp := afmt.ctprintfln("%2i %s %s %s", "-f[blue]", 8, "hellope", "world", "from ctprintln")
	afmt.print(ctemp)

	afmt.println()

	//	caprint is like aprint, but returns a dynamically allocated cstring instead
	catemp := afmt.caprintfln("%2i %s %s %s", "-f[blue]", 9, "hellope", "world", "from caprintln")
	afmt.print(catemp)
	delete (catemp)

	afmt.println()

	//	Don't like using the ANSI_Format struct and prefer the string method,
	//	but want to dynamically define your ansi without string parsing or using strings.concatenate?
	fg := "bright_magenta"
	bg := "black"
	at := "italic,underline"
	af := afmt.tprintf("-f[%s]-b[%s]-a[%s] %s", fg, bg, at, "%v")
	afmt.println(af, "10. My dynamically created ansi format using the string method.")

	afmt.println()

	//
	//	Now let's get crazy ...
	//	using afmt to create colorful tables
	//

	Table :: struct {
		col_label: [4]afmt.ANSI_4Bit,
		col_data:  [4]afmt.ANSI_4Bit,
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
	afmt.println()

	//	We can make this even easier to use and re-use by doing a little extra work up front
	//	Save the formats into a string with tprintf ...
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
	for r in 0..=10 {
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
	afmt.println()

	//	Let's try this another way with string formating and rgb

	col_label = afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[0,0,0]-b[167, 168, 009]-a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 194, 113]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[016, 141, 194]-a[bold]", "%-20s"),
		afmt.tprintf("%v", "-f[0,0,0]-b[235, 050, 180]-a[bold]", "%-20s"),
	)

	row = afmt.tprintf(
		"%s%s%s%s",
		afmt.tprintf("%v", "-f[000, 000, 000] -b[193, 195, 100] -a[bold]", "%-10s"),
		afmt.tprintf("%v", "-f[016, 194, 113] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[016, 141, 194] -b[000, 000, 000]",          "%-20s"),
		afmt.tprintf("%v", "-f[235, 050, 180] -b[000, 000, 000]",          "%-20s"),
	)

	for r in 0..=10 {
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

	afmt.println()

	//	afmt uses context.temp_allocator to build ANSI sequences ...
	//	This is not required, odin will do this for you periodically and when the program exits.
	//	But you may want to do it yourself when appropriate in long running programs.
	//	free_all(context.temp_allocator)

}
