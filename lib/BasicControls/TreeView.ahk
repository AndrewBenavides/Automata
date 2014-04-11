#Include .\lib\ex\RemoteTreeView\RemoteTreeViewClass.ahk
#Include .\lib\BasicControls\Controls.ahk

class TreeView extends Control {
	__New(parent, item, init = 0) {
		if init {
			this.Construct(parent, item)
			this.Parent := 0
			this.Tree := new RemoteTreeView(SubStr(this.ControlId, 8))
			this.Item := this.GetRoot()
		} else {
			this.Parent := parent
			this.Tree := this.Parent.Tree
			this.Item := item
			this.WindowId := this.Parent.WindowId
			this.ControlId := this.Parent.ControlId
		}
		this.IsLoaded := false
		this.ChildrenName := this.GetChildrenName()
		this[this.ChildrenName] := new TreeView.LazyDictionary(this)
	}
	
	AddChild(item) {
		child := new TreeView(this, item)
		this[this.ChildrenName][child.Item] := child
	}
		
	Child(key) {
		return this[this.ChildrenName][key]
	}

	Collapse() {
		this.Expand(false)
		this.Unload()
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
		
	GetChildrenName(name = "Children") {
		return (name <> "") ?  name : "Children"
	}

	GetRoot() {
		message := "TreeView could not retrieve root."
		root := this.Try("TreeView.GetRootCommand", message)
		return root
	}
	
	GetRootCommand() {
		root := this.Tree.GetRoot()
		ErrorLevel := (ErrorLevel <> "FAIL") ? 0 : 1
		return root
	}

	GetText() {
		message := "TreeView could not retrieve text."
		value := this.Try("TreeView.GetTextCommand", message)
		return value
	}
	
	GetTextCommand() {
		value := this.Tree.GetText(this.Item)
		ErrorLevel := (ErrorLevel <> "FAIL") ? 0 : 1
		return value
	}
	
	Load() {
		this.Expand()
		this.PopulateChildren()
		this.IsLoaded := true
	}
	
	PopulateChildren() {
		message := "TreeView could not retrieve children."
		this.Try("TreeView.PopulateChildrenCommand", message)
	}
	
	PopulateChildrenCommand() {
		if this.Parent <> 0
			this.Expand()
		item := this.Parent = 0 ? this.Item : this.Tree.GetChild(this.Item)
		while (item <> 0 && item <> "FAIL") {
			this.AddChild(item)
			item := this.Tree.GetNext(item)
		}
		ErrorLevel := (item <> "FAIL") ? 0 : 1
	}
	
	Select() {
		message := "TreeView could not select node."
		this.Try("TreeView.SelectCommand", message)
	}
	
	SelectCommand() {
		selected := this.Tree.GetSelection()
		success := true
		if (selected <> this.Item) {
			success := this.Tree.SetSelection(this.Item)
			Sleep 10
			selected := this.Tree.GetSelection()
		}
		ErrorLevel := (!success || selected <> this.Item) ? 1 : 0
	}
	
	Unload() {
		keys := []
		for key, value in this[this.ChildrenName] {
			keys[key] := key
		}
		for key, value in keys {
			this[this.ChildrenName].Remove(key)
		}
		this.IsLoaded := false
	}

	class LazyDictionary {
		__New(treeView) {
			this._ := {}
			this._.TreeView := treeView
		}
		
		__Get(key) {
			if !this._.TreeView.IsLoaded
				this._.TreeView.Load()
			if !this.HasKey(key)
				throw "Key """ . key . """ does not exist in dictionary."
			return this[key]
		}
	}
}