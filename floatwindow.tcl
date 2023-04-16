#!env wish
#	(c) 1997, Michel Beaudouin-Lafon, mbl@lri.fr
#
#	floatwindow.tcl	gestion de fenetres flottantes
#
#		FloatWindow - creation
#		FloatWindowMoveBy - deplacement
#		FloatWindowResizeBy -changement de taille

# FloatWindow nom -option valeur ...
#	cree une nouvelle fenetre flottante.
#
#	'nom' est le chemin d'acces de la fenêtre. S'il existe deja une
#	fenetre de ce nom, un nom unique est genere.
#
#	'-option valeur...' est une liste d'options. Les options reconnues
#	sont celles du widget 'toplevel' (par exemple -width et -height
#	pour la taille).
#
#	la procedure retourne le nom du widget cree.
#
proc FloatWindow {window args} {
	# creer la fenetre en lui donnant un nom unique si necessaire
	if [winfo exist $window] {
		set i 0
		while [winfo exist $window$i] {
			incr i
		}
		set window $window$i
	}
	eval toplevel $window $args
	# indiquer que l'on ne veut pas de decoration par le window manager
	wm overrideredirect $window on
	# retourner le chemin d'acces
	return $window
}

# FloatWindowMoveBy nom dx dy
#	deplace une fenetre flottante de dx dy
#
#	'nom' est le nom de la fenetre, retourne par FloatWindow
#	'dx', 'dy' sont le deplacement
#
#	la procedure ne retourne rien
#
proc FloatWindowMoveBy {window dx dy} {
	# recuperer la position
	set x [winfo x $window]
	set y [winfo y $window]
	# calculer la nouvelle position
	incr x $dx
	incr y $dy
	# l'affecter a la fenetre
	wm geometry $window +$x+$y
	# mettre a jour l'affichage : necessaire pour que les coordonnees
	# de la fenetre soient mises a jour immediatement
	update idletasks
}

# FloatWindowResizeBy nom dw dh corner
#	change la taille d'une fenetre flottante
#
#	'nom' est le nom de la fenetre, retourne par FloatWindow
#	'dw', 'dh' sont le changement de taille dans chaque direction (peuvent etre negatifs)
#	'corner' (par defaut se) est le coin de la fenetre qui est deplace.
#	  les valeurs reconnues sont : nw, ne, se, sw.
#
proc FloatWindowResizeBy {window dw dh {corner se}} {
	# calculer les points diagonaux
	set x1 [winfo x $window]
	set y1 [winfo y $window]
	set x2 [expr $x1 + [winfo width $window]]
	set y2 [expr $y1 + [winfo height $window]]
	
	# calculer la nouvelle taille et position
	# calculer les nouvelles coordonnees du coin que l'on deplace, 
	# et verifier que l'on n'a pas une fenetre de taille negative
	switch -exact -- $corner {
		nw {
			incr x1 $dw
			incr y1 $dh
			if {$x1 > $x2} {set x2 [expr $x1 + 1]}
			if {$y1 > $y2} {set y2 [expr $y1 + 1]}
		}
		ne {
			incr x2 $dw
			incr y1 $dh
			if {$x1 > $x2} {set x1 [expr $x2 - 1]}
			if {$y1 > $y2} {set y2 [expr $y1 + 1]}
		}
		sw {
			incr x1 $dw
			incr y2 $dh
			if {$x1 > $x2} {set x2 [expr $x1 + 1]}
			if {$y1 > $y2} {set y1 [expr $y2 - 1]}
		}
		se {
			incr x2 $dw
			incr y2 $dh
			if {$x1 > $x2} {set x1 [expr $x2 - 1]}
			if {$y1 > $y2} {set y1 [expr $y2 - 1]}
		}
	}
	
	# retailler la fenetre
	wm geometry $window [expr $x2 - $x1]x[expr $y2 - $y1]+$x1+$y1
	
	# mettre a jour l'affichage : necessaire pour que les coordonnees
	# de la fenetre soient mises a jour immediatement
	update idletasks
}

# -------- exemple d'utilisation --------
#

# detruire les widgets que l'on va creer.
# utile lorsque l'on recharge le meme script plusieurs fois
catch {destroy .new .quit}

# procedures pour les liaisons d'evenements
#	StartDrag enregistre la position de la souris
#	DragMove deplace la fenetre de dx,dy distance entre les positions courantes et precedentes de la souris
#	DragResize retaille la fenetre de dh,dw distance entre les positions courantes et precedentes de la souris
#

proc StartDrag {widget x y} {
	# ces variables globables contiennent la derniere position connue de la souris
	global xprev yprev
	
	set xprev $x
	set yprev $y
}

proc DragMove {widget x y} {
	global xprev yprev
	
	# deplacer la fenetre de toplevel (ici une fenetre flottante) de dx,dy
	FloatWindowMoveBy [winfo toplevel $widget] [expr $x - $xprev] [expr $y - $yprev]
	
	# mettre a jour la position de la souris
	set xprev $x
	set yprev $y
}

proc DragResize {widget x y {corner se}} {
	global xprev yprev
	
	# retailler la fenetre de toplevel (ici une fenetre flottante) de dx,dy
	FloatWindowResizeBy [winfo toplevel $widget] [expr $x - $xprev] [expr $y - $yprev] $corner
	
	# mettre a jour la position de la souris
	set xprev $x
	set yprev $y
}

# definir un bouton permettant de creer des fenetres flottantes
#
button .new -text "Creer fenetre" -command {
	# creer une nouvelle fenetre flottante
	set float [FloatWindow .float]
	
	# definir les liaisons pour pouvoir deplacer la fenetre en cliquant dedans	
	bind $float <ButtonPress-1> "StartDrag %W %X %Y"
	bind $float <Button1-Motion> "DragMove %W %X %Y"
	
	# creer quatre poignees aux quatre coins pour retailler la fenetre
	foreach corner {ne se nw sw} {
		# creer la poignee
		frame $float.$corner -bg grey -width 20 -height 20
		# definir les liaisons pour pouvoir retailler la fenetre en cliquant sur la poignee
		bind $float.$corner <ButtonPress-1> "StartDrag %W %X %Y"
		bind $float.$corner <Button1-Motion> "DragResize %W %X %Y $corner"
	}
	# placer les poignees. On utilise ici le gestionnaire de geometrie "place"
	# qui permet de positionner les widgets de facon absolue ou relative par
	# rapport a leurs parents. Ici on utilise le placement relative (-relx, -rely)
	# et le point d'ancrage (-anchor) pour que les poignees restent aux 4 coins.
	# voir la description de 'place' dans la documentation Tcl pour plus de precisions.
	place $float.nw -anchor nw -relx 0.0 -rely 0.0
	place $float.sw -anchor sw -relx 0.0 -rely 1.0
	place $float.ne -anchor ne -relx 1.0 -rely 0.0
	place $float.se -anchor se -relx 1.0 -rely 1.0
}

# creer un bouton pour quitter
# l'application quitte lorsqu'elle n'a plus de fenetres.
button .quit -text "Quitter" -command {destroy .}

# afficher les boutons
foreach button {.new .quit} {
	pack $button -side top -padx 10 -pady 10
}

