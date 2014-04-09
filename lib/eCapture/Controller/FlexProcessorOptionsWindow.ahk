#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk
#Include .\lib\eCapture\Controller\FlexProcessorRuleList.ahk

class FlexProcessorOptionsWindow extends Window {
	SetTitle() {
		this.WinTitle := "Flex Processor Rules Manager"
		this.WinText := "File types to be affected by this rule"
	}
	
	BindControls() {
		this.ProcessJobDuplicates := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf0513")
		this.DataExtractJobDuplicates := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf0510")
		this.RuleTitle := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf053")
		this.Action := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf052")
		this.Scope := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf053")
		this.ProcessJobDuplicatesScope := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf055")
		this.DataExtractJobDuplicatesScope := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf054")
		this.RulesList := new FlexProcessorRuleList(this.WindowId, "WindowsForms10.SysTreeView32.app.0.11ecf052")
		this.Criteria := this.BindTabControl("WindowsForms10.SysTabControl32.app.0.11ecf051")
		this.Criteria.Add(0, "General")
		this.Criteria.Add(1, "Date")
		this.Criteria.Add(2, "Search")
		this.Criteria.Add(3, "Advanced")
		this.Criteria.Set(3)
		this.ItemIdList := this.BindListBox("WindowsForms10.LISTBOX.app.0.11ecf054")
		this.Criteria.Set(0)
		this.ToolStrip := this.BindToolStrip("WindowsForms10.Window.8.app.0.11ecf0517")
	}
	
	CreateNewRule() {
		this.ToolStrip.Focus()
		preCount := this.RulesList.Count()
		postCount := preCount
		tries := 0
		while (postCount <> (preCount + 1) and tries < 10) {
			this.ToolStrip.Click(50, 20)
			tries += 1
			Sleep (1 + (tries * 100))
			postCount := this.RulesList.Count()
		}
		if (this.RulesList.Count() = preCount) {
			throw "Rule could not be created."
		}
		if (this.RulesList.Count() > (preCount + 1)) {
			throw "Too many rules created."
		}
	}
	
	GetItemIdListCount(ruleIndex) {
		this.Criteria.Set(3)
		this.RulesList.SelectRule(ruleIndex)
		itemIds := this.ItemIdList.Count()
		return itemIds
	}

	Exit() {
		this.Toolstrip.Focus()
		this.Toolstrip.Click(660, 20)
	}
	
	SaveRule() {
		this.Toolstrip.Focus()
		this.Toolstrip.Click(135, 20)
	}
}