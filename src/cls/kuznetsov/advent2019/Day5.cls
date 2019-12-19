Class kuznetsov.Advent2019.Day5 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input5.txt";

// w ##class(kuznetsov.Advent2019.Day5).Run()

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
        set codeArray(i-1) = $PIECE(codeString, ",", i)
    }
    return $$$OK
}

ClassMethod CodeRun(codeSet, count, result) As %Status
{
    set relativeBase = 0
    set op = 0
    for {
        // decoding the operation code and the number of its parameters 
        set opCode = codeSet(op) # 100

        w op _ " code: "_ codeSet(op) _" op: "_ opCode
        
        if opCode = 99 return $$$OK
        
        set pNum = $case(opCode,
            1: 3,
            2: 3,
            3: 1,
            4: 1,
            5: 2,
            6: 2,
            7: 3,
            8: 3,
            9: 1,
            : ..UnknownOp(opCode, op)
        )
        if pNum = 0 return 0

        w " pNum: "_ pNum 

        // decode mode for each parameter: 0 == position, 1 == immediate, 2 == relative
        for i = 1:1:pNum {
            set k = 10 ** (i + 1)
            set pMode(i) = (codeSet(op) - (codeSet(op) # k)) / k # 10 
        }

        for i = 1:1:pNum { w " p"_ i _": "_ pMode(i) }
        #; quit 
        
        // decoding of the actual parameter addresses of the operation
        for j = 1:1:pNum {
            if pMode(j) = 0 { set pAddr(j) = codeSet(op+j) }
            elseif pMode(j) = 1 { set pAddr(j) = op+j }
            elseif pMode(j) = 2 { set pAddr(j) = codeSet(op+j) + relativeBase }
            else { return 0 }
        }  
        
        for i = 1:1:pNum { w " A"_ i _": "_ pAddr(i) _":"_ codeSet(pAddr(i)) }
        w !
        #; quit 

        if opCode = 1 { do ..Add(.codeSet, .pAddr) }
        elseif opCode = 2 { do ..Mul(.codeSet, .pAddr) }
        elseif opCode = 3 { do ..Input(.codeSet, .pAddr) }
        elseif opCode = 4 { do ..Outputs(.codeSet, .pAddr) }
        elseif opCode = 5 { do ..JumpIfTrue(.codeSet, .pAddr) }
        elseif opCode = 6 { do ..JumpIfFalse(.codeSet, .pAddr) }
        elseif opCode = 7 { do ..LessThan(.codeSet, .pAddr) }
        elseif opCode = 8 { do ..equals(.codeSet, .pAddr) }
        elseif opCode = 9 { do ..AdjustsRelativeBase(.codeSet, .pAddr, .relativeBase) }

        #; if codeSet(i) = 99 { quit }
        #; else {
        #;     do $case(codeSet(op), 
        #;         1: ..Add(.codeSet, op),
        #;         2: ..Mul(.codeSet, op),
        #;         : ..UnknownOps(.codeSet, op)
        #;     )
        #; }

        set op = op + pNum + 1
    }
    
    set result = codeSet(1)
    
    return $$$OK
}

ClassMethod UnknownOp(opCode, op) As %Status
{
    w !, "Unknown opcode "_ opCode _" in line "_ op _" Something went wrong!", !
    return 0
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
    set codeSet(pAddr(1)) = 1
    return $$$OK
}

ClassMethod Outputs(codeSet, pAddr) As %Status
{
    w codeSet(pAddr(1)), !
    return $$$OK
}

ClassMethod JumpIfTrue(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod JumpIfFalse(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod LessThan(codeSet, pAddr) As %Status
{
    set outputsData = codeSet(pAddr(1))
    return $$$OK
}

ClassMethod equals(codeSet, pAddr) As %Status
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
