Class kuznetsov.Advent2019.Day2 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input4.txt";

// w ##class(kuznetsov.Advent2019.Day1).Run()

ClassMethod Run(verbose = 0) As %Integer
{
    set stream = ..GetInput(..#InputFile)
    if stream.%IsNull() { w "Panic! File " _ ..#InputFile _ " is empty!", ! }
    set i = 0
    set codeSet(0) = ""
	while 'stream.AtEnd {
		set char = stream.Read(1)
        if (char = ",") {
            set i = i + 1
            set codeSet(i) = ""
        } else {
            set codeSet(i) = codeSet(i)_char
        }
    }
    if verbose {
        for x = 0:1:i { w "code "_x_" = "_codeSet(x), ! }
    }
    return i
}

}
