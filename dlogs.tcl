#!env wish
# ----------------------------------------------------------------------------
# Boites de message et de progression
#
# Michel Beaudouin-Lafon
# Nov, 1997
#
# mailto:mbl@lri.fr
# http://www-ihm.lri.fr/~mbl/
# ----------------------------------------------------------------------------

# --- UniqueWidgetName root
#	crée un nom unique de widget
# parametres
#	root	nom de widget que l'on veut rendre unique
# valeur de retour
#	nom unique de widget
#
proc UniqueWidgetName {root} {
	# ajouter un numero a la fin du nom jusqu'a ce que la fenetre n'existe pas
	set i 0
	while [winfo exist $root$i] {
		incr i
	}
	return $root$i
}

# --- Message msg
#	affiche une boîte d'information
# parametre
#	msg	message à afficher
# valeure de retour
#	aucune
#
proc Message {msg} {
	# creer la fenetre et lui donner un titre
	set top [toplevel [UniqueWidgetName .msg]]
	wm title $top Message
	# creer le message et le bouton OK
	label $top.msg -text $msg
	button $top.ok -text OK -command "destroy $top"
	# placer les elements
	pack $top.msg -side top -fill both -expand on -padx 5 -pady 5
	pack $top.ok -side right -anchor s -padx 5 -pady 5
	# attendre que l'on clique dans le bouton OK
	tkwait window $top
}

# --- NewProgress msg size
#	cree une boite de progression
# parametres
#	msg	message
#	size	valeur finale de la progression
# valeur de retour
#	nom de la fenetre
#
proc NewProgress {msg size} {
	# creer la fenetre et lui donner un titre
	set top [toplevel [UniqueWidgetName .progress]]
	wm title $top Progression
	# creer le message et la barre
	label $top.msg -text $msg
	scale $top.progress -orient horiz -from 0 -to $size -showvalue off
	$top.progress set 0
	# s'assurer que la barre de defilement ne peut etre manipulee par l'utilisateur
	bindtags $top.progress {}
	# placer les elements
	pack $top.msg -side top -fill both -expand on -padx 5 -pady 5
	pack $top.progress -side top -fill x -padx 5 -pady 5
	
	return $top
}

# --- Progress w incr
#	fait avancer une boîte de progression
# parametre
#	w	fenetre de progression
#	incr	valeur de l'avancement
# valeur de retour
#	nouvelle valeur de la progression
#
proc Progress {w incr} {
	set val [expr [$w.progress get] + $incr]
	$w.progress set $val
	return $val
}

# --- DoneProgress w
#	detruit une barre de progression
# parametre
#	w	fenetre de progression
# valeur de retour
#	aucune
#
proc DoneProgress {w} {
	destroy $w
}

# -------- test

Message "File system is full"

# progression automatique d'une barre de progression
proc Avancer {p} {
	if {[Progress $p 15] > 200} {
    exit
#		destroy $p
	} else {
		after 250 "Avancer $p"
	}
}

set p [NewProgress "Lecture de fichier" 200]
Avancer $p
