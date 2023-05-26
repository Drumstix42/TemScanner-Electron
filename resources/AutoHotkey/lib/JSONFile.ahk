; ? https://www.autohotkey.com/boards/viewtopic.php?p=307612#p307612
class JsonFile {
    ; class JsonFile extends JSON {
    __New(filePath,saveOnExit:=""){
        If !(JSON.Load.__Class = "JSON.LOAD")
            Throw Exception("`t" A_ThisFunc "() - The JsonFile class requires that you also include the JSON.ahk library (by Coco) in your script.`n`nhttps://www.autohotkey.com/boards/viewtopic.php?t=627`nhttps://github.com/cocobelgica/AutoHotkey-JSON/blob/master/JSON.ahk" , -1)
        ObjSetBase(this.base,JSON)
        this.filePath := ComObjCreate("Scripting.FileSystemObject").GetAbsolutePathName(filePath)
    (saveOnExit ~= "^[0-9]+$")  ?  ( this.saveOnExit:=saveOnExit, OnExit(ObjBindMethod(this,"__Delete")) )
    returnObj := {}
    try returnObj := this.Load( this.OrgfileStr:=FileOpen(this.filePath,"r").Read() )
    ObjSetBase(returnObj,this)
    return returnObj
  }

  __Delete(){
    (this.saveOnExit ~= "^[0-9]+$")  ?  this.Save(this.saveOnExit)
  }

  Str(space:="",replacer:=""){
    return this.Dump(this,replacer,space)
  }

  Write(space:="",replacer:=""){
    filePath := this.base.filePath
    SplitPath, filePath,,fileDir
    If !InStr( FileExist(fileDir), "D")  ;- Create dir if it doesn't exist
      FileCreateDir, % fileDir
    try FileOpen(filePath, "w`n","UTF-8-RAW").Write( this.base.OrgfileStr:=this.Str(space,replacer) ).Close()
    catch error
      return false, errorLevel := error
    return true, errorLevel := false
  }

  Save(space:="",replacer:=""){
    If !(this.Str(space,replacer) = this.base.OrgfileStr)
      return this.Write(space,replacer)  ;, m("saved")
  }
}
