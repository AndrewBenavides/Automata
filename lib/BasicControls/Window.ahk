#Include .\lib\BasicControls\Controls.ahk

class Window {
	__New(wait = 30) {
		this.SetTitle()
		this.SetHandle(wait)
		this.BindControls()
		this.Extend()
	}
		
	BindButton(controlClass) {
		return new Button(this.WindowId, controlClass)
	}
	
	BindCheckBox(controlClass) {
		return new CheckBox(this.WindowId, controlClass)
	}
	
	BindControl(controlClass) {
		return new Control(this.WindowId, controlClass)
	}
	
	BindDropDownBox(controlClass) {
		return new DropDownBox(this.WindowId, controlClass)
	}
	
	BindLabel(controlClass) {
		return new Label(this.WindowId, controlClass)
	}
	
	BindListBox(controlClass) {
		return new ListBox(this.WindowId, controlClass)
	}
	
	BindListView(controlClass) {
		return new ListView(this.WindowId, controlClass)
	}
	
	BindRadioButtons() {
		return new RadioButtons(this.WindowId)
	}
	
	BindTabControl(controlClass) {
		return new TabControl(this.WindowId, controlClass)
	}
	
	BindTextBox(controlClass) {
		return new TextBox(this.WindowId, controlClass)
	}
	
	BindToolStrip(controlClass) {
		return new ToolStrip(this.WindowId, controlClass)
	}
	
	SetHandle(wait) {
		WinWait, % this.WinTitle, % this.WinText, % wait
		windowId := WinExist(this.WinTitle, this.WinText)
		if windowId {
			this.WindowId := "ahk_id " . windowId
			this.Exists := true
		} else {
			this.Exists := false
		}
	}
}