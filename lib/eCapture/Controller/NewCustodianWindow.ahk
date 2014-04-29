#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk

class NewCustodianWindow extends Window {
	SetTitle() {
		this.WinTitle := "New Custodian"
		this.WinText := "Custodian Name"
	}
	
	BindControls() {
		this.CustodianName := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf052")
		this.Description := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf051")
		this.TaskTable := this.BindDropDownbox("WindowsForms10.COMBOBOX.app.0.11ecf051")
		this.OkButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf052")
		this.CancelButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf051")
	}
}