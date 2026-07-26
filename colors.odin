package afmt

import "core:reflect"

//	Colors are arranged by category and hue, which means they are not alphabetical.
//	Sorry for that
//	based on https://en.wikipedia.org/wiki/Web_colors#X11_color_names


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

rune_upper :: proc(r: rune) -> rune {
	return r >= 'a' && r <= 'z' ? r ~ (1 << 5) : r
}

print_color_guide :: proc(groups: bit_set[Color_Group] = {.all}, bg := true) {
	groups := groups
	if .all in groups || groups == nil { 
		for cg in Color_Group { groups += {cg} }
		groups -= {.all}
	}

	width := [3]u8 {22, 13, 18}
	label: [3]Column(ANSI24)
	if bg {
		label = [3]Column(ANSI24) {
			{width[0], .LEFT,   {black, darkgray, {.bold}}},
			{width[1], .CENTER, {black, gray,     {.bold}}},
			{width[2], .CENTER, {black, darkgray, {.bold}}},
		}
	} else {
		label = [3]Column(ANSI24) {
			{width[0], .LEFT,   {black, lightgray, {.bold}}},
			{width[1], .CENTER, {black, silver,    {.bold}}},
			{width[2], .CENTER, {black, lightgray, {.bold}}},
		}
	}
	cols := [3]Column(ANSI24) {
		{width[0], .LEFT,   {}},
		{width[1], .CENTER, {}},
		{width[2], .CENTER, {}},
	}

	for group in groups {
		range := color_group_range[group]
		name, _ := reflect.enum_name_from_value(group)
		name = tprintf(" %r%s Group", rune_upper(rune(name[0])), name[1:])
		printrow(label, name,   "R   G   B", " H    S    L")
		for id in Color(range[0]) ..= Color(range[1]) {
			c := color[id]
			if bg {
				cols[0].ansi.fg = contrast_ratio(c, black) > contrast_ratio(c, white) ? black : white
				cols[0].ansi.bg = c
			} else {
				cols[0].ansi.bg = black
				cols[0].ansi.fg = c
			}
			cols[1].ansi = cols[0].ansi
			cols[2].ansi = cols[0].ansi
			name = tprintf(" %s", color_name_from_enum(id))
			rgb  := tprintf("%3i %3i %3i", c.r, c.g, c.b)
			hsl_ := hsl(c)
			hsls := tprintf("%6.2f %.2f %.2f", hsl_[0], hsl_[1], hsl_[2])
			printrow(cols, name, rgb, hsls)
		}
	}
}

print_color_guide_ex :: proc(groups: bit_set[Color_Group] = {.all}, bg := true, test_color := Color.black) {
	groups := groups
	if .all in groups || groups == nil { 
		for cg in Color_Group { groups += {cg} }
		groups -= {.all}
	}

	width := [3]u8 {22, 13, 18}
	label := [3]Column(ANSI24) {
		{width[0], .LEFT,   {black, darkgray, {.bold}}},
		{width[1], .CENTER, {black, gray,     {.bold}}},
		{width[2], .CENTER, {black, darkgray, {.bold}}},
	}
	cols := [3]Column(ANSI24) {
		{width[0], .LEFT,   {}},
		{width[1], .CENTER, {}},
		{width[2], .CENTER, {}},
	}

	for group in groups {
		range := color_group_range[group]
		name, _ := reflect.enum_name_from_value(group)
		name = tprintf(" %r%s Group", rune_upper(rune(name[0])), name[1:])
		printrow(label, name,   "R   G   B", " H    S    L")
		for id in Color(range[0]) ..= Color(range[1]) {
			c := color[id]
			if bg {
				cols[0].ansi.fg = color[test_color]
				cols[0].ansi.bg = c
			} else {
				cols[0].ansi.bg = color[test_color]
				cols[0].ansi.fg = c
			}
			cols[1].ansi = cols[0].ansi
			cols[2].ansi = cols[0].ansi
			name = tprintf(" %s", color_name_from_enum(id))
			rgb  := tprintf("%3i %3i %3i", c.r, c.g, c.b)
			hsl_ := hsl(c)
			hsls := tprintf("%6.2f %.2f %.2f", hsl_[0], hsl_[1], hsl_[2])
			printrow(cols, name, rgb, hsls)
		}
	}
}

Color_Group :: enum u8 {
	all,
	pinks,
	purples,
	blues,
	cyans,
	greens,
	yellows,
	oranges,
	reds,
	browns,
	whites,
	grays,
}

