#Include .\lib\BasicControls\Controls.ahk

class LotusNotesPrintWindow {
	__New(wait = 30) {
		winTitle := "Print Document" 
		winText := "Print Tabbed Tables"
		WinWait, % winTitle, % winText, % wait
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)
		
		this.Tabs := new LotusNotesPrintWindowTabStrip(this.WindowId, "IRIS.tabs1")
		this.Tabs.SelectPageSetup()
		this.Orientation := new RadioButtons()
		this.Orientation["Portrait"] := new RadioButton(this.WindowId, "Button1")
		this.Orientation["Landscape"] := new RadioButton(this.WindowId, "Button2")
		this.Sizes := new DropDownBox(this.WindowId, "ComboBox1")
		this.ExpandAllSections := new CheckBox(this.WindowId, "Button6")
		this.Tabs.SelectPrinter()
	}
	
	BindControls() {
		this.EmailBody := new Control(this.WindowId, "NotesRichText1")
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