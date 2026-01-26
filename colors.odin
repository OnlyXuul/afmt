package afmt

import "core:reflect"

//	Colors are arranged by category and hue, which means they are not alphabetical.
//	Sorry for that


//	Get color name from RGB value, if there is a match.
@(require_results)
color_name_from_value :: proc(c: RGB) -> (value: string, valid: bool) {
	for _c, e in color {
		if _c == c {
			return reflect.enum_name_from_value(e)
		}
	}

	return "", false
}

//	Get color name from enum index value
@(require_results)
color_name_from_enum :: proc(color: Color) -> (value: string) {
	value, _ = reflect.enum_name_from_value(color)
	return
}

print_color_name_guide :: proc(group := "all") {
	range: [2]i16
	switch group {
	case "All",       "all":       range = {000, 139}
	case "Pinks",     "pinks":     range = {000, 013}
	case "Purples",   "purples":   range = {014, 021}
	case "Blues",     "blues":     range = {022, 054}
	case "Greens",    "greens":    range = {055, 079}
	case "Yellows",   "yellows":   range = {080, 096}
	case "Oranges",   "oranges":   range = {097, 114}
	case "Reds",      "reds":      range = {115, 130}
	case "Grayscale", "grayscale": range = {131, 139}
	case: range = {-1, -1}
	}

	width := [3]u8 {11, 26, 13}
	label := [3]Column(ANSI24) {
		{width[0], .CENTER, {fg = black, bg = silver + 25, at = {.BOLD}}},
		{width[1], .LEFT,   {fg = black, bg = silver + 40, at = {.BOLD}}},
		{width[2], .CENTER, {fg = black, bg = silver + 25, at = {.BOLD}}},
	}
	row := [3]Column(ANSI24) {
		{width[0], .CENTER, {fg = black, at = {.BOLD}}},
		{width[1], .LEFT,   {fg = gainsboro, bg = black + 25}},
		{width[2], .CENTER, {fg = gainsboro, bg = black + 25}},
	}

	for _color, _Color in color {
		if i16(_Color) < range[0] || i16(_Color) > range[1] {continue}
		switch u8(_Color) {
		case 000: printrow(label, "index", " Pinks",     "R   G   B")
		case 014: printrow(label, "index", " Purples",   "R   G   B")
		case 022: printrow(label, "index", " Blues",     "R   G   B")
		case 055: printrow(label, "index", " Greens",    "R   G   B")
		case 080: printrow(label, "index", " Yellows",   "R   G   B")
		case 097: printrow(label, "index", " Oranges",   "R   G   B")
		case 115: printrow(label, "index", " Reds",      "R   G   B")
		case 131: printrow(label, "index", " Grayscale", "R   G   B")
		}
		row[0].ansi.fg = contrast_ratio(_color, black) > contrast_ratio(_color, white) ? black : white
		row[0].ansi.bg = _color
		row[1].ansi.bg = u8(_Color) % 2 == 0 ? black : black + 25
		row[2].ansi.bg = u8(_Color) % 2 == 0 ? black : black + 25
		num  := tprintf("%3i", u8(_Color))
		name := tprintf(" %s", color_name_from_enum(_Color))
		rgb  := tprintf("%3i,%3i,%3i", _color.r, _color.g, _color.b)
		printrow(row, num, name, rgb)
	}
}

//	Pinks
lightpink            :: RGB { 255 , 182 , 193 }
pink                 :: RGB { 255 , 192 , 203 }
crimson              :: RGB { 220 , 020 , 060 }
lavenderblush        :: RGB { 255 , 240 , 245 }
palevioletred        :: RGB { 219 , 112 , 147 }
hotpink              :: RGB { 255 , 105 , 180 }
deeppink             :: RGB { 255 , 020 , 147 }
mediumvioletred      :: RGB { 199 , 021 , 133 }
orchid               :: RGB { 218 , 112 , 214 }
thistle              :: RGB { 216 , 191 , 216 }
plum                 :: RGB { 221 , 160 , 221 }
violet               :: RGB { 238 , 130 , 238 }
magenta              :: RGB { 255 , 000 , 255 }
fuchsia              :: RGB { 255 , 000 , 255 }

