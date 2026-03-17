#+build !windows
package afmt

import "core:sys/posix"

@(private)
_set_utf8_terminal :: proc() {}

@(private)
_reset_utf8_terminal :: proc() {}