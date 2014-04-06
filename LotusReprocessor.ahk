#NoEnv
#Warn All
SetWorkingDir %A_ScriptDir%
DetectHiddenText On
DetectHiddenWindows On
SetTitleMatchMode 2
SetTitleMatchMode Slow
SendMode Input
SetControlDelay -1
SetKeyDelay 125, 125

; Includes from lib
#Include %A_ScriptDir%
#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\eCapture\Qc\OkDonePrintingWindow.ahk
#Include .\lib\LotusNotes\LotusNotesWindow.ahk
#Include .\lib\LotusNotes\LotusNotesPrintWindow.ahk
#Include .\lib\OS\PrintSettingsWindow.ahk

ProcessNotes() {
	loop {
		okWindow := new OkDonePrintingWindow()
		if okWindow.Exists {
			try {
				lotusNotes := new LotusNotesWindow()
				lotusNotes.WaitUntilReady()
				lotusNotes.BindControls()
				lotusNotes.ExpandEmail()
				
				printWindowExists := false
				while !printWindowExists {
					lotusNotes.PrintEmail()
					printWindow := new LotusNotesPrintWindow()
					printWindowExists := printWindow.Exists
				}
				
				printWindow.Orientation.Set("Landscape")
				printWindow.ExpandAllSections.Check()
				printWindow.Sizes.Set("11x17")
				printWindow.SettingsButton.Click()
				osPrintWindow := new PrintSettingsWindow()
				osPrintWindow.Orientation.Set("Landscape")
				osPrintWindow.Sizes.Set("Tabloid, 11 x 17")
				osPrintWindow.Dismiss()
				printWindow.Dismiss()
				Sleep 1000
				okWindow.DismissAll()
			}
		}
	}
}

ProcessNotes()
	