/// Advent Of Code 2019 in ObjectScript
/// Author: Dmitrii Kuznetsov
Class kuznetsov.Advent2019.Day11 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input11.txt";

// w ##class(kuznetsov.Advent2019.Day11).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.instructionSet) // instructionSet As %String
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        
        #; set instructionSet = "3,9,8,9,10,9,4,9,99,-1,8" // test pos mode in=8 => out=1
        #; set instructionSet = "3,9,7,9,10,9,4,9,99,-1,8" // test pos mode in<8 => out=1
        #; set instructionSet = "3,3,1108,-1,8,3,4,3,99" // test imm mode in=8 => out=1
        #; set instructionSet = "3,3,1107,-1,8,3,4,3,99" // test imm mode in<8 => out=1
        #; set instructionSet = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9" // jump test pos mode in=0 => out=0
        #; set instructionSet = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1" // jump test imm mode in'=8 => out=1

        // Part 1/2
        if verbose { w !, "Part 1/2 result: ", ! }

        set sc = ..ParseFromString(.instructionSet, .count, .codeSet)
        w "count: ", count, !
        set hart = 1 // thread number
        merge code(hart) = codeSet // thread codebase
        set code(hart, "op") = 0 // 1st instruction adress
        set code(hart, "relativeBase") = 0
        set irq = "start"
        #; set in = 0
        set duet = 0 // for day11
        do ..initTiles(.tiles)
        do ..initRobot(.robot)
        do ..showScreen(.tiles, .robot)

        for {
            set sc = ..CodeRun(hart, .code, count, verbose, .in, .out, .irq)
            if irq = "halt" { quit }
            elseif irq = "in" {
                set in = tiles(robot("x"), robot("y"))
                #; w code(hart, "op"), " ", tiles(robot("x"), robot("y")), !
            }
            elseif irq = "out" {
                w "out: ", out _" ", !
                if duet = 0 {
                    set tiles(robot("x"), robot("y")) = out
                } elseif duet = 1 { 
                    if out = 0 { set robot("view") = robot("view") + 3 # 4 } // rotate left 
                    else { set robot("view") = robot("view") + 1 # 4 } // rotate right
                    
                    if robot("view") = 0 { set robot("y") = robot("y") - 1 }
                    elseif robot("view") = 1 { set robot("x") = robot("x") + 1 }
                    elseif robot("view") = 2 { set robot("y") = robot("y") + 1 }
                    elseif robot("view") = 3 { set robot("x") = robot("x") - 1 }
                    else { quit }

                    do ..showScreen(.tiles, .robot)
                } else { quit }
                set duet = (duet + 1) # 2
            }
            else { w "Unknown interrupt!" quit }
        }

        w "Part 1/2 Answer: ", blockTileCount, !

        // Part 2/2 
        if verbose { w !, "Part 2/2 result: ", ! }

        #; set hart = 2 // thread number
        #; merge code(hart) = codeSet // thread codebase
        #; set code(hart, "op") = 0 // 1st instruction adress
        #; set in = 0
        #; set triples = 0 // for day11
        #; set code(hart, 0) = 2 // for day11 part2/2
        
        #; for {
        #;     set sc = ..CodeRun(hart, .code, count, verbose, in, .out, .irq)
        #;     if irq = "halt" { quit }
        #;     elseif irq = "in" {
        #;         read in
        #;     }
        #;     elseif irq = "out" {
        #;         if triples = 0 set x = out

        #;         if triples = 1 set y = out
                
        #;         if triples = 2 {
        #;             if x = -1 { set score = out quit }
        #;             set tileId = out
        #;             if x = 0 set screen(y) = ""
        #;             do ..drawTile(.screen, y, tileId)
        #;             if x = 42 do ..showScreen(.screen, y)
        #;         }
        #;         set triples = (triples + 1) # 3
        #;     }
        #;     else { w "Unknown interrupt!" quit }
        #; }
        #; w "X: "_ x _" Y: "_ y, !
        #; w "Part 2/2 Answer: ", score, !

    }
    return sc
}

ClassMethod initTiles(tiles) As %Status
{
    for y = 1:1:5 {
        for x = 1:1:5 {
            set tiles(x, y) = 0
        }
    }
    return $$$OK
}

ClassMethod initRobot(robot) As %Status
{
    set robot("x") = 3
    set robot("y") = 3
    set robot("view") = 0 // 0 - 0 degrees, 1 - 90, 2 - 180, 3 - 270
    set robot(0) = "^"
    set robot(1) = ">"
    set robot(2) = "v"
    set robot(3) = "<"    
    return $$$OK
}

