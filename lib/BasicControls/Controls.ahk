class Control {
	__New(windowId, controlClass) {
		this.WindowId := windowId
		this.ControlClass := controlClass
		this.ControlId := this.GetControlHwnd()
		this.Extend()
	}
	
	GetControlHwnd() {
		message := "Control handle for " . this.ControlClass . " in window " . this.WindowId . " could not be found."
		handle := this.Try("Control.GetControlHwndCommand", message)
		return handle
	}
	
	GetControlHwndCommand() {
		ControlGet, controlHwnd, Hwnd, , % this.ControlClass, % this.WindowId
		if ErrorLevel {
			return false
		} else {
			return "ahk_id " . controlHwnd
		}
	}
	
	Try(functionName, errorMessage) {
		function := Func(functionName)
		if !IsFunc(function) {
			throw "Function " . functionName . " was not found."
		}
		
		value := {}
		attempts := 0
		ErrorLevel := -1
		while (attempts < 5 && ErrorLevel <> 0) {
			value := function.(this)
			Sleep (1 + (25 * attempts))
			attempts += 1
		}
		if (ErrorLevel <> 0) {
			throw % errorMessage
		}
		return value
	}
}

class CheckableControl extends Control {
	Get() {
		return this.IsChecked()
	}
	
	IsChecked() {
		message := "CheckableControl could not retrieve state"
		state := this.Try("CheckableControl.IsCheckedCommand", message)
		return state
	}
	
	IsCheckedCommand() {
		ControlGet, state, Checked, , , % this.ControlId
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
		tries := 0
		setValue := this.IsChecked()
		ErrorLevel := -1
		while (setValue <> value and tries < 5 and ErrorLevel <> 0) {
			if (value) { 
				Control, Check, , % this.ControlClass, % this.WindowId
			} else {
				Control, Uncheck, , % this.ControlClass, % this.WindowId
			}
			tries := tries + 1
			Sleep 25
			setValue := this.IsChecked()
		}
		
		if (setValue <> value) {
			throw "CheckBox could not be set"
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
		tries := 0
		ErrorLevel := -1
		while (tries < 5 and ErrorLevel <> 0) {
			ControlGet, value, Choice, , , % this.ControlId
			tries := tries + 1
			Sleep 25
		}
		if (ErrorLevel <> 0) {
			throw "DropDownBox could not get value"
		}
		return value
	}
	
	GetChoices() {
		choices := {}
		
		tries := 0
		ErrorLevel := -1
		while (tries < 5 and ErrorLevel <> 0){
			ControlGet, contents, List, , , % this.ControlId
			tries := tries + 1
		}
		
		loop, parse, contents, `n 
		{
			index := A_Index
			choices[index] := A_LoopField
		}
		return choices
	}
	
	GetIndex() {
		index := this.FindIndex(this.Get())
		return index
	}
	
	Set(value) {
		selected := this.Get()
		tries := 0
		while (selected <> value and tries < 5) {
			index := this.FindIndex(value)
			this.SetIndex(index)
			selected := this.Get()
			tries := tries + 1
		}
		if (selected <> value) {
			throw "DropDownBox could not be set."
		}
	}
	
	SetIndex(index) {
		selected := this.GetIndex()
		tries := 0
		ErrorLevel := -1
		while (selected <> index and tries < 5 and ErrorLevel <> 0) {
			Control, Choose, % index, , % this.ControlId
			selected := this.GetIndex()
			tries := tries + 1
		}
		if (selected <> index) {
			throw "DropDownBox could not be set by index."
		}
	}
}

class Label extends Control {
	Get() {
		ControlGetText, value, , % this.ControlId
		return value
	}
}

class ListBox extends Control {
	Count() {
		i := 0
		for item in this.Get() {
			i := A_Index
		}
		return i
	}
	
	Get() {
		contentsList := []
		tries := 0
		contents := ""
		ErrorLevel := -1
		while (contents = "" and tries < 5 and ErrorLevel <> 0) {
			ControlGet, contents, List, , % this.ControlClass , % this.WindowId
			;this.ControlId doesn't seem to work. It's probably non-existent
			;when the handle is fetched
			tries := tries + 1
			if (tries > 1) {
				Sleep 25
			}
		}
		if (ErrorLevel <> 0) {
			throw "ListBox could not retrieve contents."
		}
		loop, parse, contents, `n
		{
			contentsList[A_Index] := A_LoopField
		}
		return contentsList
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
		message := "RadioButton could not be set."
		state := this.Try("RadioButton.SetCommand", message)
		return state
	}
	
	SetCommand() {
		state := this.IsChecked()
		if (state = false) {
			Control, Check, , , % this.ControlId
			state := this.IsChecked()
		} 
		return state
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
		tries := 0
		ErrorLevel := -1
		while (tries < 5 and ErrorLevel <> 0) {
			ControlClick, , % this.ControlId, , , , NA X%xCoor% Y%yCoor%
			tries := tries + 1
		}
		if (ErrorLevel <> 0) {
			throw "ToolStrip could not be clicked."
		}
	}
}