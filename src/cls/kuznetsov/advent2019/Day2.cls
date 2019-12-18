Class kuznetsov.Advent2019.Day2 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input2.txt";

// w ##class(kuznetsov.Advent2019.Day1).Run()

ClassMethod Run(verbose = 0) As %Status
{
    do ..Read(.codeSet, .count)

    do ..ProgramAlarm1202(.codeSet)

    for i = 0:4:count {
        if codeSet(i) = 1 { do ..Add(.codeSet, i) }
        elseif codeSet(i) = 2 { do ..Mul(.codeSet, i) }
        elseif codeSet(i) = 99 { w "The program is finished", ! quit }	
        else { w "Unknown opcode "_ codeSet(i) _" in line "_ i _"– something went wrong!", ! return }
        
        #; do $CASE(codeSet(i),
        #;     1: do ..Add(.codeSet, i),
        #;     2: do ..Mul(.codeSet, i),
        #;     99: w "The program is finished",
        #;     : w "Unknown opcode "_ codeSet(i) _" in line "_ i _"– something went wrong!"
        #; )
    }

    if verbose {
        for i = 0:4:count { 
            w i _ ": " _ codeSet(i) 
            if ( i+1 <= count ) w " "_ codeSet(i+1)
            if ( i+2 <= count ) w " "_ codeSet(i+2)
            if ( i+3 <= count ) w " "_ codeSet(i+3)
            w !
        }
    }
    
    w "Value is left at position 0: "_ codeSet(0), !

    return $$$OK
}

ClassMethod Read(codeSet, count) As %Status
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
    set count = i
    return $$$OK
}

ClassMethod Add(codeSet, i) As %Status
{
    set codeSet(codeSet(i+3)) = codeSet(codeSet(i+1)) + codeSet(codeSet(i+2))
    return $$$OK
}

ClassMethod Mul(codeSet, i) As %Status
{
    set codeSet(codeSet(i+3)) = codeSet(codeSet(i+1)) * codeSet(codeSet(i+2))
    return $$$OK
}

ClassMethod ProgramAlarm1202(codeSet) As %Status
{
    set codeSet(1) = 12
    set codeSet(2) = 2
    return $$$OK
}

}
