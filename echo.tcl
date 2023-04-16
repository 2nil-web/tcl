#!env wish

#	   ___    0  Michel Beaudouin-Lafon        e-mail: mbl@lri.fr
#	  /   \  /   LRI - Bat 490                 www   : http://www-ihm.lri.fr/~mbl
#	 /  __/ /    Universite de Paris-Sud       voice : +33 1 69 15 69 10
#	/__   \/     91 405 ORSAY Cedex - FRANCE   fax   : +33 1 69 15 65 86
#
#	Cet exemple illustre la notion d'echo dans un editeur partage.
#	Dans le mode sans echo, tout deplacement d'un objet dans une fenetre
#	se repercute immediatement dans les autres fenetres.
#	Dans le mode avec echo, la modification dans les autres fenetres
#	n'est faite qu'a la fin du deplacement. Pendant le deplacement, un icone
#	apparait pour indiquer que l'objet est en cours de modification.
#

# detruire eventuellement ce qui est deja dans l'interface
catch {eval destroy [winfo children .]}

# mode d'edition directe / avec echo
set Echo 0

# procedure appelee lorsque l'on clique sur un item.
proc itemStartDrag {c x y} {
    global firstX firstY lastX lastY
    set lastX [$c canvasx $x]
    set lastY [$c canvasy $y]
    set firstX $lastX
    set firstY $lastY
    $c addtag dragged withtag current

    global Echo
    if {$Echo == 0} {
		return
    }

    global Others
    set id [$c find withtag dragged]
    set coords [$c coords $id]
    set x [expr ([lindex $coords 0] + [lindex $coords 2]) / 2]
    set y [expr ([lindex $coords 1] + [lindex $coords 3]) / 2]
    foreach w $Others($c) {
	$w create rectangle [expr $x - 6] [expr $y - 4] [expr $x + 10] [expr $y + 8] \
		-fill red -tags icon
	$w create rectangle [expr $x - 10] [expr $y - 8] [expr $x + 6] [expr $y + 4] \
		-fill red -tags icon
    }
}

# procedure appelee lorsque l'on deplace un item.
proc itemDrag {c x y} {
    global lastX lastY
    set x [$c canvasx $x]
    set y [$c canvasy $y]

    $c move dragged [expr $x-$lastX] [expr $y-$lastY]

    global Echo
    if {$Echo == 0} {
		global Others
		set id [$c find withtag dragged]
		foreach w $Others($c) {
			$w move $id [expr $x-$lastX] [expr $y-$lastY]
		}
    }

    set lastX $x
    set lastY $y
}

# procedure appelee lorsque l'on a fini de deplacer un item.
proc itemStopDrag {c x y} {
    global Echo
    if {$Echo == 0} {
		$c dtag dragged
		return
    }

    global Others firstX firstY lastX lastY
    set id [$c find withtag dragged]
    set xinc [expr ($lastX - $firstX) / 10]
    set yinc [expr ($lastY - $firstY) / 10]
    foreach w $Others($c) {
		move $w $id $xinc $yinc 10
		$w delete icon
    }
    $c dtag dragged
}

# procedure appelee pendant l'animation du deplacement, en mode Echo
proc move {w id xinc yinc nb} {
	$w move $id $xinc $yinc
	incr nb -1
	if {$nb > 0} {
		after 100 [list move $w $id $xinc $yinc $nb]
	}
	update idletasks
}

# creer un mini panneau de controle
wm title . "Echo"
checkbutton .echo -text "Mode Echo" -variable Echo
button .quit -text "Quit" -command {destroy .}
pack .echo -fill x -padx 5 -pady 5
pack .quit -fill x -padx 5 -pady 5
wm geometry . +250+300

# creer deux fenetres
toplevel .t1
toplevel .t2
pack [canvas .t1.c -width 200 -height 200]
pack [canvas .t2.c -width 200 -height 200]

set Others(.t1.c) .t2.c
set Others(.t2.c) .t1.c

wm title .t1 Michel
wm title .t2 Alain

wm geometry .t1 +50+50
wm geometry .t2 +300+50

# definir les liaision d'evenements
foreach w {.t1.c .t2.c} {
	$w bind item <ButtonPress-1> "itemStartDrag %W %x %y"
	$w bind item <B1-Motion> "itemDrag %W %x %y"
	$w bind item <ButtonRelease-1> "itemStopDrag %W %x %y"

	bind $w <Enter> {
		focus %W
	}
	bind $w <Key> {
		global Echo
		set Echo [expr 1 - $Echo]
	}

	$w create oval 10 10 60 40 -fill blue -tags item
	$w create rectangle 30 50 90 80 -fill green -tags item
}