color_group_range := [Color_Group][2]Color {
	.all     = all_range,
	.pinks   = pinks_range,
	.purples = purples_range,
	.blues   = blues_range,
	.cyans   = cyans_range,
	.greens  = greens_range,
	.yellows = yellows_range,
	.oranges = oranges_range,
	.reds    = reds_range,
	.browns  = browns_range,
	.whites  = whites_range,
	.grays   = grays_range,
}

all_range     :: [2]Color { Color.mediumvioletred, Color.gainsboro }
pinks_range   :: [2]Color { Color.mediumvioletred, Color.pink }
purples_range :: [2]Color { Color.indigo,          Color.lavender }
blues_range   :: [2]Color { Color.midnightblue,    Color.powderblue }
cyans_range   :: [2]Color { Color.teal,            Color.lightcyan }
greens_range  :: [2]Color { Color.darkgreen,       Color.palegreen }
yellows_range :: [2]Color { Color.darkkhaki,       Color.lightyellow }
oranges_range :: [2]Color { Color.orangered,       Color.orange }
reds_range    :: [2]Color { Color.darkred,         Color.lightsalmon }
browns_range  :: [2]Color { Color.maroon,          Color.cornsilk }
whites_range  :: [2]Color { Color.mistyrose,       Color.white }
grays_range   :: [2]Color { Color.black,           Color.gainsboro }

