#Include .\lib\BasicControls\Controls.ahk

class PrintSettingsWindow {
	__New(wait = 30) {
		winTitle := "Properties" 
		winText := "Device Settings"
		WinWait, % winTitle, % winText, % wait
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)

		this.Sizes := new DropDownBox(this.WindowId, "ComboBox1")
		this.Orientation := new RadioButtons(this.WindowId)
		this.Orientation.Add("Portrait", "Button6")
		this.Orientation.Add("Landscape", "Button7")
		this.OkButton := new Button(this.WindowId, "Button20")
	}
	
	Dismiss() {
		while WinExist(this.WindowId) {
			this.OkButton.Click()
			Sleep 25
		}
	}
}