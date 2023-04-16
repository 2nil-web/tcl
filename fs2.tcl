#!env wish

# Procedure appelee pour remplir la liste de fichiers
proc FileOpen_Update {widget newpath} {
    catch {cd $newpath}

    $widget.files delete 0 end
    foreach f [lsort [glob -nocomplain *]] {
	if [file isdirectory $f] {
		append f /
	}
	$widget.files insert end $f
    }

    # mettre a jour le menu du directory courant
    global FileOpen_CurDir
    
    $widget.dir.menu delete 0 end
    set path [file split [pwd]]
    set FileOpen_CurDir [lindex $path end]
    set path [lreplace $path end end]
    set curpath {}
    foreach dir $path {
	lappend curpath $dir
	$widget.dir.menu insert 0 command -label $dir \
		-command [list FileOpen_Update $widget [eval file join $curpath]]
    }
}

# Procedure appelee pour terminer le dialogue
proc FileOpen_Done {widget} {
    destroy $widget	
}

# Procedure appelee lorsqu'on clique sur Open
proc FileOpen_Open {widget} {
    global FileOpen_Value

    set f [$widget.files get [$widget.files curselection]]
    if [file isdirectory $f] {
	FileOpen_Update $widget $f
    } else {
	global FileOpen_File
	set FileOpen_File [file join [pwd] $f]
	FileOpen_Done $widget
    }
}

# ------------------------------------------------------------------------
# Cree une fenetre independante avec les differents elements necessaires
# pour la selection d'un fichier

proc FileOpen {filesel msg dir} {
	# Cree la fenetre et lui donne un titre
	toplevel $filesel
	wm title $filesel "File opener ..."

	# Cree le message
	label $filesel.msg -text $msg
	pack $filesel.msg -side top -padx 5 -pady 5 -anchor w

	# Cree le menu du directory courant
	menubutton $filesel.dir -menu $filesel.dir.menu -textvariable FileOpen_CurDir
	menu $filesel.dir.menu
	pack $filesel.dir -side top -padx 5 -pady 5

	# Cree la listbox destinée à contenir les noms de fichier et sa scrollbar
	listbox $filesel.files  -selectmode single -yscrollcommand "$filesel.sb set"
	scrollbar $filesel.sb -orient ver -command "$filesel.files yview"
	pack $filesel.files -side left -fill both -expand on -padx 5 -pady 5
	pack $filesel.sb -side left -fill y -padx 5 -pady 5

	# Un double click est equivalent au bouton Open
	bind $filesel.files <Double-ButtonPress-1> "$filesel.open invoke"

	# Cree les boutons Open et Cancel
	button $filesel.open -text Open -command "FileOpen_Open $filesel" -width 8
	button $filesel.cancel -text Cancel -command "FileOpen_Done $filesel" -width 8
	pack $filesel.open $filesel.cancel -side bottom -fill y -padx 5 -pady 5

	# Initialise la liste de fichiers avec le répertoire courant
	set dir [pwd]
	FileOpen_Update $filesel $dir
	
	# attendre la selection
	global FileOpen_File
	set FileOpen_File {}
	tkwait window $filesel
	cd $dir
	puts $FileOpen_File
	return $FileOpen_File
}

#---- test

FileOpen .fs "Fichier a ouvrir :" [pwd]

