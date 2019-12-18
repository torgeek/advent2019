Class kuznetsov.Advent2019.Day2 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input2.txt";

// w ##class(kuznetsov.Advent2019.Day1).Run()

ClassMethod Run(verbose = 0) As %Status
{
    do ..ReadFromFile(.codeSet, .count)

    do ..CopyCode(.codeSet, count, .copyCodeSet)    
    do ..ProgramAlarm1202(.copyCodeSet)
    do ..CodeRun(.copyCodeSet, count, .outputValue)
    w "Value is left at position 0: "_ outputValue, !

    do ..CopyCode(.codeSet, count, .copyCodeSet)
    for i = 0:1:99 {
        for j = 0:1:99 {
            do ..CopyCode(.copyCodeSet, count, .copyCodeSetIJ)
            do ..NounAndVerbInit(.copyCodeSetIJ, i, j)
            do ..CodeRun(.copyCodeSetIJ, count, .outputValue)
            if outputValue = 19690720 {
                w "Value for i: "_ i _" j: "_ j _" "_ outputValue, !
                do ..CopyCode(.copyCodeSet, count, .copyCodeSetIJ)
                do ..NounAndVerbInit(.copyCodeSetIJ, i, j)
                do ..CodePrint(.copyCodeSetIJ, count)
                w "Answer: "_ (100 * i + j), !
            }
        }
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

    return $$$OK
}

ClassMethod ReadFromFile(codeSet, count) As %Status
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
    do ..NounAndVerbInit(.codeSet, 12, 2)
    return $$$OK
}

ClassMethod NounAndVerbInit(codeSet, noun, verb) As %Status
{
    set codeSet(1) = noun
    set codeSet(2) = verb
    return $$$OK
}

ClassMethod CodeRun(codeSet, count, result) As %Status
{
    for i = 0:4:count {
        if codeSet(i) = 1 { do ..Add(.codeSet, i) }
        elseif codeSet(i) = 2 { do ..Mul(.codeSet, i) }
        elseif codeSet(i) = 99 { quit }	
        else { w "Unknown opcode "_ codeSet(i) _" in line "_ i _"– something went wrong!", ! return }
        
        #; do $CASE(codeSet(i),
        #;     1: do ..Add(.codeSet, i),
        #;     2: do ..Mul(.codeSet, i),
        #;     99: w "The program is finished",
        #;     : w "Unknown opcode "_ codeSet(i) _" in line "_ i _"– something went wrong!"
        #; )
    }
    
    set result = codeSet(0)
    
    return $$$OK
}

ClassMethod CopyCode(codeSet, count, result) As %Status
{
    for i = 0:1:count {
        set result(i) = codeSet(i) 
    }
    return $$$OK
}

ClassMethod CodePrint(codeSet, count)
{
    for i = 0:1:count {
        w codeSet(i) _ "," 
    }
    w !
    return $$$OK
}

}
