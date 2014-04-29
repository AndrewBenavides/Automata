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
#Include .\lib\Excel\ProcessTaglistJobLog.ahk
#Include .\lib\eCapture\Controller\Controller.ahk
#Include .\lib\eCapture\Controller\ClientManagementTreeView.ahk
#Include .\lib\eCapture\Controller\FlexProcessorOptionsWindow.ahk
#Include .\lib\eCapture\Controller\ImportFromFileWindow.ahk
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\eCapture\Controller\ProcessingJobOptionsWindow.ahk
#Include .\lib\eCapture\Controller\DataExtractJobOptionsWindow.ahk

ProcessLog() {
	MouseMove, 1, 1, 0
	controller := new Controller()
	jobLog := new ProcessTaglistJobLog()
	entries := jobLog.GetEntries()
	for key, entry in entries {
		counts := {}
		counts.File := entry.GetTaglistCount()
		if IsNumber(counts.File) {
			if (counts.File > 0) {
				custodian := TargetCustodian(controller, entry)
				if custodian.Exists {
					processingJobWindow := GetNewJobWindow(entry, custodian)
					ConfigureProcessingJob(processingJobWindow, entry)
					counts.Added := GetAddedCount()
					counts := CreateFilterAndGetCounts(counts, entry)
					LogCount(entry, counts)
				} else {
					entry.StatusCell.SetAndColor("Custodian not found.", xl_Orange)
				}
			}
		} else {
			entry.StatusCell.SetAndColor(counts.File, xl_Orange)
		}
	}
}

IsNumber(num) {
	if num is number 
	{
		return true
	} else {
		return false
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

GetNewJobWindow(entry, custodian) {
	if (entry.JobType = "Processing Jobs") {
		window := custodian.NewProcessingJob()
	} else if (entry.JobType = "Data Extract Jobs") {
		window := custodian.NewDataExtractJob()
	} else {
		message := "Job Type """ . entry.JobType . " is not supported."
		throw message
	}	
	return window
}

ConfigureProcessingJob(window, entry) {
	window.Type["DataExtractImport"].Set()
	window.Name.Set(entry.JobName)
	window.ItemIdFilePath.Set(entry.TaglistFullName)
	window.SelectChildren.Set(entry.SelectChildren)
	window.ChildItemHandling[entry.ChildItemHandling].Set()
	window.OkButton.Click()
}

GetAddedCount() {
	countWdw := new ImportFromFileWindow()
	addedCount := countWdw.GetCount()
	return addedCount
}

CreateFilterAndGetCounts(counts, entry) {
	OpenFilteringOptions(entry)
	filteringCounts := CreateFilteringRules()
	counts.Parents := filteringCounts.ParentCount
	counts.Children := filteringCounts.ChildCount
	return counts
}

OpenFilteringOptions(entry) {
	if (entry.JobType = "Processing Jobs") {
		window := new ProcessingJobOptionsWindow()
	} else {
		window := new DataExtractJobOptionsWindow()
	}
	tries := 0
	filterWindow := {}
	filterWindow.Exists := false
	while (!filterWindow.Exists && tries < 5) {
		window.ManageFlexProcessorButton.Click()
		filterWindow := new FlexProcessorOptionsWindow()
		Sleep (1 + (tries * 100))
		tries += 1
	}
	window.OkButton.Click() 
}

CreateFilteringRules() {
	counts := {}
	wdw := new FlexProcessorOptionsWindow()
	wdw.CreateNewRule()
	wdw.RuleTitle.Set("Remove Duplicates")
	wdw.Action.Set("Remove")
	wdw.ProcessJobDuplicates.Check()
	wdw.DataExtractJobDuplicates.Check()
	wdw.ProcessJobDuplicatesScope.Set("Project")
	wdw.DataExtractJobDuplicatesScope.Set("Project")
	wdw.SaveRule()
	counts.ParentCount := ValidateParents(wdw)
	counts.ChildCount := ValidateChildren(wdw)
	wdw.Exit()
	return counts
}

ValidateParents(wdw) {
	itemCount := wdw.GetItemIdListCount(0)
	return itemCount
}

ValidateChildren(wdw) {
	rule := wdw.RulesList.SelectRule(1)
	if  (rule.Action = "Remove") {
		return 0
	} else {
		itemCount := wdw.GetItemIdListCount(1)
		return itemCount
	}
}

LogCount(entry, counts) {
	entry.TaglistCountCell.Set(counts.File)
	entry.AddedCountCell.Set(counts.Added)
	entry.ParentCountCell.Set(counts.Parents)
	entry.ChildCountCell.Set(counts.Children)

	if (counts.Parents > 0) {
		entry.StatusCell.SetAndColor("Added", xl_LightGreen)
	} else {
		entry.StatusCell.SetAndColor("Error?", xl_Orange)
	}
}

^+t::
	ProcessLog()