//	Purples
darkmagenta          :: RGB { 139 , 000 , 139 }
purple               :: RGB { 128 , 000 , 128 }
mediumorchid         :: RGB { 186 , 085 , 211 }
darkviolet           :: RGB { 148 , 000 , 211 }
darkorchid           :: RGB { 153 , 050 , 204 }
indigo               :: RGB { 075 , 000 , 130 }
blueviolet           :: RGB { 138 , 043 , 226 }
mediumpurple         :: RGB { 147 , 112 , 219 }

//	Blues
mediumslateblue      :: RGB { 123 , 104 , 238 }
slateblue            :: RGB { 106 , 090 , 205 }
darkslateblue        :: RGB { 072 , 061 , 139 }
ghostwhite           :: RGB { 248 , 248 , 255 }
lavender             :: RGB { 230 , 230 , 250 }
blue                 :: RGB { 000 , 000 , 255 }
mediumblue           :: RGB { 000 , 000 , 205 }
darkblue             :: RGB { 000 , 000 , 139 }
navy                 :: RGB { 000 , 000 , 128 }
midnightblue         :: RGB { 025 , 025 , 112 }
royalblue            :: RGB { 065 , 105 , 225 }
cornflowerblue       :: RGB { 100 , 149 , 237 }
lightsteelblue       :: RGB { 176 , 196 , 222 }
lightslategray       :: RGB { 119 , 136 , 153 }
slategray            :: RGB { 112 , 128 , 144 }
dodgerblue           :: RGB { 030 , 144 , 255 }
aliceblue            :: RGB { 240 , 248 , 255 }
steelblue            :: RGB { 070 , 130 , 180 }
lightskyblue         :: RGB { 135 , 206 , 250 }
skyblue              :: RGB { 135 , 206 , 235 }
deepskyblue          :: RGB { 000 , 191 , 255 }
lightblue            :: RGB { 173 , 216 , 230 }
powderblue           :: RGB { 176 , 224 , 230 }
cadetblue            :: RGB { 095 , 158 , 160 }
darkturquoise        :: RGB { 000 , 206 , 209 }
azure                :: RGB { 240 , 255 , 255 }
lightcyan            :: RGB { 224 , 255 , 255 }
paleturquoise        :: RGB { 175 , 238 , 238 }
aqua                 :: RGB { 000 , 255 , 255 }
cyan                 :: RGB { 000 , 255 , 255 }
darkcyan             :: RGB { 000 , 139 , 139 }
teal                 :: RGB { 000 , 128 , 128 }
darkslategray        :: RGB { 047 , 079 , 079 }

//	Greens
mediumturquoise      :: RGB { 072 , 209 , 204 }
lightseagreen        :: RGB { 032 , 178 , 170 }
turquoise            :: RGB { 064 , 224 , 208 }
aquamarine           :: RGB { 127 , 255 , 212 }
mediumaquamarine     :: RGB { 102 , 205 , 170 }
mediumspringgreen    :: RGB { 000 , 250 , 154 }
mintcream            :: RGB { 245 , 255 , 250 }
springgreen          :: RGB { 000 , 255 , 127 }
mediumseagreen       :: RGB { 060 , 179 , 113 }
seagreen             :: RGB { 046 , 139 , 087 }
honeydew             :: RGB { 240 , 255 , 240 }
darkseagreen         :: RGB { 143 , 188 , 143 }
palegreen            :: RGB { 152 , 251 , 152 }
lightgreen           :: RGB { 144 , 238 , 144 }
limegreen            :: RGB { 050 , 205 , 050 }
lime                 :: RGB { 000 , 255 , 000 }
forestgreen          :: RGB { 034 , 139 , 034 }
green                :: RGB { 000 , 128 , 000 }
darkgreen            :: RGB { 000 , 100 , 000 }
lawngreen            :: RGB { 124 , 252 , 000 }
chartreuse           :: RGB { 127 , 255 , 000 }
greenyellow          :: RGB { 173 , 255 , 047 }
darkolivegreen       :: RGB { 085 , 107 , 047 }
yellowgreen          :: RGB { 154 , 205 , 050 }
olivedrab            :: RGB { 107 , 142 , 035 }

