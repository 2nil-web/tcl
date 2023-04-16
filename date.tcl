#!env tclsh

proc n_days_ago {n} {
 set day [expr 24 * 3600] # seconds in one day
 set now [clock seconds]
 puts [expr $now - $day]
 return [expr $now - $day]
}

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

set count1 [example ONE]
set count2 [example ONE TWO]
set count3 [example ONE TWO THREE ]
set count4 [example ONE TWO THREE FOUR]

#puts "The example was called with $count1, $count2, $count3, and $count4 Arguments"

#set dt [n_days_ago 3]
#puts "n days ago $dt"

n_days_ago 5
clock seconds
set systemTime [clock seconds]
set yest [expr systemTime - 86400]"
puts "Seconds: [expr $systemTime - 86400]"
puts "The time is: [clock format $systemTime -format %H:%M:%S]"
puts "The date is: [clock format $yest -format %D]"
