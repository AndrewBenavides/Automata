#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk

class ImportFromFileWindow extends Window {
	SetTitle() {
		this.WinTitle := "Import From File"
		this.WinText := "Total lines:"		
	}
	
	BindControls() {
		this.Count := new Label(this.WindowId, "WindowsForms10.STATIC.app.0.11ecf051")
	}
	
	GetCount() {
		value := -1
		while WinExist(this.WindowId) {
			try {
				newValue := this.ParseCount(this.Count.Get())
			}
			if (newValue > value) {
				value := newValue
			}
		}
		return value
	}
	
	ParseCount(countMessage) {
		StringSplit, arr, countMessage, :
		if (arr0 > 0) {
			value := SubStr(arr2,2)
			return value
		} else {
			return -1
		}
	}
}