#Include .\lib\BasicControls\Controls.ahk

class ImportFromFileWindow {
	__New() {
		wintitle := "Import From File"
		wintext := "Total lines:"
		WinWait, % wintitle, % wintext, 10
		this.WindowId := "ahk_id " . WinExist(wintitle, wintext)
		this.Count := new Label(this.WindowId, "WindowsForms10.STATIC.app.0.11ecf051")
	}
	
	GetCount() {
		value := -1
		while WinExist(this.WindowId) {
			newValue := this.ParseCount(this.Count.Get())
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