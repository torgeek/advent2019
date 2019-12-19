Class kuznetsov.Advent2019.Day7 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input7.txt";

// w ##class(kuznetsov.Advent2019.Day7).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.instructionSet) // instructionSet As %String
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        
        // Part 1/2
        if verbose { w !, "Part 1/2 result: ", ! }
        set sc = ..ParseFromString(.instructionSet, .count, .codeSet)

        set highestSignal = 0
        for i = 0:1:4 {
            for j = 0:1:4 {
                if j = i continue
                for l = 0:1:4 {
                    if l = j continue 
                    if l = i continue
                    for k = 0:1:4 {
                        if k = l continue
                        if k = j continue
                        if k = i continue
                        for m = 0:1:4 {
                            if m = i continue
                            if m = j continue
                            if m = k continue
                            if m = l continue

                            set phase(0) = i
                            set phase(1) = j
                            set phase(2) = l
                            set phase(3) = k
                            set phase(4) = m

                            set out = 0
                            for amp = 0:1:4 {
                                merge codeSetCopy = codeSet
                                set in(1) = phase(amp)
                                set in(2) = out
                                set sc = ..CodeRun(.codeSetCopy, count, .in, verbose, .out)
                            }
                            if highestSignal < out { set highestSignal = out}
                        }
                    }
                }
            }
        }
        w "highest signal: "_ highestSignal, !
        // Part 2/2 
        #; if verbose { w !, "Part 2/2 result: ", ! }
        #; set sc = ..ParseFromString(.instructionSet, .count, .codeSet)
        #; set input = 2
        #; set sc = ..CodeRun(.codeSet, count, input, verbose)

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
        // i-1 instruction counter starts from zero
        set codeArray(i-1) = $PIECE(codeString, ",", i) 
    }
    return $$$OK
}

ClassMethod CodeRun(codeSet, count, inputs, verbose = 0, outputs) As %Status
{
    set relativeBase = 0 // variable pointer
    set op = 0 // operations counter 
    set pNum = 0 // parameter number
    set inputsCounter = 1

    for {
        // decoding the operation code and the number of its parameters 
        set opCode = codeSet(op) # 100

        if verbose { w op _ " code: "_ codeSet(op) _" op: "_ opCode }
        
        if opCode = 99 { 
            if verbose { w !, "HALT ", ! } 
            set outputs = out
            return $$$OK 
        }

        if opCode = 3 { 
            set in = inputs(inputsCounter)
            set inputsCounter = inputsCounter + 1
        }
        
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

        if verbose { w " pNum: "_ pNum } 

        // decode mode for each parameter: 0 == position, 1 == immediate, 2 == relative
        for i = 1:1:pNum {
            set k = 10 ** (i + 1)
            set pMode(i) = (codeSet(op) - (codeSet(op) # k)) / k # 10 
        }

        if verbose { for i = 1:1:pNum { w " p"_ i _": "_ pMode(i) } } 
        
        // decoding of the actual parameter addresses of the operation
        for j = 1:1:pNum {
            if pMode(j) = 0 { set pAddr(j) = codeSet(op+j) }
            elseif pMode(j) = 1 { set pAddr(j) = op+j }
            elseif pMode(j) = 2 { set pAddr(j) = codeSet(op+j) + relativeBase }
            else { return 0 }
        }  
        
        if verbose { 
            #; for i = 1:1:pNum { w " A"_ i _": "_ pAddr(i) _":"_ codeSet(pAddr(i)) }
            w !
        }

        set op = op + pNum + 1 // next instruction, some operations may change it

        do $case( opCode, 
            1: ..Add(.codeSet, .pAddr),
            2: ..Mul(.codeSet, .pAddr),
            3: ..Input(.codeSet, .pAddr, in),
            4: ..Outputs(.codeSet, .pAddr, .out),
            5: ..JumpIfTrue(.codeSet, .pAddr, .op),
            6: ..JumpIfFalse(.codeSet, .pAddr, .op),
            7: ..LessThan(.codeSet, .pAddr),
            8: ..equals(.codeSet, .pAddr),
            9: ..AdjustsRelativeBase(.codeSet, .pAddr, .relativeBase),
            : ..UnknownOp(opCode, op)
        )
    }

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

ClassMethod Input(codeSet, pAddr, input) As %Status
{
    #; read input
    #; w !
    set codeSet(pAddr(1)) = input
    return $$$OK
}

ClassMethod Outputs(codeSet, pAddr, outputs) As %Status
{
    set outputs = codeSet(pAddr(1))
    #; w ": "_ outputs, !
    return $$$OK
}

ClassMethod JumpIfTrue(codeSet, pAddr, op) As %Status
{
    if codeSet(pAddr(1)) '= 0 { set op = codeSet(pAddr(2)) }
    return $$$OK
}

ClassMethod JumpIfFalse(codeSet, pAddr, op) As %Status
{
    if codeSet(pAddr(1)) = 0 { set op = codeSet(pAddr(2)) }
    return $$$OK
}

ClassMethod LessThan(codeSet, pAddr) As %Status
{
    if codeSet(pAddr(1)) < codeSet(pAddr(2)) { 
        set codeSet(pAddr(3)) = 1 
    }
    else { set codeSet(pAddr(3)) = 0 }
    
    return $$$OK
}

ClassMethod equals(codeSet, pAddr) As %Status
{
    if codeSet(pAddr(1)) = codeSet(pAddr(2)) { 
        set codeSet(pAddr(3)) = 1 
    }
    else { set codeSet(pAddr(3)) = 0 }

    return $$$OK
}

ClassMethod AdjustsRelativeBase(codeSet, pAddr, relativeBase) As %Status
{
    set relativeBase = relativeBase + codeSet(pAddr(1))
    return $$$OK
}

}
