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
#Include .\lib\Excel\ProcessingJobTaglistLog.ahk

ProcessLog() {
	ecaptureController := new Controller()
	jobLog := new JobLog()
	entries := jobLog.GetEntries()
	for key, value in entries {
		fileCount := value.GetTaglistCount()
		if fileCount is number 
		{
			if (fileCount > 0) {
				name := value.JobName
				filePath := value.TaglistFullName
				selectChildren := value.JobLog.SelectChildren
				childItemHandling := value.JobLog.ChildItemHandling
				options := new ProcessingJobTaglistOptions(name, filePath, selectChildren, childItemHandling)
				
				client := ecaptureController.Clients[jobLog.Client]
				project := client.Projects[jobLog.Project]
				if (project.Custodians.Exists(value.Custodian)) {
					custodian := project.Custodians[value.Custodian]
					addedCount := custodian.NewProcessingJobTaglist(options)
					counts := CreateDeduplicationRule()
					
					value.TaglistCountCell.Value2 := fileCount
					value.AddedCountCell.Value2 := addedCount
					value.ParentCountCell.Value2 := counts.ParentCount
					value.ChildCountCell.Value2 := counts.ChildCount
					if (counts.ParentCount > 0) {
						value.StatusCell.Value2 := "Added"
					} else {
						value.StatusCell.Value2 := "Error?"
					}
				} else {
					value.StatusCell.Value2 := "Custodian not found."
				}
			}
		} else {
			value.StatusCell.Value2 := fileCount
		}
	}
}

CreateDeduplicationRule() {
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

^+t::
	ProcessLog()