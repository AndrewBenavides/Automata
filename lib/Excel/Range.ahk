global xl_Orange := 46
global xl_LightGreen := 35
global xl_Clear := -4105

class Range {
	xlValues := -4163
	xlWhole := 1
	xlByColumns := 2
	xlNext := 1
	
	__New(worksheet, address) {
		this.Worksheet := worksheet
		this.Xl := this.Worksheet.Application
		this.Range := this.Xl.Intersect(this.Worksheet.Range(address), this.Worksheet.UsedRange)
		this.Extend()
	}
	
	Find(what) {
		cell := this.Range.Find(what, , this.xlValues, this.xlWhole, this.xlByColumns, this.xlNext, false)
		if (cell <> "") {
			firstAddress := cell.Address
			found := cell
			while true {
				cell := this.Range.FindNext(cell)
				found := this.Xl.Union(found, cell)
				if (firstAddress = cell.Address) {
					break 
				}
			} 
		}
		if (found <> "" ) {
			range := new Range(this.Worksheet, found.Address)
		} else {
			range := ""
		}
		return range
	}
	
	Get() {
		return this.Range.Value2
	}
	
	GetAll() {
		values := []
		for cell in this.Range.Cells {
			values.Add(cell.Value2)
		}
		return values
	}
	
	GetColumn() {
		return this.Range.Column
	}
	
	GetRow() {
		return this.Range.Row
	}
		
	Set(value) {
		this.Range.Value2 := value
	}
	
	SetAndColor(value, colorIndex) {
		this.Range.Value2 := value
		this.Range.Interior.ColorIndex := colorIndex
	}
}

class ColumnCollection extends Range {
	Extend() {
		this.ColumnFor := {}
		this.ValueFor := {}
		
		for cell in this.Range.Cells {
			this.ColumnFor[cell.Value2] := cell.Column
			this.ValueFor[cell.Column] := cell.Value2
		}
	}
}
