#!env tclsh

proc example {first {second ""} args} {
    if {$second eq ""} {
        puts "There is only one argument and it is: $first"
        return 1
    } else {
        if {$args eq ""} {
            puts "There are two arguments - $first and $second"
            return 2
        } else {
            puts "There are many arguments - $first and $second and $args"
            return "many"
        }
    }
}

#set count1 [example ONE]
#set count2 [example ONE TWO]
#set count3 [example ONE TWO THREE ]
#set count4 [example ONE TWO THREE FOUR]

#puts "The example was called with $count1, $count2, $count3, and $count4 Arguments"

#set dt [n_days_ago 3]
#puts "n days ago $dt"

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

set today [date_ts]
set last_day [fmt_ts -5]
set next_day [fmt_ts 5  "le %d/%m/%Y a %H:%M"]

puts "Today:     $today"
puts "Last day:  $last_day"
puts "Next day:  $next_day"

#puts "Today:     [clock format $today   -format %Y-%m-%dT%H:%M:%S]"
#puts "Last day:  [clock format $last_day -format %Y-%m-%dT%H:%M:%S]"
#puts "Next day:  [clock format $next_day -format %Y-%m-%dT%H:%M:%S]"

