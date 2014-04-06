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
#Include .\lib\eCapture\Qc\ReprocessErrorWindow.ahk

CatchErrors() {
	loop {
		errorWindow := new ReprocessErrorWindow()
		if errorWindow.Exists {
			errorWindow.Dismiss()
			Sleep 1000
		}
	}
}

CatchErrors()