//	Yellows
ivory                :: RGB { 255 , 255 , 240 }
beige                :: RGB { 245 , 245 , 220 }
lightyellow          :: RGB { 255 , 255 , 224 }
lightgoldenrodyellow :: RGB { 250 , 250 , 210 }
yellow               :: RGB { 255 , 255 , 000 }
olive                :: RGB { 128 , 128 , 000 }
darkkhaki            :: RGB { 189 , 183 , 107 }
palegoldenrod        :: RGB { 238 , 232 , 170 }
lemonchiffon         :: RGB { 255 , 250 , 205 }
khaki                :: RGB { 240 , 230 , 140 }
gold                 :: RGB { 255 , 215 , 000 }
cornsilk             :: RGB { 255 , 248 , 220 }
goldenrod            :: RGB { 218 , 165 , 032 }
darkgoldenrod        :: RGB { 184 , 134 , 011 }
floralwhite          :: RGB { 255 , 250 , 240 }
oldlace              :: RGB { 253 , 245 , 230 }
wheat                :: RGB { 245 , 222 , 179 }

//	Oranges
orange               :: RGB { 255 , 165 , 000 }
moccasin             :: RGB { 255 , 228 , 181 }
papayawhip           :: RGB { 255 , 239 , 213 }
blanchedalmond       :: RGB { 255 , 235 , 205 }
navajowhite          :: RGB { 255 , 222 , 173 }
antiquewhite         :: RGB { 250 , 235 , 215 }
tan                  :: RGB { 210 , 180 , 140 }
burlywood            :: RGB { 222 , 184 , 135 }
darkorange           :: RGB { 255 , 140 , 000 }
bisque               :: RGB { 255 , 228 , 196 }
linen                :: RGB { 250 , 240 , 230 }
peru                 :: RGB { 205 , 133 , 063 }
peachpuff            :: RGB { 255 , 218 , 185 }
sandybrown           :: RGB { 244 , 164 , 096 }
chocolate            :: RGB { 210 , 105 , 030 }
saddlebrown          :: RGB { 139 , 069 , 019 }
seashell             :: RGB { 255 , 245 , 238 }
sienna               :: RGB { 160 , 082 , 045 }

//	Reds
lightsalmon          :: RGB { 255 , 160 , 122 }
coral                :: RGB { 255 , 127 , 080 }
orangered            :: RGB { 255 , 069 , 000 }
darksalmon           :: RGB { 233 , 150 , 122 }
tomato               :: RGB { 255 , 099 , 071 }
salmon               :: RGB { 250 , 128 , 114 }
mistyrose            :: RGB { 255 , 228 , 225 }
lightcoral           :: RGB { 240 , 128 , 128 }
snow                 :: RGB { 255 , 250 , 250 }
rosybrown            :: RGB { 188 , 143 , 143 }
indianred            :: RGB { 205 , 092 , 092 }
red                  :: RGB { 255 , 000 , 000 }
brown                :: RGB { 165 , 042 , 042 }
firebrick            :: RGB { 178 , 034 , 034 }
darkred              :: RGB { 139 , 000 , 000 }
maroon               :: RGB { 128 , 000 , 000 }

//	Grayscale
white                :: RGB { 255 , 255 , 255 }
whitesmoke           :: RGB { 245 , 245 , 245 }
gainsboro            :: RGB { 220 , 220 , 220 }
lightgray            :: RGB { 211 , 211 , 211 }
silver               :: RGB { 192 , 192 , 192 }
darkgray             :: RGB { 169 , 169 , 169 }
gray                 :: RGB { 128 , 128 , 128 }
dimgray              :: RGB { 105 , 105 , 105 }
black                :: RGB { 000 , 000 , 000 }

