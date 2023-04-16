#!env tclsh
package require Tk
button .b -text {Push Me} -command {tk_messageBox -message {hello, world}}
pack .b
