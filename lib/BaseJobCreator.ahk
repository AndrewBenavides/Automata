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

#Include .\lib\eCapture\Controller\Controller.ahk
#Include .\lib\Excel\BaseJobLog.ahk

class BaseJobCreator {
	__New() {
		this.Controller := new Controller()
		this.Entries := this.Log.GetEntries()
		MouseMove, 1, 1, 0
		this.ProcessEntries()
	}
	
	__Get(key) {
		if (this.HasKey(key)) {
			return this[key]
		} else {
			throw "Key """ . key . """ does not exist in JobCreatorBase"
		}
	}
	
	ConfigureJob(window, entry) {
		throw "This method must be overridden."
	}
	
	GetNewJobWindow(custodian, entry) {
		if (entry.JobType = "Processing Jobs") {
			window := custodian.NewProcessingJob()
		} else if (entry.JobType = "Data Extract Jobs") {
			window := custodian.NewDataExtractJob()
		} else if (entry.JobType = "Discovery Jobs") {
			window := custodian.NewDiscoveryJob()
		} else {
			message := "Job Type """ . entry.JobType . """ is not supported."
			throw message
		}	
		return window
	}

	ProcessEntries() {
		for key, entry in this.Entries {
			this.ProcessEntry(entry)
		}
	}
	
	ProcessEntry(entry) {
		custodian := this.TargetCustodian(entry)
		if custodian.Exists {
			this.CreateJob(custodian, entry)
		} else {
			entry.StatusCell.SetAndColor("Custodian not found.", xl_Orange)
		}
	}
	
	TargetCustodian(entry, tries = 0) {
		client := this.Controller.Clients[entry.Client]
		project := client.Projects[entry.Project]
		custodian := {}
		try {
			custodian := project.Custodians[entry.Custodian]
			custodian.Exists := true
		} catch ex {
			if (entry.CreateCustodians && tries < 3) {
				this.CreateCustodian(project, entry)
				custodian := this.TargetCustodian(entry, tries + 1)
			} else {
				custodian.Exists := false
			}
		}
		return custodian
	}
	
	CreateCustodian(project, entry) {
		window := project.NewCustodian()
		window.CustodianName.Set(entry.Custodian)
		window.OkButton.Click()
		project.Refresh()
	}
	
	CreateJob(window, entry) {
		throw "This method must be overridden."
	}
}
