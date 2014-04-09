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

#Include .\lib\Excel\ProcessingJobTaglistLog.ahk
#Include .\lib\eCapture\Controller\Controller.ahk
#Include .\lib\eCapture\Controller\ClientManagementTreeView.ahk
#Include .\lib\eCapture\Controller\FlexProcessorOptionsWindow.ahk
#Include .\lib\eCapture\Controller\ImportFromFileWindow.ahk
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\eCapture\Controller\ProcessingJobOptionsWindow.ahk

ProcessLog() {
	MouseMove, 1, 1, 0
	controller := new Controller()
	jobLog := new JobLog()
	entries := jobLog.GetEntries()
	for key, entry in entries {
		counts := {}
		counts.File := entry.GetTaglistCount()
		if IsNumber(counts.File) {
			if (counts.File > 0) {
				custodian := TargetCustodian(controller, entry)
				if custodian.Exists {
					options := GetOptions(entry)
					processingJobWindow := custodian.NewProcessingJob()
					ConfigureProcessingJob(processingJobWindow, options)
					counts.Added := GetAddedCount()
					counts := CreateFilterAndGetCounts(counts)
					LogCount(entry, counts)
				} else {
					entry.StatusCell.Value2 := "Custodian not found."
				}
			}
		} else {
			entry.StatusCell.Value2 := fileCount
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
	client := controller.Clients[jobLog.Client]
	project := client.Projects[jobLog.Project]
	custodian := {}
	try {
		custodian := project.Custodians[entry.Custodian]
		custodian.Exists := true
	} catch ex {
		custodian.Exists := false
	}
	return custodian
}

GetOptions(entry) {
	name := entry.JobName
	filePath := entry.TaglistFullName
	selectChildren := entry.JobLog.SelectChildren
	childItemHandling := entry.JobLog.ChildItemHandling
	options := new ProcessingJobTaglistOptions(name, filePath, selectChildren, childItemHandling)
	return options
}

ConfigureProcessingJob(window, options) {
	window.Type["DataExtractImport"].Set()
	window.Name.Set(options.Name)
	window.ItemIdFilePath.Set(options.FilePath)
	window.SelectChildren.Set(options.SelectChildren)
	window.ChildItemHandling[options.ChildItemHandling].Set()
	window.OkButton.Click()
}

GetAddedCount() {
	countWdw := new ImportFromFileWindow()
	addedCount := countWdw.GetCount()
	return addedCount
}

CreateFilterAndGetCounts(counts) {
	OpenFilteringOptions()
	filteringCounts := CreateFilteringRules()
	counts.Parents := filteringCounts.ParentCount
	counts.Children := filteringCounts.ChildCount
	return counts
}

OpenFilteringOptions() {
	window := new ProcessingJobOptionsWindow()
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
	;Create dismiss method on base Window class?
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
	entry.TaglistCountCell.Value2 := counts.File
	entry.AddedCountCell.Value2 := counts.Added
	entry.ParentCountCell.Value2 := counts.Parents
	entry.ChildCountCell.Value2 := counts.Children

	if (counts.Parents > 0) {
		entry.StatusCell.Value2 := "Added"
	} else {
		entry.StatusCell.Value2 := "Error?"
	}
}

^+t::
	ProcessLog()