#!/usr/bin/env tclsh

package require Tk
package require widget::all

labeledwidget .lw -labeltext "Canvas Widget" -labelpos s
pack .lw -fill both -expand yes -padx 10 -pady 10

set cw [canvas [.lw childsite].c -relief raised -width 200 -height 200]
pack $cw -padx 10 -pady 10
