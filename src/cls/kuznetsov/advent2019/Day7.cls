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
        set sc = ..ParseFromString(.instructionSet, .count, .codeSet)

        // Part 1/2
        #; if verbose { w !, "Part 1/2 result: ", ! }
        #; set highestSignal = 0
        #; for i = 0:1:4 {
        #;     for j = 0:1:4 {
        #;         if j = i continue
        #;         for l = 0:1:4 {
        #;             if l = j continue 
        #;             if l = i continue
        #;             for k = 0:1:4 {
        #;                 if k = l continue
        #;                 if k = j continue
        #;                 if k = i continue
        #;                 for m = 0:1:4 {
        #;                     if m = i continue
        #;                     if m = j continue
        #;                     if m = k continue
        #;                     if m = l continue

        #;                     set phase(0) = i
        #;                     set phase(1) = j
        #;                     set phase(2) = l
        #;                     set phase(3) = k
        #;                     set phase(4) = m

        #;                     set out = 0
        #;                     for amp = 0:1:4 {
        #;                         merge codeSetCopy = codeSet
        #;                         set in(1) = phase(amp)
        #;                         set in(2) = out
        #;                         set sc = ..CodeRun(.codeSetCopy, count, .in, verbose, .out)
        #;                     }
        #;                     if highestSignal < out { set highestSignal = out}
        #;                 }
        #;             }
        #;         }
        #;     }
        #; }
        #; w "highest signal: "_ highestSignal, !

        // Part 2/2 
        if verbose { w !, "Part 2/2 result: ", ! }
        
        set highestSignal = 0
        for i = 9:-1:5 {
            for j = 9:-1:5 {
                if j = i continue
                for l = 9:-1:5 {
                    if l = j continue 
                    if l = i continue
                    for k = 9:-1:5 {
                        if k = l continue
                        if k = j continue
                        if k = i continue
                        for m = 9:-1:5 {
                            if m = i continue
                            if m = j continue
                            if m = k continue
                            if m = l continue

                            set phase(0) = i
                            set phase(1) = j
                            set phase(2) = l
                            set phase(3) = k
                            set phase(4) = m

                            #; w i, j, l, k, m

                            set out = 0
                            for amp = 0:1:4 {
                                merge codeSetAmp(amp) = codeSet
                                set in = phase(amp)
                                set codeSetAmp(amp, "op") = 0
                                do ..CodeRun(amp, .codeSetAmp, count, .in, verbose, .out)
                            }

                            for {
                                do ..CodeRun(amp, .codeSetAmp, count, .in, verbose, .out, .halt)
                                if (amp = 4) && $data(halt) kill halt quit
                                set amp = (amp + 1) # 5
                                set in = out
                            }
                            
                            if highestSignal < out { 
                                set highestSignal = out
                                merge highestPhase = phase
                            }
                        }
                    }
                }
            }
        }

    }
    w highestSignal, " " 
    w highestPhase(0),highestPhase(1),highestPhase(2),highestPhase(3),highestPhase(4)
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