/*  Pinks                                 */
mediumvioletred      :: RGB{ 199, 021, 133 }
deeppink             :: RGB{ 255, 020, 147 }
palevioletred        :: RGB{ 219, 112, 147 }
hotpink              :: RGB{ 255, 105, 180 }
lightpink            :: RGB{ 255, 182, 193 }
pink                 :: RGB{ 255, 192, 203 }
/*  Purples                               */
indigo               :: RGB{ 075, 000, 130 }
rebeccapurple        :: RGB{ 102, 051, 153 }
purple               :: RGB{ 128, 000, 128 }
darkmagenta          :: RGB{ 139, 000, 139 }
darkviolet           :: RGB{ 148, 000, 211 }
darkslateblue        :: RGB{ 072, 061, 139 }
blueviolet           :: RGB{ 138, 043, 226 }
darkorchid           :: RGB{ 153, 050, 204 }
fuchsia              :: RGB{ 255, 000, 255 }
magenta              :: RGB{ 255, 000, 255 }
slateblue            :: RGB{ 106, 090, 205 }
mediumslateblue      :: RGB{ 123, 104, 238 }
mediumorchid         :: RGB{ 186, 085, 211 }
mediumpurple         :: RGB{ 147, 112, 219 }
orchid               :: RGB{ 218, 112, 214 }
violet               :: RGB{ 238, 130, 238 }
plum                 :: RGB{ 221, 160, 221 }
thistle              :: RGB{ 216, 191, 216 }
lavender             :: RGB{ 230, 230, 250 }
/*  Blues                                 */
midnightblue         :: RGB{ 025, 025, 112 }
navy                 :: RGB{ 000, 000, 128 }
darkblue             :: RGB{ 000, 000, 139 }
mediumblue           :: RGB{ 000, 000, 205 }
blue                 :: RGB{ 000, 000, 255 }
royalblue            :: RGB{ 065, 105, 225 }
steelblue            :: RGB{ 070, 130, 180 }
dodgerblue           :: RGB{ 030, 144, 255 }
deepskyblue          :: RGB{ 000, 191, 255 }
cornflowerblue       :: RGB{ 100, 149, 237 }
skyblue              :: RGB{ 135, 206, 235 }
lightskyblue         :: RGB{ 135, 206, 250 }
lightsteelblue       :: RGB{ 176, 196, 222 }
lightblue            :: RGB{ 173, 216, 230 }
powderblue           :: RGB{ 176, 224, 230 }
/*  Cyans                                 */
teal                 :: RGB{ 000, 128, 128 }
darkcyan             :: RGB{ 000, 139, 139 }
lightseagreen        :: RGB{ 032, 178, 170 }
cadetblue            :: RGB{ 095, 158, 160 }
darkturquoise        :: RGB{ 000, 206, 209 }
mediumturquoise      :: RGB{ 072, 209, 204 }
turquoise            :: RGB{ 064, 224, 208 }
aqua                 :: RGB{ 000, 255, 255 }
cyan                 :: RGB{ 000, 255, 255 }
aquamarine           :: RGB{ 127, 255, 212 }
paleturquoise        :: RGB{ 175, 238, 238 }
lightcyan            :: RGB{ 224, 255, 255 }
/*  Greens                                */
darkgreen            :: RGB{ 000, 100, 000 }
green                :: RGB{ 000, 128, 000 }
darkolivegreen       :: RGB{ 085, 107, 047 }
forestgreen          :: RGB{ 034, 139, 034 }
seagreen             :: RGB{ 046, 139, 087 }
olive                :: RGB{ 128, 128, 000 }
olivedrab            :: RGB{ 107, 142, 035 }
mediumseagreen       :: RGB{ 060, 179, 113 }
limegreen            :: RGB{ 050, 205, 050 }
lime                 :: RGB{ 000, 255, 000 }
springgreen          :: RGB{ 000, 255, 127 }
mediumspringgreen    :: RGB{ 000, 250, 154 }
darkseagreen         :: RGB{ 143, 188, 143 }
mediumaquamarine     :: RGB{ 102, 205, 170 }
yellowgreen          :: RGB{ 154, 205, 050 }
lawngreen            :: RGB{ 124, 252, 000 }
chartreuse           :: RGB{ 127, 255, 000 }
lightgreen           :: RGB{ 144, 238, 144 }
greenyellow          :: RGB{ 173, 255, 047 }
palegreen            :: RGB{ 152, 251, 152 }
/*  Yellows                               */
darkkhaki            :: RGB{ 189, 183, 107 }
gold                 :: RGB{ 255, 215, 000 }
khaki                :: RGB{ 240, 230, 140 }
peachpuff            :: RGB{ 255, 218, 185 }
yellow               :: RGB{ 255, 255, 000 }
palegoldenrod        :: RGB{ 238, 232, 170 }
moccasin             :: RGB{ 255, 228, 181 }
papayawhip           :: RGB{ 255, 239, 213 }
lightgoldenrodyellow :: RGB{ 250, 250, 210 }
lemonchiffon         :: RGB{ 255, 250, 205 }
lightyellow          :: RGB{ 255, 255, 224 }
/*  Oranges                               */
orangered            :: RGB{ 255, 069, 000 }
tomato               :: RGB{ 255, 099, 071 }
darkorange           :: RGB{ 255, 140, 000 }
coral                :: RGB{ 255, 127, 080 }
orange               :: RGB{ 255, 165, 000 }
/*  Reds                                  */
darkred              :: RGB{ 139, 000, 000 }
red                  :: RGB{ 255, 000, 000 }
firebrick            :: RGB{ 178, 034, 034 }
crimson              :: RGB{ 220, 020, 060 }
indianred            :: RGB{ 205, 092, 092 }
lightcoral           :: RGB{ 240, 128, 128 }
salmon               :: RGB{ 250, 128, 114 }
darksalmon           :: RGB{ 233, 150, 122 }
lightsalmon          :: RGB{ 255, 160, 122 }
/*  Browns                                */
maroon               :: RGB{ 128, 000, 000 }
brown                :: RGB{ 165, 042, 042 }
saddlebrown          :: RGB{ 139, 069, 019 }
sienna               :: RGB{ 160, 082, 045 }
chocolate            :: RGB{ 210, 105, 030 }
darkgoldenrod        :: RGB{ 184, 134, 011 }
peru                 :: RGB{ 205, 133, 063 }
rosybrown            :: RGB{ 188, 143, 143 }
goldenrod            :: RGB{ 218, 165, 032 }
sandybrown           :: RGB{ 244, 164, 096 }
tan                  :: RGB{ 210, 180, 140 }
burlywood            :: RGB{ 222, 184, 135 }
wheat                :: RGB{ 245, 222, 179 }
navajowhite          :: RGB{ 255, 222, 173 }
bisque               :: RGB{ 255, 228, 196 }
blanchedalmond       :: RGB{ 255, 235, 205 }
cornsilk             :: RGB{ 255, 248, 220 }
/*  Whites                                */
mistyrose            :: RGB{ 255, 228, 225 }
antiquewhite         :: RGB{ 250, 235, 215 }
linen                :: RGB{ 250, 240, 230 }
beige                :: RGB{ 245, 245, 220 }
whitesmoke           :: RGB{ 245, 245, 245 }
lavenderblush        :: RGB{ 255, 240, 245 }
oldlace              :: RGB{ 253, 245, 230 }
aliceblue            :: RGB{ 240, 248, 255 }
seashell             :: RGB{ 255, 245, 238 }
ghostwhite           :: RGB{ 248, 248, 255 }
honeydew             :: RGB{ 240, 255, 240 }
floralwhite          :: RGB{ 255, 250, 240 }
azure                :: RGB{ 240, 255, 255 }
mintcream            :: RGB{ 245, 255, 250 }
snow                 :: RGB{ 255, 250, 250 }
ivory                :: RGB{ 255, 255, 240 }
white                :: RGB{ 255, 255, 255 }
/*  Grays                                 */
black                :: RGB{ 000, 000, 000 }
darkslategray        :: RGB{ 047, 079, 079 }
dimgray              :: RGB{ 105, 105, 105 }
slategray            :: RGB{ 112, 128, 144 }
gray                 :: RGB{ 128, 128, 128 }
lightslategray       :: RGB{ 119, 136, 153 }
darkgray             :: RGB{ 169, 169, 169 }
silver               :: RGB{ 192, 192, 192 }
lightgray            :: RGB{ 211, 211, 211 }
gainsboro            :: RGB{ 220, 220, 220 }

