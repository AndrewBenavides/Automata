﻿#NoEnv
#Warn All
SetWorkingDir %A_ScriptDir%
DetectHiddenText On
DetectHiddenWindows On
SetTitleMatchMode 2
SetTitleMatchMode Slow
SendMode Input
SetKeyDelay 75, 75

; Includes from lib
#Include %A_ScriptDir%
#Include .\lib\eCapture\Controller\ClientManagementTreeView.ahk
#Include .\lib\Excel\ProcessingJobTaglistLog.ahk

^+t::
	