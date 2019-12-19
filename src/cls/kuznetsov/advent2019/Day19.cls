Class kuznetsov.Advent2019.Day19 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input19.txt";

// w ##class(kuznetsov.Advent2019.Day19).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.instructionSet) // instructionSet As %String
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        set sc = ..ParseFromString(.instructionSet, .count, .codeSet) // instructionSet As %ArrayOfDT?
        // Part 1/2
        set sc = ..CodeRun(.codeSet, count, .result)
        if verbose { w ": "_ result, ! }

        // Part 2/2 
        if verbose { w ": " , ! }
    }
    return sc
}

ClassMethod ReadFromFile(string) As %Status
{
    Set sc = $$$OK
    set stream = ..GetInput(..#InputFile)
    if stream.%IsNull() { set sc = 0 }
    else {
        set string = stream.ReadLine()
    }
    return sc
}

ClassMethod ParseFromString(codeString, count, codeArray) As %Status
{
    set count = $LENGTH(codeString, ",")
    for i = 1:1:count {
        set codeArray(i) = $PIECE(codeString, ",", i)
    }
    return $$$OK
}

ClassMethod CodeRun(codeSet, count, result) As %Status
{
    set relativeBase = 0
    for i = 1:4:count {
        // decoding operations code
        // and parameter mode: 0 == position, 1 == immediate, 2 == relative
        set opCode = codeSet(i) # 100
        set pMode(1) = (codeSet(i) - (codeSet(i) # 100))/100 # 10
        set pMode(2) = (codeSet(i) - (codeSet(i) # 1000))/1000 # 10
        set pMode(3) = (codeSet(i) - (codeSet(i) # 10000))/10000 # 10

        #; w codeSet(i) _" "_ opCode _" "_ pMode(1) _" "_ pMode(2) _" "_ pMode(3), !
        #; quit 

        for j = 1:1:3 {
            if pMode(j) = 0 { set pAddr(j) = codeSet(i+j) }
            elseif pMode(j) = 1 { set pAddr(j) = i+j }
            elseif pMode(j) = 2 { set pAddr(j) = codeSet(i+j) + relativeBase }
            else { return 0 }
        }  
        
        #; w codeSet(i) _" "_ opCode _" "_ pAddr(1) _" "_ pAddr(2) _" "_ pAddr(3), !
        #; w codeSet(pAddr(1)) _" "_ codeSet(pAddr(2)) _" "_ codeSet(pAddr(3)), !
        #; quit 

        if opCode = 1 { do ..Add(.codeSet, .pAddr) }
        elseif opCode = 2 { do ..Mul(.codeSet, .pAddr) }
        elseif opCode = 3 { do ..Input(.codeSet, .pAddr) }
        elseif opCode = 4 { do ..Outputs(.codeSet, .pAddr) }
        elseif opCode = 5 { do ..OpCode5(.codeSet, .pAddr) }
        elseif opCode = 6 { do ..OpCode6(.codeSet, .pAddr) }
        elseif opCode = 7 { do ..OpCode7(.codeSet, .pAddr) }
        elseif opCode = 9 { do ..AdjustsRelativeBase(.codeSet, .pAddr, .relativeBase) }
        elseif opCode = 99 { quit }
        else { 
            w "Unknown opcode "_ opCode _" in line "_ i _"– something went wrong!", ! 
            quit 
        }

        #; if codeSet(i) = 99 { quit }
        #; else {
        #;     do $case(codeSet(i), 
        #;         1: ..Add(.codeSet, i),
        #;         2: ..Mul(.codeSet, i),
        #;         : ..UnknownOps(.codeSet, i)
        #;     )
        #; }
    }
    
    set result = codeSet(1)
    
    return $$$OK
}

ClassMethod Add(codeSet, pAddr) As %Status
{
    set codeSet(pAddr(3)) = codeSet(pAddr(1)) + codeSet(pAddr(2))
    return $$$OK
}

ClassMethod Mul(codeSet, pAddr) As %Status
{
    set codeSet(pAddr(3)) = codeSet(pAddr(1)) * codeSet(pAddr(2))
    return $$$OK
}

ClassMethod Input(codeSet, pAddr) As %Status
{
    set codeSet(pAddr(1)) = inputData
    return $$$OK
}

ClassMethod Outputs(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod OpCode5(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod OpCode6(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod OpCode7(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod AdjustsRelativeBase(codeSet, pAddr, relativeBase) As %Status
{
    set relativeBase = relativeBase + codeSet(pAddr(1))
    return $$$OK
}

}
