#Include .\lib\BasicControls\Controls.ahk

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
	}
	
	CreateNewRule() {
		this.Toolstrip.Click(50, 10)
	}
	
	SaveRule() {
		this.Toolstrip.Click(135, 10)
	}
	
	Exit() {
		this.Toolstrip.Click(660, 10)
	}
}