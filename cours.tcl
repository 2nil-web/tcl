#!env wish

#
#	   ___    0  Michel Beaudouin-Lafon        e-mail: mbl@lri.fr
#	  /   \  /   LRI - Bat 490                 www   : http://www-ihm.lri.fr/~mbl
#	 /  __/ /    Universite de Paris-Sud       voice : +33 1 69 15 69 10
#	/__   \/     91 405 ORSAY Cedex - FRANCE   fax   : +33 1 69 15 65 86
#
#	interface permettant de tester Tcl et Tk interactivement
#	Une fenetre principale permet de saisir un script.
#	Un bouton ou une combinaison de touches permet d'evaluer le script
#	dans un second interpreteur.

# detruire eventuellement ce qui est deja dans l'interface
catch {eval destroy [winfo children .]}

# procedure pour charger une fonte
proc GetFont {family size} {
	return [font create -family $family -size $size]
}

# l'interface principale est constituee d'une zone texte, d'une barre de defilement
# et de quelque boutons
#
frame .bar
text .src -font [GetFont Helvetica 18] -width 50 -height 20 -yscrollcommand {.sb set}
scrollbar .sb -orient vertical -command {.src yview}
.src tag configure reply -foreground blue
bind .src <Control-w> {.bar.clear invoke}
bind .src <Control-x> {.bar.clear invoke}
bind .src <Control-e> {.bar.eval invoke}
bind .src <Shift-Return> {.bar.eval invoke}
bind .src <Control-o> {.bar.open invoke}
bind .src <Control-s> {.bar.save invoke}

pack .bar -side bottom -fill x
pack .src -side left -fill both -expand true
pack .sb -side left -fill y

button .bar.clear -text Clear -command {.src delete 1.0 end}
button .bar.eval -text Eval -command Eval
button .bar.spyvar -text "Spy var." -command "test eval SpyVariable"
button .bar.interp -text "New Interp" -command NewInterp
button .bar.open -text Open -command OpenFile
button .bar.save -text Save -command SaveFile

foreach button {clear eval spyvar interp open save} {
	pack .bar.$button -side left -padx 5 -pady 5
}

#----------
# la variable InterpStuff contient un script a executer dans le second
# interpreteur lorsque celui-ci est cree.
# le script contient les fonctionnalites de debugging.

set InterpStuff {
set varNo 0

proc GetFont {family size} {
	return [font create -family $family -size $size]
}

# cette procedure cree une fenetre affichant le contenu de la variable var.
# la variable var est definie comme la valeur active d'un widget "label".
# Tcl se charge alors de mettre a jour le label lorsque la valeur de la variable change
# Le nom de la variable peut etre change en tapant un nouveau nom
# suivi de return.
#
proc SpyVariable {{var {}}} {
	set font [GetFont Helvetica 18]
	global varNo
	set top .var$varNo
	incr varNo
	toplevel $top
	wm title $top Variable
	entry $top.var -font $font
	if {$var == ""} {
		label $top.val -text (undef) -font $font
	} else {
		$top.var insert end $var
		label $top.val -textvariable $var -font $font
	}
	pack $top.var -side top -fill x
	pack $top.val -side top -fill both -expand true
	bind $top.var <Return> "ChangeVariable $top"
}

# procedure appelee pour changer le nom de la variable controlee.
#
proc ChangeVariable {top} {
	set var [$top.var get]
	$top.val configure -textvariable $var
}
}
#----------

# procedure appelee lorsque l'on cree un nouvel interpreteur
#
proc NewInterp {} {
	catch {interp delete test}
	interp create test
	load {} Tk test
	
	global InterpStuff
	test eval $InterpStuff
}

# procedure appelee pour faire evaluer le contenu de la fenetre texte
# par le second interpreteur
#
proc Eval {} {
	# avant evaluation on detruit les caracteres avec le tag "reply"
	# qui correspondent au resultat de l'evaluation precedente
	catch {.src delete reply.first reply.last}
	if [catch {.src get sel.first sel.last} txt] {
		set txt [.src get 1.0 end]
	}
	# le resultat de l'execution est ajoute a la fin de la fenetre,
	# avec le tag "reply"
	.src insert end \n[test eval $txt] reply
}

# procedure permettant de charger un fichier dans la fenetre principale
#
proc OpenFile {} {
	set types {
		{{Text Files} {} TEXT}
		{{TCL Scripts} {.tcl}}
 	}
	set filename [tk_getOpenFile -filetypes $types]
	if {$filename == ""} return
	if [catch {open $filename r} fd] {
		return
	}
	
	.src delete 1.0 end
	.src insert end [read $fd [file size $filename]]
	close $fd
}

# procedure permettant de sauver le contenu de la fenetre principale
# dans un fichier
#
proc SaveFile {} {
	set types {
		{{Text Files} {} TEXT}
		{{TCL Scripts} {.tcl}}
 	}
	set filename [tk_getSaveFile -filetypes $types]
	if {$filename == ""} return
	if [catch {open $filename w} fd] {
		return
	}
	
	catch {.src delete reply.first reply.last}
	puts -nonewline $fd [.src get 1.0 end]
	close $fd
}

# au lancement, on cree le second interpreteur
#
NewInterenv 
