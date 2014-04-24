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
#Include .\lib\Excel\ProcessJobLog.ahk
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\eCapture\Controller\Controller.ahk

ProcessLog() {
	MouseMove, 1, 1, 0
	controller := new Controller()
	jobLog := new ProcessJobLog()
	for key, entry in jobLog.GetEntries() {
		custodian := TargetCustodian(controller, entry)
		if custodian.Exists {
			processingJobWindow := GetNewJobWindow(jobLog, custodian)
			CreateProcessingJob(processingJobWindow, entry)
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

GetNewJobWindow(jobLog, custodian) {
	if (jobLog.JobType = "Processing Jobs") {
		window := custodian.NewProcessingJob()
	} else if (jobLog.JobType = "Data Extract Jobs") {
		window := custodian.NewDataExtractJob()
	} else {
		message := "Job Type """ . jobLog.JobType . " is not supported."
		throw message
	}	
	return window
}

CreateProcessingJob(window, entry) {
	if window.DiscoveryJobs.HasID(entry.DiscoveryJobID) {
		discoveryJob := window.DiscoveryJobs.GetByID(entry.DiscoveryJobID)
		if (discoveryJob.Name = entry.JobName) {
			window.Name.Set(entry.JobName)
			discoveryJob.Check()
			window.ShowJobOptions.Uncheck()
			window.OkButton.Click()
			entry.SetStatus("Processing Job Created.", 35)
		} else {
			entry.SetStatus("Discovery Job Name does match Process Job Name.", 46)
			window.CancelButton.Click()
		}
	} else {
		entry.SetStatus("Discovery Job ID not found.", 46)
		window.CancelButton.Click()
	}
}

^+t::
	ProcessLog()