@(rodata)
color := [Color]RGB {
	//	Pinks
	.mediumvioletred      = mediumvioletred,
	.deeppink             = deeppink,
	.palevioletred        = palevioletred,
	.hotpink              = hotpink,
	.lightpink            = lightpink,
	.pink                 = pink,
	//	Purples
	.indigo               = indigo,
	.rebeccapurple        = rebeccapurple,
	.purple               = purple,
	.darkmagenta          = darkmagenta,
	.darkviolet           = darkviolet,
	.darkslateblue        = darkslateblue,
	.blueviolet           = blueviolet,
	.darkorchid           = darkorchid,
	.fuchsia              = fuchsia,
	.magenta              = magenta,
	.slateblue            = slateblue,
	.mediumslateblue      = mediumslateblue,
	.mediumorchid         = mediumorchid,
	.mediumpurple         = mediumpurple,
	.orchid               = orchid,
	.violet               = violet,
	.plum                 = plum,
	.thistle              = thistle,
	.lavender             = lavender,
	//	Blues
	.midnightblue         = midnightblue,
	.navy                 = navy,
	.darkblue             = darkblue,
	.mediumblue           = mediumblue,
	.blue                 = blue,
	.royalblue            = royalblue,
	.steelblue            = steelblue,
	.dodgerblue           = dodgerblue,
	.deepskyblue          = deepskyblue,
	.cornflowerblue       = cornflowerblue,
	.skyblue              = skyblue,
	.lightskyblue         = lightskyblue,
	.lightsteelblue       = lightsteelblue,
	.lightblue            = lightblue,
	.powderblue           = powderblue,
	//	Cyans
	.teal                 = teal,
	.darkcyan             = darkcyan,
	.lightseagreen        = lightseagreen,
	.cadetblue            = cadetblue,
	.darkturquoise        = darkturquoise,
	.mediumturquoise      = mediumturquoise,
	.turquoise            = turquoise,
	.aqua                 = aqua,
	.cyan                 = cyan,
	.aquamarine           = aquamarine,
	.paleturquoise        = paleturquoise,
	.lightcyan            = lightcyan,
	//	Greens
	.darkgreen            = darkgreen,
	.green                = green,
	.darkolivegreen       = darkolivegreen,
	.forestgreen          = forestgreen,
	.seagreen             = seagreen,
	.olive                = olive,
	.olivedrab            = olivedrab,
	.mediumseagreen       = mediumseagreen,
	.limegreen            = limegreen,
	.lime                 = lime,
	.springgreen          = springgreen,
	.mediumspringgreen    = mediumspringgreen,
	.darkseagreen         = darkseagreen,
	.mediumaquamarine     = mediumaquamarine,
	.yellowgreen          = yellowgreen,
	.lawngreen            = lawngreen,
	.chartreuse           = chartreuse,
	.lightgreen           = lightgreen,
	.greenyellow          = greenyellow,
	.palegreen            = palegreen,
	//	Yellows
	.darkkhaki            = darkkhaki,
	.gold                 = gold,
	.khaki                = khaki,
	.peachpuff            = peachpuff,
	.yellow               = yellow,
	.palegoldenrod        = palegoldenrod,
	.moccasin             = moccasin,
	.papayawhip           = papayawhip,
	.lightgoldenrodyellow = lightgoldenrodyellow,
	.lemonchiffon         = lemonchiffon,
	.lightyellow          = lightyellow,
	//	Oranges
	.orangered            = orangered,
	.tomato               = tomato,
	.darkorange           = darkorange,
	.coral                = coral,
	.orange               = orange,
	//	Reds
	.darkred              = darkred,
	.red                  = red,
	.firebrick            = firebrick,
	.crimson              = crimson,
	.indianred            = indianred,
	.lightcoral           = lightcoral,
	.salmon               = salmon,
	.darksalmon           = darksalmon,
	.lightsalmon          = lightsalmon,
	//	Browns
	.maroon               = maroon,
	.brown                = brown,
	.saddlebrown          = saddlebrown,
	.sienna               = sienna,
	.chocolate            = chocolate,
	.darkgoldenrod        = darkgoldenrod,
	.peru                 = peru,
	.rosybrown            = rosybrown,
	.goldenrod            = goldenrod,
	.sandybrown           = sandybrown,
	.tan                  = tan,
	.burlywood            = burlywood,
	.wheat                = wheat,
	.navajowhite          = navajowhite,
	.bisque               = bisque,
	.blanchedalmond       = blanchedalmond,
	.cornsilk             = cornsilk,
	//	Whites
	.mistyrose            = mistyrose,
	.antiquewhite         = antiquewhite,
	.linen                = linen,
	.beige                = beige,
	.whitesmoke           = whitesmoke,
	.lavenderblush        = lavenderblush,
	.oldlace              = oldlace,
	.aliceblue            = aliceblue,
	.seashell             = seashell,
	.ghostwhite           = ghostwhite,
	.honeydew             = honeydew,
	.floralwhite          = floralwhite,
	.azure                = azure,
	.mintcream            = mintcream,
	.snow                 = snow,
	.ivory                = ivory,
	.white                = white,
	//	Grays
	.black                = black,
	.darkslategray        = darkslategray,
	.dimgray              = dimgray,
	.slategray            = slategray,
	.gray                 = gray,
	.lightslategray       = lightslategray,
	.darkgray             = darkgray,
	.silver               = silver,
	.lightgray            = lightgray,
	.gainsboro            = gainsboro,
}

