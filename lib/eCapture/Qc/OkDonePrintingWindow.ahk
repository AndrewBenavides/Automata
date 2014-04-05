#Include .\lib\BasicControls\Controls.ahk

class OkDonePrintingWindow {
	__New() {
		this.WinTitle := "ahk_class #32770" 
		this.WinText := "Press OK when you are done printing"
		WinWait, % this.WinTitle, % this.WinText, 30
		windowId := WinExist(this.WinTitle, this.WinText)
		if windowId {
			this.WindowId := "ahk_id " . windowId
		
			this.OkButton := new Button(this.WindowId, "Button1")
			this.Exists := true
		} else {
			this.Exists := false
		}
	}
	
	Dismiss() {
		while WinExist(this.WindowId) {
			this.OkButton.Click()
			Sleep 25
		}
	}
	
	DismissAll() {
		windowId := WinExist(this.WinTitle, this.WinText)
		while windowId {
			okButton := new Button("ahk_id " . windowId, "Button1")
			okButton.Click()
			Sleep 25
			windowId := WinExist(this.WinTitle, this.WinText)
		}
	}
}