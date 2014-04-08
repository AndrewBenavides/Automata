#Include .\lib\ex\RemoteBuf\RemoteBuf.ahk

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
	
	Send(keys) {
		this.Keys := keys
		message := "Control could not receive sent key commands."
		this.Try("Control.SendCommand", message)
	}
	
	SendCommand() {
		ControlSend, , % this.Keys, % this.ControlId
		this.Keys :=
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
		message := "Button could not be clicked."
		this.Try("Button.ClickCommand", message)
	}
	
	ClickCommand() {
		ControlClick, , % this.ControlId, , , , NA
	}
}

class CheckBox extends CheckableControl {
	Check() {
		this.Set(true)
	}

	Set(value) {
		this.SetValue := value
		message := "CheckBox could not be set."
		this.Try("CheckBox.SetCommand", message)
	}
	
	SetCommand() {
		value := this.SetValue
		if (value <> this.IsChecked()) {
			if value {
				Control, Check, , , % this.ControlId
			} else {
				Control, Uncheck, , , % this.ControlId
			}
		}
		this.SetValue :=
		return value
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
		message := "DropDownBox could not get value."
		value := this.Try("DropDownBox.GetCommand", message)
		return value
	}
	
	GetCommand() {
		ControlGet, value, Choice, , , % this.ControlId
		return value
	}
	
	GetChoices() {
		message := "DropDownBox could not get values."
		contents := this.Try("DropDownBox.GetChoicesCommand", message)
		
		choices := {}		
		loop, parse, contents, `n 
		{
			index := A_Index
			choices[index] := A_LoopField
		}
		return choices
	}
	
	GetChoicesCommand() {
		ControlGet, contents, List, , , % this.ControlId
		return contents
	}
	
	GetIndex() {
		index := this.FindIndex(this.Get())
		return index
	}
	
	Set(value) {
		if (value <> this.Get()) {
			index := this.FindIndex(value)
			this.SetIndex(index)
		
			if (value <> this.Get()) {
				throw "DropDownBox could not be set."
			}
		}
	}
	
	SetIndex(index) {
		if (index <> this.GetIndex()) {
			this.SetIndex := index
			message := "DropDownBox could not be set by index."
			this.Try("DropDownBox.SetIndexCommand", message)
		
			if (index <> this.GetIndex()) {
				throw % message
			}
		}
	}
	
	SetIndexCommand() {
		Control, Choose, % this.SetIndex, , % this.ControlId
		this.SetIndex :=
	}
}

class Label extends Control {
	Get() {
		message := "Label could not retrieve contents"
		value := this.Try("Label.GetCommand", message)
		return value
	}
	
	GetCommand() {
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
		message := "ListBox could not retrieve contents."
		contents := this.Try("ListBox.GetCommand", message)
		
		values := []
		loop, parse, contents, `n
			values[A_Index] := A_LoopField
		return values
	}
	
	GetCommand() {
		ControlGet, contents, List, , , % this.ControlId
		return contents
	}
}

class ListView extends Control {
	Get() {
		message := "ListView could not retrieve contents."
		contents := this.Try("ListView.GetCommand", message)
		
		values := []
		loop, parse, contents, `n
		{
			row := A_Index
			loop, parse, A_LoopField, %A_Tab%
				cell := A_Index
				values[row, cell] := A_LoopField
		}
		return values
	}
	
	GetCommand() {
		ControlGet, contents, List, , , % this.ControlId
		return contents
	}

	GetColumnCount() {
		message := "ListView could not retrieve column count."
		colCount := this.Try("ListView.GetColumnCountCommand", message)
		return colCount
	}
	
	GetColumnCountCommand() {
		ControlGet, colCount, List, Count Col, , % this.ControlId
		return colCount
	}
	
	GetRowCount() {
		message := "ListView could not retrieve column count."
		rowCount := this.Try("ListView.GetRowCountCommand", message)
		return rowCount
	}
	
	GetRowCountCommand() {
		ControlGet, rowCount, List, Count, , % this.ControlId
		return rowCount
	}
	
	SelectRow(index, state = true) {
		this.SelectedIndex := index
		this.SelectedState := state
		message := "ListView could not be set by index."
		this.Try("ListView.SelectRowCommand", message)
	}

	SelectRowCommand() {
		;http://www.autohotkey.com/board/topic/36781-advanced-select-row-in-external-listview/?p=322882
		;http://www.autohotkey.com/board/topic/86149-checkuncheck-checkbox-in-listview-using-sendmessage/?p=548821
		LVIF_STATE 			:= 0x8
		LVIS_CHECKED       	:= 0x2000
		LVIS_UNCHECKED     	:= 0x1000
		LVIS_STATEIMAGEMASK	:= 0xF000
		LVM_SETITEMSTATE	:= 0x102B

		index := this.SelectedIndex - 1
		state := this.SelectedState ? LVIS_CHECKED : LVIS_UNCHECKED
		
		VarSetCapacity(LVITEM, 20, 0)
		NumPut(LVIF_STATE, LVITEM,0,"UInt") ;-- mask
		NumPut(index, LVITEM,4,"Int")
		NumPut(state, LVITEM,12,"UInt")
		NumPut(LVIS_STATEIMAGEMASK, LVITEM,16,"UInt")
		RemoteBuf_Open(hLVITEM, WinExist(this.WindowId), 20)
		RemoteBuf_Write(hLVITEM, LVITEM, 20)
		SendMessage, LVM_SETITEMSTATE, index, RemoteBuf_Get(hLVITEM), , % this.ControlId
		error_level := !ErrorLevel
		RemoteBuf_Close(hLVITEM)
		
		ErrorLevel := error_level
		this.SelectedIndex :=
		this.SelectedState :=
	}
}
	
class RadioButtons {
	__New(windowId) {
		this.WindowId := windowId
	}
	
	__Get(key) {
		return this.Buttons[key]
	}
	
	Extend() {
		this.Buttons := []
	}
	
	Add(key, className) {
		this.Buttons[key] := new RadioButton(this.WindowId, className)
	}
	
	Get() {
		for key, value in this.Buttons {
			if (value.IsChecked()) {
				return key
			}
		}
	}
	
	Set(key) {
		this.Buttons[key].Set()
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
			state := true
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
		message := "TextBox could not retrieve contents."
		value := this.Try("TextBox.GetCommand", message)
		return value
	}
	
	GetCommand() {
		ControlGetText, value, , % this.ControlId
		return value
	}
	
	Set(value) {
		this.SetValue := value
		message := "TextBox was not able to set value."
		this.Try("TextBox.SetCommand", message)
		
		if (value <> this.Get()) {
			throw % message
		}
	}
	
	SetCommand() {
		ControlSetText, , % this.SetValue, % this.ControlId
		this.SetValue :=
	}
}

class ToolStrip extends Control {
	Click(xCoor, yCoor) {
		this.xCoor := xCoor
		this.yCoor := yCoor
		message := "ToolStrip could not be clicked."
		this.Try("ToolStrip.ClickCommand", message)
	}
	
	ClickCommand() {
		xCoor := this.xCoor
		yCoor := this.yCoor
		ControlClick, , % this.ControlId, , , , NA X %xCoor% Y%yCoor%
		this.xCoor :=
		this.yCoor :=
	}
}