ClassMethod CodeRun(amp, codeSet, count, in, verbose = 0, outputs, halt) As %Status
{
    set relativeBase = 0 // variable pointer
    set op = codeSet(amp, "op") // operations counter 
    set pNum = 0 // parameter number
    set inputsCounter = 1

    for {
        // decoding the operation code and the number of its parameters 
        set opCode = codeSet(amp, op) # 100

        if verbose { w op _ " code: "_ codeSet(amp, op) _" op: "_ opCode }
        
        if opCode = 99 { 
            if verbose { w !, "HALT ", ! } 
            set outputs = out
            set halt = 1
            return $$$OK 
        }

        // input interrupt
        if (opCode = 3) && '$data(in) {
            set codeSet(amp, "op") = op
            return $$$OK
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
            set pMode(i) = (codeSet(amp, op) - (codeSet(amp, op) # k)) / k # 10 
        }

        if verbose { for i = 1:1:pNum { w " p"_ i _": "_ pMode(i) } } 
        
        // decoding of the actual parameter addresses of the operation
        for j = 1:1:pNum {
            if pMode(j) = 0 { set pAddr(j) = codeSet(amp, op+j) }
            elseif pMode(j) = 1 { set pAddr(j) = op+j }
            elseif pMode(j) = 2 { set pAddr(j) = codeSet(amp, op+j) + relativeBase }
            else { return 0 }
        }  
        
        if verbose { 
            #; for i = 1:1:pNum { w " A"_ i _": "_ pAddr(i) _":"_ codeSet(pAddr(i)) }
            w !
        }

        set op = op + pNum + 1 // next instruction, some operations may change it

        do $case( opCode, 
            1: ..Add(.codeSet, amp, .pAddr),
            2: ..Mul(.codeSet, amp, .pAddr),
            3: ..Input(.codeSet, amp, .pAddr, .in),
            4: ..Outputs(.codeSet, amp, .pAddr, .out),
            5: ..JumpIfTrue(.codeSet, amp, .pAddr, .op),
            6: ..JumpIfFalse(.codeSet, amp, .pAddr, .op),
            7: ..LessThan(.codeSet, amp, .pAddr),
            8: ..equals(.codeSet, amp, .pAddr),
            9: ..AdjustsRelativeBase(.codeSet, amp, .pAddr, .relativeBase),
            : ..UnknownOp(opCode, op)
        )
        if opCode = 4 { 
            set outputs = out
        }
    }

    return $$$OK
}

ClassMethod UnknownOp(opCode, op) As %Status
{
    w !, "Unknown opcode "_ opCode _" in line "_ op _" Something went wrong!", !
    return 0
}

ClassMethod Add(codeSet, amp, pAddr) As %Status
{
    set codeSet(amp, pAddr(3)) = codeSet(amp, pAddr(1)) + codeSet(amp, pAddr(2))
    return $$$OK
}

ClassMethod Mul(codeSet, amp, pAddr) As %Status
{
    set codeSet(amp, pAddr(3)) = codeSet(amp, pAddr(1)) * codeSet(amp, pAddr(2))
    return $$$OK
}

ClassMethod Input(codeSet, amp, pAddr, input) As %Status
{
    set codeSet(amp, pAddr(1)) = input
    kill input
    return $$$OK
}

ClassMethod Outputs(codeSet, amp, pAddr, outputs) As %Status
{
    set outputs = codeSet(amp, pAddr(1))
    return $$$OK
}

ClassMethod JumpIfTrue(codeSet, amp, pAddr, op) As %Status
{
    if codeSet(amp, pAddr(1)) '= 0 { set op = codeSet(amp, pAddr(2)) }
    return $$$OK
}

ClassMethod JumpIfFalse(codeSet, amp, pAddr, op) As %Status
{
    if codeSet(amp, pAddr(1)) = 0 { set op = codeSet(amp, pAddr(2)) }
    return $$$OK
}

ClassMethod LessThan(codeSet, amp, pAddr) As %Status
{
    if codeSet(amp, pAddr(1)) < codeSet(amp, pAddr(2)) { 
        set codeSet(amp, pAddr(3)) = 1 
    }
    else { set codeSet(amp, pAddr(3)) = 0 }
    
    return $$$OK
}

ClassMethod equals(codeSet, amp, pAddr) As %Status
{
    if codeSet(amp, pAddr(1)) = codeSet(amp, pAddr(2)) { 
        set codeSet(amp, pAddr(3)) = 1 
    }
    else { set codeSet(amp, pAddr(3)) = 0 }

    return $$$OK
}

ClassMethod AdjustsRelativeBase(codeSet, amp, pAddr, relativeBase) As %Status
{
    set relativeBase = relativeBase + codeSet(amp, pAddr(1))
    return $$$OK
}

}
