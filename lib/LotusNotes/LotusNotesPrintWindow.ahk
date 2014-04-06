#Include .\lib\BasicControls\Controls.ahk

class LotusNotesPrintWindow {
	__New(wait = 30) {
		winTitle := "Print Document" 
		winText := "Print Tabbed Tables"
		WinWait, % winTitle, % winText, % wait
		windowId := WinExist(winTitle, winText)
		if windowId {
			this.Exists := true
			this.WindowId := "ahk_id " . windowId
			
			this.Tabs := new LotusNotesPrintWindowTabStrip(this.WindowId, "IRIS.tabs1")
			this.SettingsButton := new Button(this.WindowId, "Button7")
			this.OkButton := new Button(this.WindowId, "Button21")
			
			this.Tabs.SelectPageSetup()
			this.Orientation := new RadioButtons(this.WindowId)
			this.Orientation.Add("Portrait", "Button1")
			this.Orientation.Add("Landscape", "Button2")
			this.Sizes := new DropDownBox(this.WindowId, "ComboBox1")
		this.ExpandAllSections := new CheckBox(this.WindowId, "Button6")
		} else {
			this.Exists := false
		}
	}
	
	BindControls() {
		this.EmailBody := new Control(this.WindowId, "NotesRichText1")
	}
	
	Dismiss() {
		while WinExist(this.WindowId) {
			this.OkButton.Click()
			Sleep 25
		}
	}

	PrintEmail() {
		this.EmailBody.Send("^p")
	}
	
	WaitUntilReady() {
		attempts := 0
		item := {}
		item.ControlId := 0
		while (attempts < 30 && item.ControlId = 0) {
			try {
				item := new Control(this.WindowId, "IRIS.tedit1")
			}
			Sleep (1 + (300 * attempts))
			attempts += 1
		}
	}
}

class LotusNotesPrintWindowTabStrip extends Control {
	Extend() {
		this.ToolStrip := new ToolStrip(this.WindowId, this.ControlClass)
	}
	
	SelectPrinter() {
		command := "LotusNotesPrintWindowTabStrip.SelectPrinterCommand"
		message := "Printer Tab could not be selected."
		this.Try(command, message)
	}
	
	SelectPrinterCommand() {
		this.SwitchTab(70, 10, "Print Tabbed Tables")
	}
	
	SelectPageSetup() {
		command := "LotusNotesPrintWindowTabStrip.SelectPageSetupCommand"
		message := "Page Setup Tab could not be selected."
		this.Try(command, message)
	}
	
	SelectPageSetupCommand() {
		this.SwitchTab(180, 10, "Miscellaneous")
	}
	
	SwitchTab(xCoor, yCoor, tabContent) {
		this.ToolStrip.Click(xCoor, yCoor)
		WinWait, % this.WindowId, % tabContent, 3
		WinGetText, contents, % this.WindowId
		if InStr(contents, tabContent) {
			ErrorLevel := 0
			return true
		} else {
			ErrorLevel := 1
			return false
		}
	}
}