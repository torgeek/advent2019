/// Advent Of Code 2019 in ObjectScript
/// Author: Dmitrii Kuznetsov
Class kuznetsov.Advent2019.Day13 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input13.txt";

// w ##class(kuznetsov.Advent2019.Day13).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.instructionSet) // instructionSet As %String
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {

        // Part 1/2
        if verbose { w !, "Part 1/2 result: ", ! }
        set sc = ..ParseFromString(.instructionSet, .count, .codeSet)
        
        set hart = 1 // thread number
        merge code(hart) = codeSet // thread codebase
        set code(hart, "op") = 0 // 1st instruction adress
        set in = 0
        set triples = 0 // for day13
        set blockTileCount = 0 // for day13 part1/2

        for {
            set sc = ..CodeRun(hart, .code, count, verbose, in, .out, .irq)
            if irq = "halt" { quit }
            elseif irq = "in" {}
            elseif irq = "out" {
                if (triples = 2) && (out = 2) set blockTileCount = blockTileCount + 1
                set triples = (triples + 1) # 3
            }
            else { w "Unknown interrupt!" quit }
        }

        w "Part 1/2 Answer: ", blockTileCount, !

        // Part 2/2 
        if verbose { w !, "Part 2/2 result: ", ! }

        set hart = 2 // thread number
        merge code(hart) = codeSet // thread codebase
        set code(hart, "op") = 0 // 1st instruction adress
        set in = 0
        set triples = 0 // for day13
        set code(hart, 0) = 2 // for day13 part2/2
        
        for {
            set sc = ..CodeRun(hart, .code, count, verbose, in, .out, .irq)
            if irq = "halt" { quit }
            elseif irq = "in" {
                read in
            }
            elseif irq = "out" {
                if triples = 0 set x = out

                if triples = 1 set y = out
                
                if triples = 2 {
                    if x = -1 { set score = out quit }
                    set tileId = out
                    if x = 0 set screen(y) = ""
                    do ..drawTile(.screen, y, tileId)
                    if x = 42 do ..showScreen(.screen, y)
                }
                set triples = (triples + 1) # 3
            }
            else { w "Unknown interrupt!" quit }
        }
        w "X: "_ x _" Y: "_ y, !
        w "Part 2/2 Answer: ", score, !

    }
    return sc
}

ClassMethod drawTile(screen, line, tileId) As %Status
{
    set tile = $case(tileId,
        0: " ", // is an empty tile. No game object appears in this tile
        1: "#", // is a wall tile. Walls are indestructible barriers
        2: "-", // is a block tile. Blocks can be broken by the ball
        3: "=", // is a horizontal paddle tile. The paddle is indestructible
        4: "o", // is a ball tile. The ball moves diagonally and bounces off objects
        : "?"
    )
    set screen(line) = screen(line)_tile
    return $$$OK
}

