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

CreateDeduplicationRule() {
	wdw := new FlexProcessorOptionsWindow()
	wdw.CreateNewRule()
	wdw.RuleTitle.Set("Remove Duplicates")
	wdw.Action.Set("Remove")
	wdw.ProcessJobDuplicates.Check()
	wdw.DataExtractJobDuplicates.Check()
	wdw.ProcessJobDuplicatesScope.Set("Project")
	wdw.DataExtractJobDuplicatesScope.Set("Project")
	wdw.SaveRule()
	wdw.Exit()
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
	