@(rodata)
color := [Color]RGB {
	//	Pinks
	.lightpink            = lightpink,
	.pink                 = pink,
	.crimson              = crimson,
	.lavenderblush        = lavenderblush,
	.palevioletred        = palevioletred,
	.hotpink              = hotpink,
	.deeppink             = deeppink,
	.mediumvioletred      = mediumvioletred,
	.orchid               = orchid,
	.thistle              = thistle,
	.plum                 = plum,
	.violet               = violet,
	.magenta              = magenta,
	.fuchsia              = fuchsia,
	//	Purples
	.darkmagenta          = darkmagenta,
	.purple               = purple,
	.mediumorchid         = mediumorchid,
	.darkviolet           = darkviolet,
	.darkorchid           = darkorchid,
	.indigo               = indigo,
	.blueviolet           = blueviolet,
	.mediumpurple         = mediumpurple,
	//	Blues
	.mediumslateblue      = mediumslateblue,
	.slateblue            = slateblue,
	.darkslateblue        = darkslateblue,
	.ghostwhite           = ghostwhite,
	.lavender             = lavender,
	.blue                 = blue,
	.mediumblue           = mediumblue,
	.darkblue             = darkblue,
	.navy                 = navy,
	.midnightblue         = midnightblue,
	.royalblue            = royalblue,
	.cornflowerblue       = cornflowerblue,
	.lightsteelblue       = lightsteelblue,
	.lightslategray       = lightslategray,
	.slategray            = slategray,
	.dodgerblue           = dodgerblue,
	.aliceblue            = aliceblue,
	.steelblue            = steelblue,
	.lightskyblue         = lightskyblue,
	.skyblue              = skyblue,
	.deepskyblue          = deepskyblue,
	.lightblue            = lightblue,
	.powderblue           = powderblue,
	.cadetblue            = cadetblue,
	.darkturquoise        = darkturquoise,
	.azure                = azure,
	.lightcyan            = lightcyan,
	.paleturquoise        = paleturquoise,
	.aqua                 = aqua,
	.cyan                 = cyan,
	.darkcyan             = darkcyan,
	.teal                 = teal,
	.darkslategray        = darkslategray,
	//	Greens
	.mediumturquoise      = mediumturquoise,
	.lightseagreen        = lightseagreen,
	.turquoise            = turquoise,
	.aquamarine           = aquamarine,
	.mediumaquamarine     = mediumaquamarine,
	.mediumspringgreen    = mediumspringgreen,
	.mintcream            = mintcream,
	.springgreen          = springgreen,
	.mediumseagreen       = mediumseagreen,
	.seagreen             = seagreen,
	.honeydew             = honeydew,
	.darkseagreen         = darkseagreen,
	.palegreen            = palegreen,
	.lightgreen           = lightgreen,
	.limegreen            = limegreen,
	.lime                 = lime,
	.forestgreen          = forestgreen,
	.green                = green,
	.darkgreen            = darkgreen,
	.lawngreen            = lawngreen,
	.chartreuse           = chartreuse,
	.greenyellow          = greenyellow,
	.darkolivegreen       = darkolivegreen,
	.yellowgreen          = yellowgreen,
	.olivedrab            = olivedrab,
	//	Yellows
	.ivory                = ivory,
	.beige                = beige,
	.lightyellow          = lightyellow,
	.lightgoldenrodyellow = lightgoldenrodyellow,
	.yellow               = yellow,
	.olive                = olive,
	.darkkhaki            = darkkhaki,
	.palegoldenrod        = palegoldenrod,
	.lemonchiffon         = lemonchiffon,
	.khaki                = khaki,
	.gold                 = gold,
	.cornsilk             = cornsilk,
	.goldenrod            = goldenrod,
	.darkgoldenrod        = darkgoldenrod,
	.floralwhite          = floralwhite,
	.oldlace              = oldlace,
	.wheat                = wheat,
	//	Oranges
	.orange               = orange,
	.moccasin             = moccasin,
	.papayawhip           = papayawhip,
	.blanchedalmond       = blanchedalmond,
	.navajowhite          = navajowhite,
	.antiquewhite         = antiquewhite,
	.tan                  = tan,
	.burlywood            = burlywood,
	.darkorange           = darkorange,
	.bisque               = bisque,
	.linen                = linen,
	.peru                 = peru,
	.peachpuff            = peachpuff,
	.sandybrown           = sandybrown,
	.chocolate            = chocolate,
	.saddlebrown          = saddlebrown,
	.seashell             = seashell,
	.sienna               = sienna,
	//	Reds
	.lightsalmon          = lightsalmon,
	.coral                = coral,
	.orangered            = orangered,
	.darksalmon           = darksalmon,
	.tomato               = tomato,
	.salmon               = salmon,
	.mistyrose            = mistyrose,
	.lightcoral           = lightcoral,
	.snow                 = snow,
	.rosybrown            = rosybrown,
	.indianred            = indianred,
	.red                  = red,
	.brown                = brown,
	.firebrick            = firebrick,
	.darkred              = darkred,
	.maroon               = maroon,
	//	Grayscale
	.white                = white,
	.whitesmoke           = whitesmoke,
	.gainsboro            = gainsboro,
	.lightgray            = lightgray,
	.silver               = silver,
	.darkgray             = darkgray,
	.gray                 = gray,
	.dimgray              = dimgray,
	.black                = black,
}

