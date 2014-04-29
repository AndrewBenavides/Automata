#Include .\lib\BasicControls\Controls.ahk

class DiscoveryJobListView extends ListView {
	Extend() {
		values := {}
		for i, row in this.Get() {
			entry := new DiscoveryJobListViewEntry(this, row, i)
			values[entry.ID] := entry
		}
		this.Values := values
	}
	
	GetByID(jobId) {
		exists := this.Values.HasKey(jobId)
		if (!exists) {
			throw "DiscoveryJobID " . jobId . " does not exist."
		}
		return this.Values[jobId]
	}
	
	CheckAll() {
		this.SelectAll(true)
	}
	
	HasID(jobId) {
		exists := this.Values.HasKey(jobId)
		return exists
	}
	
	SelectAll(state = true) {
		this.SelectRow(0, state)
	}
	
	UncheckAll() {
		this.SelectAll(false)
	}
}

class DiscoveryJobListViewEntry {
	__New(listViewParent, listViewItem, listViewRowNumber) {
		this.ListView := listViewParent
		this.Row := listViewRowNumber
		this.ID := listViewItem[1]
		this.Name := listViewItem[2]
		this.Status := listViewItem[3]
		this.Description := listViewItem[4]
		this.Items := listViewItem[5]
		this.DateCreated := listViewItem[6]
	}
	
	Check() {
		this.Select(true)
	}

	Select(state = true) {
		this.ListView.SelectRow(this.Row, state)
	}
	
	Uncheck() {
		this.Select(false)
	}
}