GetControlHwnd(windowId, controlClass) {
	ControlGet, controlHwnd, Hwnd, , % controlClass, % windowId
	controlHwnd := "ahk_id " . controlHwnd
	return controlHwnd
}

class Control {
	__New(windowId, controlClass) {
		this.WindowId := windowId
		this.ControlClass := controlClass
		this.ControlId := GetControlHwnd(this.WindowId, this.ControlClass)
		this.Extend()
	}
}

class CheckableControl extends Control {
	Get() {
		return this.IsChecked()
	}
	
	IsChecked() {
		ControlGet, state, Checked, , % this.ControlClass, % this.WindowId
		return state
	}
}

class Button extends Control {
	Click() {
		ControlClick, % this.ControlClass, % this.WindowId, , , , NA
	}
}

class CheckBox extends CheckableControl {
	Check() {
		this.Set(true)
	}

	Set(value) {
		if (value) { 
			Control, Check, , % this.ControlClass, % this.WindowId
		} else {
			Control, Uncheck, , % this.ControlClass, % this.WindowId
		}
	}
	
	Uncheck() {
		this.Set(false)
	}
}

class DropDownBox extends Control {
	Extend() {
		this.Choices := this.GetChoices()
	}
	
	FindIndex(value) {
		for key, choice in this.Choices {
			if (choice = value) {
				return key
			}
		}
		return -1
	}
	
	Get() {
		ControlGet, value, Choice, , , % this.ControlId
		return value
	}
	
	GetChoices() {
		choices := {}
		ControlGet, contents, List, , , % this.ControlId
		loop, parse, contents, `n 
		{
			index := A_Index
			choices[index] := A_LoopField
		}
		return choices
	}
	
	GetIndex() {
		;SendMessage, 0x147, 0, 0, , % this.ControlId
		;return ErrorLevel
		this.FindIndex(this.Get())
	}
	
	Set(value) {
		index := this.FindIndex(value)
		this.SetIndex(index)
	}
	
	SetIndex(index) {
		Control, Choose, % index, , % this.ControlId
	}
}

class Label extends Control {
	Get() {
		ControlGetText, value, , % this.ControlId
		return value
	}
}

class RadioButtons {
	Get() {
		for key, value in this {
			if (value.IsChecked()) {
				return key
			}
		}
	}
	
	Set(value) {
		this[value].Set()
	}
}

class RadioButton extends CheckableControl {
	Set() {
		Control, Check, , % this.ControlClass, % this.WindowId
	}
}

class TabControl extends Control {
	Count() {
		SendMessage, 0x1304,,, % this.ControlClass, % this.WindowId  ; 0x1304 is TCM_GETITEMCOUNT.
		TabCount = %ErrorLevel%
	}
	
	Get() {
		ControlGet, selected, Tab, , % this.ControlClass, % this.WindowId
		return selected
	}
	
	Set(value) {
		SendMessage, 0x1330, % value, , % this.ControlClass, % this.WindowId
		SendMessage, 0x130C, % value, , % this.ControlClass, % this.WindowId
	}
}

class TextBox extends Control {
	Get() {
		tries := 0
		value := ""
		while (tries < 5 and value = "") {
			if (tries > 0 ) {
				Sleep 50
			}
			ControlGetText, value, % this.ControlClass, % this.WindowId
			tries := tries + 1
		}
		return value
	}
	
	Set(value) {
		tries := 0
		setValue := ""
		while (tries < 5 and setValue <> value) {
			if (tries > 0) {
				Sleep 100
			}
			ControlSetText, % this.ControlClass, % value, % this.WindowId
			setValue := this.Get()
			tries := tries + 1
		}
		if (setValue <> value) {
			throw "Error: value was not able to be set."
		}
	}
}

class ToolStrip extends Control {
	Click(xCoor, yCoor) {
		ControlClick, , % this.ControlId, , , , NA X%xCoor% Y%yCoor%
	}
}