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
#Include .\lib\eCapture\Controller\ClientManagementTreeView.ahk
#Include .\lib\Excel\DiscoveryJobLog.ahk
#Include .\lib\eCapture\Controller\NewDiscoveryJobWindow.ahk
#Include .\lib\eCapture\Controller\Controller.ahk

ProcessLog() {
	MouseMove, 1, 1, 0
	controller := new Controller()
	jobLog := new DiscoveryJobLog()
	for key, entry in jobLog.GetEntries() {
		custodian := TargetCustodian(controller, entry)
		if custodian.Exists {
			window := custodian.NewDiscoveryJob()
			CreateJob(window, entry)
		} else {
			entry.SetStatus("Custodian does not exist.", 46)
		}
	}
}

TargetCustodian(controller, entry) {
	client := controller.Clients[entry.Client]
	project := client.Projects[entry.Project]
	custodian := {}
	try {
		custodian := project.Custodians[entry.Custodian]
		custodian.Exists := true
	} catch ex {
		custodian.Exists := false
	}
	return custodian
}

CreateJob(window, entry) {
	if PathExists(entry.Path) {
		window.JobName.Set(entry.JobName)
		window.Description.Set(entry.Description)
		window.AddDirectory(entry.Path)
		window.CreateDtSearchIndex.Uncheck()
		window.ShowJobOptions.Uncheck()
		window.OkButton.Click()
		entry.SetStatus("Discovery Job created.", 35)
	} else {
		entry.SetStatus("Path does not exist.", 46)
		window.CancelButton.Click()
	}
}

PathExists(path) {
	FileGetAttrib, attrib, % path
	exists = (InStr(attrib, "D")) ? true : false
	return exists
}

^+t::
	ProcessLog()