Color :: enum u8 {
	//	Pinks
	lightpink, // 0
	pink,
	crimson,
	lavenderblush,
	palevioletred,
	hotpink,
	deeppink,
	mediumvioletred,
	orchid,
	thistle,
	plum,
	violet,
	magenta,
	fuchsia,
	//	Purples
	darkmagenta, // 14
	purple,
	mediumorchid,
	darkviolet,
	darkorchid,
	indigo,
	blueviolet,
	mediumpurple,
	//	Blues
	mediumslateblue, // 22
	slateblue,
	darkslateblue,
	ghostwhite,
	lavender,
	blue,
	mediumblue,
	darkblue,
	navy,
	midnightblue,
	royalblue,
	cornflowerblue,
	lightsteelblue,
	lightslategray,
	slategray,
	dodgerblue,
	aliceblue,
	steelblue,
	lightskyblue,
	skyblue,
	deepskyblue,
	lightblue,
	powderblue,
	cadetblue,
	darkturquoise,
	azure,
	lightcyan,
	paleturquoise,
	aqua,
	cyan,
	darkcyan,
	teal,
	darkslategray,
	//	Greens
	mediumturquoise, // 55
	lightseagreen,
	turquoise,
	aquamarine,
	mediumaquamarine,
	mediumspringgreen,
	mintcream,
	springgreen,
	mediumseagreen,
	seagreen,
	honeydew,
	darkseagreen,
	palegreen,
	lightgreen,
	limegreen,
	lime,
	forestgreen,
	green,
	darkgreen,
	lawngreen,
	chartreuse,
	greenyellow,
	darkolivegreen,
	yellowgreen,
	olivedrab,
	//	Yellows
	ivory, // 80
	beige,
	lightyellow,
	lightgoldenrodyellow,
	yellow,
	olive,
	darkkhaki,
	palegoldenrod,
	lemonchiffon,
	khaki,
	gold,
	cornsilk,
	goldenrod,
	darkgoldenrod,
	floralwhite,
	oldlace,
	wheat,
	//Oranges
	orange, // 97
	moccasin,
	papayawhip,
	blanchedalmond,
	navajowhite,
	antiquewhite,
	tan,
	burlywood,
	darkorange,
	bisque,
	linen,
	peru,
	peachpuff,
	sandybrown,
	chocolate,
	saddlebrown,
	seashell,
	sienna,
	//	Reds
	lightsalmon, // 115
	coral,
	orangered,
	darksalmon,
	tomato,
	salmon,
	mistyrose,
	lightcoral,
	snow,
	rosybrown,
	indianred,
	red,
	brown,
	firebrick,
	darkred,
	maroon,
	//	Grayscale
	white, // 131
	whitesmoke,
	gainsboro,
	lightgray,
	silver,
	darkgray,
	gray,
	dimgray,
	black, // 139
}
