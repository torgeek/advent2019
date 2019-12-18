Class kuznetsov.Advent2019.Base
{

Parameter Folder = "/irisdev/app/";

ClassMethod GetInput(fileName As %String) As %Stream
{
    set filePathAndName = ..#Folder_fileName
    set stream = ##Class(%Stream.FileCharacter).%New()
    set sc = stream.LinkToFile(filePathAndName)
    return stream
}

}
