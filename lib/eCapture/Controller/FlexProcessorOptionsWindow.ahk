#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\eCapture\Controller\FlexProcessorRuleList.ahk

class FlexProcessorOptionsWindow {
	__New() {
		wintitle := "Flex Processor Rules Manager"
		wintext := "File types to be affected by this rule"
		WinWait, % wintitle, % wintext, 10
		this.WindowId := "ahk_id " . WinExist(wintitle, wintext)

		this.Toolstrip := new Toolstrip(this.WindowId, "WindowsForms10.Window.8.app.0.11ecf0512")
		this.ProcessJobDuplicates := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0513")
		this.DataExtractJobDuplicates := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0510")
		this.RuleTitle := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf053")
		this.Action := new DropDownBox(this.WindowId, "WindowsForms10.COMBOBOX.app.0.11ecf052")
		this.Scope := new DropDownBox(this.WindowId, "WindowsForms10.COMBOBOX.app.0.11ecf053")
		this.ProcessJobDuplicatesScope := new DropDownBox(this.WindowId, "WindowsForms10.COMBOBOX.app.0.11ecf055")
		this.DataExtractJobDuplicatesScope := new DropDownBox(this.WindowId, "WindowsForms10.COMBOBOX.app.0.11ecf054")
		this.RulesList := new FlexProcessorRuleList(this.WindowId, "WindowsForms10.SysTreeView32.app.0.11ecf052")
		this.Criteria := new TabControl(this.WindowId, "WindowsForms10.SysTabControl32.app.0.11ecf051")
		this.ItemIdList := new ListBox(this.WindowId, "WindowsForms10.LISTBOX.app.0.11ecf054")
	}
	
	CreateNewRule() {
		this.GetFocus(this.Toolstrip)
		preCount := this.RulesList.Count()
		postCount := preCount
		tries := 0
		while (postCount <> (preCount + 1) and tries < 10) {
			this.Toolstrip.Click(50, 10)
			tries := tries + 1
			Sleep 100
			postCount := this.RulesList.Count()
		}
		if (this.RulesList.Count() = preCount) {
			throw "Rule could not be created."
		}
		if (this.RulesList.Count() > (preCount + 1)) {
			throw "Too many rules created."
		}
	}
	
	GetFocus(focusedControl) {
		WinActivate, % this.WindowId
		WinWaitActive, % this.WindowId, , 10
		ControlFocus, , % focusedControl.ControlId
	}
	
	GetItemIdListCount(ruleIndex) {
		this.Criteria.Set(3)
		this.RulesList.SelectRule(ruleIndex)
		itemIds := this.ItemIdList.Count()
		return itemIds
	}

	Exit() {
		this.GetFocus(this.Toolstrip)
		try {
			tries := 0
			while (tries < 5) {
				this.Toolstrip.Click(660, 10)
				tries := tries + 1
				Sleep 50
			}
		}
	}
	
	SaveRule() {
		this.GetFocus(this.Toolstrip)
		tries := 0
		while (tries < 5) {
			this.Toolstrip.Click(135, 10)
			tries := tries + 1
			Sleep 50
		}
	}
}