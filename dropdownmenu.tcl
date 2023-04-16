#!/usr/bin/env tclsh

proc ::tk_optionMenu {w varName firstValue args} {
    upvar #0 $varName var

    if {![info exists var]} {
        set var $firstValue
    }
    menubutton $w -textvariable $varName -indicatoron 1 -menu $w.menu \
            -relief raised -highlightthickness 1 -anchor c \
            -direction flush
    menu $w.menu -tearoff 0
    $w.menu add radiobutton -label $firstValue -variable $varName
    foreach i $args {
        $w.menu add radiobutton -label $i -variable $varName
    }
    return $w.menu
}


