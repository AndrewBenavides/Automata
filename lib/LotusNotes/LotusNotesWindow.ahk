#Include .\lib\BasicControls\Controls.ahk

class LotusNotesWindow {
	__New(wait = 30) {
		winTitle := " - IBM Lotus Notes" 
		winText := "Search All Mail"
		WinWait, % winTitle, % winText, % wait
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)
	}
	
	BindControls() {
		this.EmailBody := new Control(this.WindowId, "NotesRichText1")
	}
	
	ExpandEmail() {
		this.EmailBody.Send("+{+}")
		this.EmailBody.Send("+{+}")
	}
	
	PrintEmail() {
		this.EmailBody.Send("^p")
	}
	
	WaitUntilReady() {
		attempts := 0
		item := {}
		item.ControlId := 0
		while (attempts < 30 && item.ControlId = 0) {
			try {
				item := new Control(this.WindowId, "IRIS.tedit1")
			}
			Sleep (1 + (300 * attempts))
			attempts += 1
		}
	}
}