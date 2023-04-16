#!env wish
option add *MessageInfo.title "Notice" widgetDefault

class MessageInfo {
    inherit itk::Toplevel

    constructor {args} {
        itk_component add dismiss {
            button $itk_interior.dismiss -text "Dismiss"                 -command "destroy $itk_component(hull)"
        }
        pack $itk_component(dismiss) -side bottom -pady 4

        itk_component add separator {
            frame $itk_interior.sep -height 2 -borderwidth 1 -relief sunken
        }
        pack $itk_component(separator) -side bottom -fill x -padx 4

        itk_component add icon {
            label $itk_interior.icon -bitmap info
        }
        pack $itk_component(icon) -side left -padx 8 -pady 8

        itk_component add infoFrame {
            frame $itk_interior.info
        }
        pack $itk_component(infoFrame) -side left -expand yes             -fill both -padx 4 -pady 4

        itk_component add message {
            label $itk_interior.mesg -width 20
        } {
            usual
            rename -text -message message Text
        }
        pack $itk_component(message) -expand yes -fill both

        eval itk_initialize $args

        after idle [code $this centerOnScreen]
    }

    protected method centerOnScreen {} {
        update idletasks
        set wd [winfo reqwidth $itk_component(hull)]
        set ht [winfo reqheight $itk_component(hull)]
        set x [expr ([winfo screenwidth $itk_component(hull)]-$wd)/2]
        set y [expr ([winfo screenheight $itk_component(hull)]-$ht)/2]
        wm geometry $itk_component(hull) +$x+$y
    }
}

usual MessageInfo {
    keep -background -cursor -foreground -font
    keep -activebackground -activeforeground -disabledforeground
    keep -highlightcolor -highlightthickness
}

#
# EXAMPLE:  Create a notice window:
#
MessageInfo .m -message "File not found:\n/usr/local/bin/foo"
