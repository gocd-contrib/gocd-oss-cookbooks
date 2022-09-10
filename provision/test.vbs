Set application = WScript.CreateObject("Shell.Application")
Set fileSystemObject = WScript.CreateObject("Scripting.FileSystemObject")

Set pathNameSpace = application.NameSpace(fileSystemObject.GetAbsolutePathName(WScript.Arguments.item(0)))
Set pathNameSpace = application.NameSpace(fileSystemObject.GetAbsolutePathName(path))
Set destinationPathNameSpace = application.NameSpace(fileSystemObject.GetAbsolutePathName("."))

destinationPathNameSpace.CopyHere pathNameSpace.items, 4 + 16
