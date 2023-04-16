#!env wish

#	   ___    0  Michel Beaudouin-Lafon        e-mail: mbl@lri.fr
#	  /   \  /   LRI - Bat 490                 www   : http://www-ihm.lri.fr/~mbl
#	 /  __/ /    Universite de Paris-Sud       voice : +33 1 69 15 69 10
#	/__   \/     91 405 ORSAY Cedex - FRANCE   fax   : +33 1 69 15 65 86
#
#	Mini-editeur de textes permettant l'experimentation de nouvelles techniques
#	d'interaction. ATTENTION - cet editeur est un prototype et ne doit pas etre
#	utilise pour editer de "vrais" textes - vous risquez de perdre des donnees !
#
#	La boite "Find" est un instrument de recherche : au fur et a mesure que l'on
#	tape du texte, toutes les occurences de ce texte apparaissent dans le texte.
#
#	La commande Outline ajoute un bouton en tete de la procedure Tcl dans laquelle
#	est le curseur. Ce bouton permet de montrer/cacher le texte de la procedure.


# ---- faire le menage en cas de re-chargement
catch {font delete textFont}
catch {eval destroy [winfo children .]}
catch {unset HiddenText}

# ---- creer la fenetre d'edition de texte
#

font create textFont -family Courier -size 10

text .src -font textFont -width 80 -height 40 -relief sunken -yscrollcommand {.sb set}
scrollbar .sb -orient vertical -command {.src yview}

pack .src -side left -fill both -expand true
pack .sb -side left -fill y

# ---- creer la barre de menus
#
menu .bar
.bar add cascade -label Fichier -menu .bar.text
.bar add cascade -label Edition -menu .bar.edit
#.bar add cascade -label Tcl -menu .bar.tcl
. config -menu .bar

menu .bar.text
.bar.text add command -label Nouveau -command {NewText}
.bar.text add command -label Charger -command {OpenFile}
.bar.text add command -label Sauver -command {SaveFile}
.bar.text add command -label "Sauver sous" -command {SaveAs}
.bar.text add separator
.bar.text add command -label Quit -command {Quit}

menu .bar.edit
.bar.edit add command -label Couper -command {event generate <<Cut>>}
.bar.edit add command -label Copier -command {event generate <<Copy>>}
.bar.edit add command -label Coller -command {event generate <<Paste>>}
.bar.edit add separator
.bar.edit add command -label "Outline selection" -command {CreateSelectOutline}
.bar.edit add command -label "Outline Tcl proc" -command {CreateTclProcOutline}

#menu .bar.tcl
#.bar.tcl add command -label "Nouvel interpreteur" -command {NewInterp}
#.bar.tcl add command -label Evaluer -command {EvalText}
#.bar.tcl add command -label "Espionner variable" -command {SpyVar}

# ---- procedures de gestion de fichiers
#
# Attention! on ne controle pas si le fichier en cours d'edition a ete modifie...
#

set fileName ""

proc NewText {} {
	global fileName
	.src delete 1.0 end
	set fileName ""
}

proc OpenFile {} {
	global fileName
	set types {
		{{Text Files} {} TEXT}
		{{TCL Scripts} {.tcl}}
 	}
	set fileName [tk_getOpenFile -filetypes $types]
	if {$fileName == ""} return
	if [catch {open $fileName r} fd] {
		tk_messageBox -title "Erreur" -type ok -icon error -message $fd
		return
	}
	
	.src delete 1.0 end
	.src insert end [read $fd [file size $fileName]]
	close $fd
}

proc SaveFile {} {
	global fileName
	if {$fileName == ""} {
		SaveAs
		return
	}
	if [catch {open $fileName w} fd] {
		tk_messageBox -title "Erreur" -type ok -icon error -message $fd
		return
	}
	
	catch {.src delete reply.first reply.last}
	puts -nonewline $fd [.src get 1.0 end]
	close $fd
}

proc SaveAs {} {
	global fileName
	set types {
		{{Text Files} {} TEXT}
		{{TCL Scripts} {.tcl}}
 	}
	set fileName [tk_getSaveFile -filetypes $types]
	if {$fileName == ""} return
	if [catch {open $fileName w} fd] {
		tk_messageBox -title "Erreur" -type ok -icon error -message $fd
		return
	}
	
	catch {.src delete reply.first reply.last}
	puts -nonewline $fd [.src get 1.0 end]
	close $fd
}

proc Quit {} {
	destroy .
}

# --- boite de recherche
#

toplevel .find
wm title .find Find

entry .find.string
button .find.show -text Show -command {ShowFindString [.find.string get]}
button .find.reset -text Reset -command ResetFindString
bind .find.string <Key-Return> {ShowFindString [.find.string get]}

bind .find.string <Key> {AutoFind}
proc AutoFind {} {
	global findId
	after cancel AutoFind
	after 500 {ShowFindString [.find.string get]}
}

pack .find.string -side top -fill x
pack .find.show -side left -padx 5 -pady 5
pack .find.reset -side left -padx 5 -pady 5

proc ShowFindString {str} {
	set from 1.0
	
	ResetFindString
	.src tag configure found -background green
	while { [set from [.src search -exact -count length -- $str $from end]] != {} } {
		set to [.src index "$from + $length chars"]
		.src tag add found $from $to
		set from $to
	}
}

proc ResetFindString {} {
	.src tag delete found
}

# ---- mode outline
#

set wid 0

proc CreateSelectOutline {} {
	set from [.src index sel.first]
	set to [.src index sel.last]
	if [.src compare $from == $to] {
		return
	}
	CreateOutline $from $from $to
}

proc CreateTclProcOutline {} {
	set from [.src search -back -regexp -- "^proc " insert 1.0]
	set to [.src search -forw -regexp -- "^\}" insert end]
	if {$from == {} || $to == {}} {
		return
	}
	CreateOutline $from [.src index "$from lineend"] $to
}

proc CreateOutline {mark from to} {
	global wid
	incr wid
	set w [button .src.w$wid -text v -command "ToggleOutline $wid"]
	.src window create $mark -window $w
	.src mark set b$wid "$from +1char"
	.src mark set e$wid "$to + 1char"
	.src mark gravity b$wid left
	ToggleOutline $wid
}

proc ToggleOutline {wid} {
	global HiddenText
	
	if [info exists HiddenText($wid)] {
		.src insert b$wid $HiddenText($wid)
		unset HiddenText($wid)
		.src.w$wid config -text v
	} else {
		set HiddenText($wid) [.src get b$wid e$wid]
		.src delete b$wid e$wid
		.src.w$wid config -text >
	}
}
