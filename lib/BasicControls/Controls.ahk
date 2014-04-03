class Control {
	__New(windowId, controlClass) {
		this.WindowId := windowId
		this.ControlClass := controlClass
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
		ControlClick, % this.ControlClass, % this.WindowId
	}
}

class CheckBox extends CheckableControl {
	Set(value) {
		if (value) { 
			Control, Check, , % this.ControlClass, % this.WindowId
		} else {
			Control, Uncheck, , % this.ControlClass, % this.WindowId
		}
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