ClassMethod showScreen(screen, line) As %Status
{
    w screen(line), " ", !
    return $$$OK
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

ClassMethod CodeRun(hart, codeSet, count, verbose = 0, in, out, irq) As %Status
{
    set relativeBase = 0 // variable pointer
    set op = codeSet(hart, "op") // operations counter
    set pNum = 0 // parameter number
    set inputsCounter = 1

    for {
        // decoding the operation code and the number of its parameters 
        set opCode = codeSet(hart, op) # 100

        if verbose { w op _ " code: "_ codeSet(hart, op) _" op: "_ opCode }
        
        // halt interrupt
        if opCode = 99 { 
            #; if verbose { w !, "HALT ", ! } 
            set irq = "halt"
            return $$$OK 
        }

        // input interrupt
        if opCode = 3 && $data(in) {
            set codeSet(hart, "op") = op
            set irq = "in"
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

        if verbose { w " pNum: "_ pNum } 

        // decode mode for each parameter: 0 == position, 1 == immediate, 2 == relative
        for i = 1:1:pNum {
            set k = 10 ** (i + 1)
            set pMode(i) = (codeSet(hart, op) - (codeSet(hart, op) # k)) / k # 10 
        }

        if verbose { for i = 1:1:pNum { w " "_ codeSet(hart, op + i) } }
        if verbose { for i = 1:1:pNum { w " p"_ i _": "_ pMode(i) } } 
        
        // decoding of the actual parameter addresses of the operation
        for j = 1:1:pNum {
            if pMode(j) = 0 { set pAddr(j) = codeSet(hart, op+j) }
            elseif pMode(j) = 1 { set pAddr(j) = op+j }
            elseif pMode(j) = 2 { set pAddr(j) = codeSet(hart, op+j) + relativeBase }
            else { return 0 }
        }  
        
        #; if verbose { 
        #;     for i = 1:1:pNum { w " A"_ i _": "_ pAddr(i) }
        #;     for i = 1:1:pNum { w " : " _ codeSet(hart, pAddr(i)) }
        #;     w !
        #; }

        set op = op + pNum + 1 // next instruction, some operations may change it

        do $case( opCode, 
            1: ..Add(.codeSet, hart, .pAddr),
            2: ..Mul(.codeSet, hart, .pAddr),
            3: ..Input(.codeSet, hart, .pAddr, .in),
            4: ..Outputs(.codeSet, hart, .pAddr, .out),
            5: ..JumpIfTrue(.codeSet, hart, .pAddr, .op),
            6: ..JumpIfFalse(.codeSet, hart, .pAddr, .op),
            7: ..LessThan(.codeSet, hart, .pAddr),
            8: ..equals(.codeSet, hart, .pAddr),
            9: ..AdjustsRelativeBase(.codeSet, hart, .pAddr, .relativeBase),
            : ..UnknownOp(opCode, op)
        )
        
        // output interrupt
        if opCode = 4 {
            set codeSet(hart, "op") = op
            set irq = "out"
            return $$$OK
        }
    }

    return $$$OK
}

ClassMethod UnknownOp(opCode, op) As %Status
{
    w !, "Unknown opcode "_ opCode _" in line "_ op _" Something went wrong!", !
    return 0
}

ClassMethod Add(codeSet, hart, pAddr) As %Status
{
    set codeSet(hart, pAddr(3)) = codeSet(hart, pAddr(1)) + codeSet(hart, pAddr(2))
    return $$$OK
}

ClassMethod Mul(codeSet, hart, pAddr) As %Status
{
    set codeSet(hart, pAddr(3)) = codeSet(hart, pAddr(1)) * codeSet(hart, pAddr(2))
    return $$$OK
}

ClassMethod Input(codeSet, hart, pAddr, in) As %Status
{
    set codeSet(hart, pAddr(1)) = in
    kill in
    return $$$OK
}

ClassMethod Outputs(codeSet, hart, pAddr, out) As %Status
{
    set out = codeSet(hart, pAddr(1))
    return $$$OK
}

ClassMethod JumpIfTrue(codeSet, hart, pAddr, op) As %Status
{
    if codeSet(hart, pAddr(1)) '= 0 { set op = codeSet(hart, pAddr(2)) }
    return $$$OK
}

ClassMethod JumpIfFalse(codeSet, hart, pAddr, op) As %Status
{
    if codeSet(hart, pAddr(1)) = 0 { set op = codeSet(hart, pAddr(2)) }
    return $$$OK
}

ClassMethod LessThan(codeSet, hart, pAddr) As %Status
{
    if codeSet(hart, pAddr(1)) < codeSet(hart, pAddr(2)) { 
        set codeSet(hart, pAddr(3)) = 1 
    }
    else { set codeSet(hart, pAddr(3)) = 0 }
    
    return $$$OK
}

ClassMethod equals(codeSet, hart, pAddr) As %Status
{
    if codeSet(hart, pAddr(1)) = codeSet(hart, pAddr(2)) { 
        set codeSet(hart, pAddr(3)) = 1 
    }
    else { set codeSet(hart, pAddr(3)) = 0 }

    return $$$OK
}

ClassMethod AdjustsRelativeBase(codeSet, hart, pAddr, relativeBase) As %Status
{
    set relativeBase = relativeBase + codeSet(hart, pAddr(1))
    return $$$OK
}

}
