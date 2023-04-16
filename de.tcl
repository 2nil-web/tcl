package require widget::dateentry; # or widget::all

proc ts {{n ""}} {
  set nw [clock seconds]

  if {$n ne ""} {
    set nw [expr $nw + $n*86400]
  }

  return $nw
}

proc fmt_ts {{n ""} {f ""}} {
  if {$f eq ""} {
    set f "%Y-%m-%dT%H:%M:%S"
  }
  return [clock format [ts $n] -format $f]
}

proc date_ts {{n ""}} {
  return [fmt_ts $n "%d/%m/%Y"]
}

set t [widget::dateentry .de -dateformat "%d/%m/%Y" -language fr -textvariable d]
set d [date_ts -5]
pack $t -fill x -expand 1
set s [ttk::label .dl -text $d]
pack $s -fill x -expand 1

