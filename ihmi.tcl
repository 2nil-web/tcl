#!env wish

wm title . "Fenêtre de Saisie"
label .labelNom -text "Nom"
entry .nom -width 25 -textvariable nom
label .labelPrenom -text "Prénom"
entry .prenom -width 25 -textvariable prenom
grid .labelPrenom .nom -row 0 -pady 4 -sticky e
grid .labelNom .prenom -row 1 -pady 4 -sticky e
focus .nom
bind .nom <KeyPress-Return> {focus .prenom}