ClassMethod showScreen(tiles, robot) As %Status
{
    for y = 1:1:5 {
        for x = 1:1:5 {
            if (x = robot("x")) && (y = robot("y")) { w robot(robot("view")) }
            elseif tiles(x, y) = 1  { w "#" }
            else { w "." }
        }
        w !
    }
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

ClassMethod CodeRun(hart, code, count, verbose = 0, in, out, irq) As %Status
{
    set relativeBase = code(hart, "relativeBase") // variable pointer
    set op = code(hart, "op") // operations counter    
    
    w "irq: ", irq, " ", "base: ", relativeBase, !
    
    for {
        // decoding the operation code and the number of its parameters 
        set opCode = code(hart, op) # 100

        if verbose { w op _ " code: "_ code(hart, op) _" op: "_ opCode }
        
        // halt interrupt
        if opCode = 99 { 
            if verbose { w !, "HALT ", ! } 
            set irq = "halt"
            return $$$OK 
        }   

        // input interrupt
        if opCode = 3 && '$data(in) {
            set code(hart, "op") = op
            set code(hart, "relativeBase") = relativeBase
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

        // decode mode for each parameter 123xx (xx - instructions code)
        for i = 1:1:pNum {
            set k = 10 ** (i + 1)
            set pMode(i) = (code(hart, op) - (code(hart, op) # k)) / k # 10 
        }

        if verbose { for i = 1:1:pNum { w " "_ code(hart, op + i) } }
        if verbose { for i = 1:1:pNum { w " pmode"_ i _": "_ pMode(i)} }
        
        // decode mode for each parameter: 0 == position, 1 == immediate, 2 == relative
        // decode of the actual parameter addresses of the operation
        for i = 1:1:pNum {
            if pMode(i) = 0 { set pAddr(i) = code(hart, op + i) }
            elseif pMode(i) = 1 { set pAddr(i) = op + i }
            elseif pMode(i) = 2 { set pAddr(i) = code(hart, op + i) + relativeBase }
            else { return 0 }
        }  
        
        if verbose { 
            for i = 1:1:pNum { w " Addr"_ i _":"_ pAddr(i) }
            for i = 1:1:pNum { w " : " _ code(hart, pAddr(i)) }
            w !
        }

        set op = op + pNum + 1 // next instruction, some operations may change it    

        do $case( opCode, 
            1: ..Add(.code, hart, .pAddr),
            2: ..Mul(.code, hart, .pAddr),
            3: ..Input(.code, hart, .pAddr, .in),
            4: ..Outputs(.code, hart, .pAddr, .out),
            5: ..JumpIfTrue(.code, hart, .pAddr, .op),
            6: ..JumpIfFalse(.code, hart, .pAddr, .op),
            7: ..LessThan(.code, hart, .pAddr),
            8: ..equals(.code, hart, .pAddr),
            9: ..AdjustsRelativeBase(.code, hart, .pAddr, .relativeBase),
            : ..UnknownOp(opCode, op)
        )
        
        // output interrupt
        if opCode = 4 {
            set code(hart, "op") = op
            set code(hart, "relativeBase") = relativeBase
            set irq = "out"
            return $$$OK
        }
    }

    return $$$OK
}

ClassMethod Add(code, hart, pAddr) As %Status
{
    set code(hart, pAddr(3)) = code(hart, pAddr(1)) + code(hart, pAddr(2))
    return $$$OK
}

ClassMethod Mul(code, hart, pAddr) As %Status
{
    set code(hart, pAddr(3)) = code(hart, pAddr(1)) * code(hart, pAddr(2))
    return $$$OK
}

ClassMethod Input(code, hart, pAddr, in) As %Status
{
    set code(hart, pAddr(1)) = in
    kill in
    return $$$OK
}

ClassMethod Outputs(code, hart, pAddr, out) As %Status
{
    set out = code(hart, pAddr(1))
    return $$$OK
}

ClassMethod JumpIfTrue(code, hart, pAddr, op) As %Status
{
    if code(hart, pAddr(1)) '= 0 { set op = code(hart, pAddr(2)) }
    return $$$OK
}

ClassMethod JumpIfFalse(code, hart, pAddr, op) As %Status
{
    if code(hart, pAddr(1)) = 0 { set op = code(hart, pAddr(2)) }
    return $$$OK
}

ClassMethod LessThan(code, hart, pAddr) As %Status
{
    if code(hart, pAddr(1)) < code(hart, pAddr(2)) { 
        set code(hart, pAddr(3)) = 1 
    }
    else { set code(hart, pAddr(3)) = 0 }
    
    return $$$OK
}

ClassMethod equals(code, hart, pAddr) As %Status
{
    if code(hart, pAddr(1)) = code(hart, pAddr(2)) { 
        set code(hart, pAddr(3)) = 1 
    }
    else { set code(hart, pAddr(3)) = 0 }

    return $$$OK
}

ClassMethod AdjustsRelativeBase(code, hart, pAddr, relativeBase) As %Status
{
    set relativeBase = relativeBase + code(hart, pAddr(1))
    return $$$OK
}

ClassMethod UnknownOp(opCode, op) As %Status
{
    w !, "Unknown opcode "_ opCode _" in line "_ op _" Something went wrong!", !
    return 0
}

}
