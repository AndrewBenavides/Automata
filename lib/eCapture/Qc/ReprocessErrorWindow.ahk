#Include .\lib\BasicControls\Controls.ahk

class ReprocessErrorWindow {
	__New(wait = 30) {
		winTitle := "Reprocess Error" 
		winText := "Exception --->"
		WinWait, % winTitle, % winText, % wait
		windowId := WinExist(winTitle, winText)
		if windowId {
			this.WindowId := "ahk_id " . windowId
			this.Exists := true
			
			this.Label := new Label(this.WindowId, "Static2")
			this.YesButton := new Button(this.WindowId, "Button1")
			this.NoButton := new Button(this.WindowId, "Button2")
		} else {
			this.Exists := false
		}
	}
	
	Dismiss() {
		while WinExist(this.WindowId) {
			this.YesButton.Click()
			Sleep 25
		}
	}
}