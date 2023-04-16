#!env wish
set version [info tclversion]
message .msg -text "Version Tcl/TK $version" -bg green -w 400
pack .msg
button .but -text OK -command exit
pack .but
