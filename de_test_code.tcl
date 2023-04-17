if { [info script] eq $argv0 } {
    set auto_path [linsert $auto_path 0 [file dirname [info script]]]
    package require widget::dateentry
    destroy {*}[winfo children .]

    proc getDate { args } {
      #puts [info level 0]
      set ::SDATE [clock format [expr [clock seconds]-30*86400] -format "%d-%m-%Y"]
      puts "SDATE $::SDATE"
      puts "EDATE $::EDATE"
      puts [clock format [expr [clock seconds]-30*86400] -format "%d-%m-%Y"]
      set ::SDATE [clock format [expr [clock seconds]-30*86400] -format "%d-%m-%Y"]
      update idle
    }

    # package require widget::dateentry
    set ::SDATE [expr [clock seconds]-30*86400]
#    set ::SDATE [clock format [expr [clock seconds]-30*86400] -format "%d-%m-%Y"]
    set ::EDATE "16-03-2023"
    set beg [widget::dateentry .s -textvariable ::SDATE -dateformat "%d-%m-%Y" -command [list getDate .s]]
    set end [widget::dateentry .e -textvariable ::EDATE -dateformat "%d-%m-%Y" -command [list getDate .e]]
    grid [label .sl -text "Start:"] $beg -padx 4 -pady 4
    grid [label .el -text "End:"  ] $end -padx 4 -pady 4

#    puts [$end get]
}
