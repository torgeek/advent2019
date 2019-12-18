Class kuznetsov.Advent2019.Day1 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input1.txt";

// w ##class(kuznetsov.Advent2019.Day1).Run()

// ClassMethod Run(fn = "input"_..#Day_".txt", verbose = 0) As %Integer

ClassMethod Run(verbose = 0) As %Integer
{
    set stream = ..GetInput(..#InputFile)
    set sum = 0
	while 'stream.AtEnd {
		set line=stream.ReadLine()
        set line = line\3 - 2
        set sum = sum + line
        if verbose w "line = "_line," ","sum = "_sum,!
    }
    return sum
}

ClassMethod Run2(verbose = 0) As %Integer
{
    set stream=..GetInput(..#InputFile)
    set sum = 0
	while 'stream.AtEnd {
		set line = stream.ReadLine()
        set fuel = line
        set full = 0
        for  {
            set fuel = fuel\3 - 2
            quit:fuel<0
            set full = full+fuel
            }  
        set sum = sum + full
        if verbose w "line = "_line, " ", "sum = "_sum, !
    }
    
    return sum
}

}
