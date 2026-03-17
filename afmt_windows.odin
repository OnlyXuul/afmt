#+build windows
package afmt

import "core:sys/windows"

@(private="file") orig_ocp: windows.CODEPAGE
@(private="file") orig_icp: windows.CODEPAGE

//  Sets Windows terminal CODEPAGE to .UTF8 for both input and ouput
@(private)
_set_utf8_terminal :: proc "contextless"() {
	orig_icp = orig_icp == windows.CODEPAGE.ACP ? windows.GetConsoleCP() : orig_icp // input
	orig_ocp = orig_ocp == windows.CODEPAGE.ACP ? windows.GetConsoleOutputCP() : orig_ocp// ouput
	assert_contextless(windows.SetConsoleCP(.UTF8) != false)
	assert_contextless(windows.SetConsoleOutputCP(.UTF8) != false)
}

//  Resets Windows terminal to original CODEPAGE from last run of set_utf8_terminal()
@(private)
_reset_utf8_terminal :: proc "contextless"() {
	assert_contextless(windows.SetConsoleCP(orig_icp) != false)
	assert_contextless(windows.SetConsoleOutputCP(orig_ocp) != false)
}