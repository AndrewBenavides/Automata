#Include .\lib\ex\RemoteTreeView\RemoteTreeViewClass.ahk
#Include .\lib\BasicControls\Controls.ahk

class TreeView extends Control {
	__New(parent, item, init = 0) {
		if init {
			this.Construct(parent, item)
			this.Tree := new RemoteTreeView(SubStr(this.ControlId, 8))
			this.Item := this.GetRoot()
			this.Parent := 0
			this.IsLoaded := true
		} else {
			this.Item := item
			this.Parent := parent
			this.ControlId := this.Parent.ControlId
			this.WindowId := this.Parent.WindowId
			this.Tree := this.Parent.Tree
			this.IsLoaded := false
		}
	}
	
	Collapse() {
		this.Expand(false)
		this.Items := []
		this.IsLoaded := false
	}
		
	Expand(do = true) {
		this.Expanding := do
		message := "TreeView could not be expanded."
		this.Try("TreeView.ExpandCommand", message)
	}
	
	ExpandCommand() {
		this.Tree.Expand(this.Item, this.Expanding)
		ErrorLevel := (ErrorLevel <> "FAIL" || ErrorLevel <> 0) ? 0 : 1
	}
	
	Item(key) {
		if !this.ItemExists(key)
			throw "Key """ . key . """ does not exist in dictionary."
		return this.Items[key]
	}
	
	ItemExists(key) {
		if !this.IsLoaded
			this.Load()
		exists := this.Items.HasKey(key)
		return exists
	}
	
	GetChildren() {
		message := "TreeView could not retrieve children."
		children := this.Try("TreeView.GetChildrenCommand", message)
		return children
	}
	
	GetChildrenCommand() {
		if this.Parent <> 0
			this.Expand()
		children := []
		item := this.Tree.GetChild(this.Item)
		while (item <> 0 && item <> "FAIL") {
			child := new TreeView(this, item)
			children[item] := child
			item := this.Tree.GetNext(item)
		}
		ErrorLevel := (item <> "FAIL") ? 0 : 1
		return children
	}

	GetRoot() {
		message := "TreeView could not retrieve root."
		root := this.Try("TreeView.GetRootCommand", message)
		return root
	}
	
	GetRootCommand() {
		root := this.Tree.GetRoot()
		ErrorLevel := (ErrorLevel <> "FAIL") ? 0 : 1
	}

	GetText() {
		message := "TreeView could not retrieve text."
		value := this.Try("TreeView.GetTextCommand", message)
		return value
	}
	
	GetTextCommand() {
		value := this.Tree.GetText(this.item)
		ErrorLevel := (ErrorLevel <> "FAIL") ? 0 : 1
		return value
	}
	
	Load() {
		this.Expand()
		this.Items := this.GetChildren()
		this.IsLoaded := true
	}
}