Color :: enum u8 {
	//	Pinks
	mediumvioletred, // 0
	deeppink,
	palevioletred,
	hotpink,
	lightpink,
	pink,
	//	Purples
	indigo, // 6
	rebeccapurple,
	purple,
	darkmagenta,
	darkviolet,
	darkslateblue,
	blueviolet,
	darkorchid,
	fuchsia,
	magenta,
	slateblue,
	mediumslateblue,
	mediumorchid,
	mediumpurple,
	orchid,
	violet,
	plum,
	thistle,
	lavender,
	//	Blues
	midnightblue, // 25
	navy,
	darkblue,
	mediumblue,
	blue,
	royalblue,
	steelblue,
	dodgerblue,
	deepskyblue,
	cornflowerblue,
	skyblue,
	lightskyblue,
	lightsteelblue,
	lightblue,
	powderblue,
	//	Cyans
	teal, // 40
	darkcyan,
	lightseagreen,
	cadetblue,
	darkturquoise,
	mediumturquoise,
	turquoise,
	aqua,
	cyan,
	aquamarine,
	paleturquoise,
	lightcyan,
	//	Greens
	darkgreen, // 52
	green,
	darkolivegreen,
	forestgreen,
	seagreen,
	olive,
	olivedrab,
	mediumseagreen,
	limegreen,
	lime,
	springgreen,
	mediumspringgreen,
	darkseagreen,
	mediumaquamarine,
	yellowgreen,
	lawngreen,
	chartreuse,
	lightgreen,
	greenyellow,
	palegreen,
	//	Yellows
	darkkhaki, // 72
	gold,
	khaki,
	peachpuff,
	yellow,
	palegoldenrod,
	moccasin,
	papayawhip,
	lightgoldenrodyellow,
	lemonchiffon,
	lightyellow,
	//	Oranges
	orangered, // 83
	tomato,
	darkorange,
	coral,
	orange,
	//	Reds
	darkred, // 88
	red,
	firebrick,
	crimson,
	indianred,
	lightcoral,
	salmon,
	darksalmon,
	lightsalmon,
	//	Browns
	maroon, // 97
	brown,
	saddlebrown,
	sienna,
	chocolate,
	darkgoldenrod,
	peru,
	rosybrown,
	goldenrod,
	sandybrown,
	tan,
	burlywood,
	wheat,
	navajowhite,
	bisque,
	blanchedalmond,
	cornsilk,
	//	Whites
	mistyrose, // 114
	antiquewhite,
	linen,
	beige,
	whitesmoke,
	lavenderblush,
	oldlace,
	aliceblue,
	seashell,
	ghostwhite,
	honeydew,
	floralwhite,
	azure,
	mintcream,
	snow,
	ivory,
	white,
	//	Grays
	black, // 131
	darkslategray,
	dimgray,
	slategray,
	gray,
	lightslategray,
	darkgray,
	silver,
	lightgray,
	gainsboro, // 140
}