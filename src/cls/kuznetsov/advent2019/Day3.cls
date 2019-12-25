/// Advent Of Code 2019 in ObjectScript
/// Author: Dmitrii Kuznetsov
Class kuznetsov.Advent2019.Day3 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input3.txt";

// w ##class(kuznetsov.Advent2019.Day3).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.wirePath)
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        // Part 1/2
        do ..WirePath2Matrix(.wirePath, .wireMatrix, .minDistance)
        if verbose { w "Mininimal distance to cross: "_ minDistance, ! }

        // Part 2/2 
        do ..WirePath2Steps(.wirePath, .wireMatrix, .minStepsSum)
        if verbose { w "Mininimal steps to cross: "_ minStepsSum, ! }
    }
    return sc
}

ClassMethod ReadFromFile(wirePath) As %Status
{
    Set sc = $$$OK
    set stream = ..GetInput(..#InputFile)
    if stream.%IsNull() { set sc = 0 }
    else {
        set wirePath(1) = stream.ReadLine()
        set wirePath(2) = stream.ReadLine()
    }
    return sc
}

ClassMethod WirePath2Matrix(wirePath, wireMatrix, result) As %Status
{
    set minDistance = 0

    for phase = 1:1:2 {
        set x = 0
        set y = 0

        for i = 1:1:$LENGTH(wirePath(phase), ",") {
            set go = $PIECE(wirePath(phase), ",", i)
            set axis = $EXTRACT(go)
            set step = $EXTRACT(go, 2, *)

            for j = 1:1:step {
                if phase = 1 { set wireMatrix(x, y) = 1 }
                elseif (phase = 2) && ($data(wireMatrix(x, y))) {
                    set wireMatrix(x, y) = 2
                    set newDistance = $ZABS(x) + $ZABS(y)
                    if (minDistance > newDistance) || (minDistance = 0) { 
                        set minDistance = newDistance 
                    }
                } 

                if axis = "R" { set x = x + 1 }
                elseif axis = "L" { set x = x - 1 }
                elseif axis = "U" { set y = y + 1 }
                elseif axis = "D" { set y = y - 1 }
                else { return 0 }
            }         
        }
    }
    
    set result = minDistance
    
    return $$$OK
}

ClassMethod WirePath2Steps(wirePath, wireMatrix, result) As %Status
{
    set minStepsSum = 0

    for phase = 1:1:2 {
        set x = 0
        set y = 0
        set stepsSum = 0

        for i = 1:1:$LENGTH(wirePath(phase), ",") {
            set go = $PIECE(wirePath(phase), ",", i)
            set axis = $EXTRACT(go)
            set step = $EXTRACT(go, 2, *)

            for j = 1:1:step {
                if j = step {
                    set stepsSum = stepsSum + step
                } 
                elseif (phase = 1) && (wireMatrix(x, y) = 2) {
                    set wireMatrix(x, y, "steps") = stepsSum + j - 1
                }
                elseif (phase = 2) && ($data(wireMatrix(x, y))) && (wireMatrix(x, y) = 2) {
                    set newStepsSum = wireMatrix(x, y, "steps") + stepsSum + j - 1
                    if (minStepsSum > newStepsSum) || (minStepsSum = 0) { 
                        set minStepsSum = newStepsSum
                    }
                } 

                if axis = "R" { set x = x + 1 }
                elseif axis = "L" { set x = x - 1 }
                elseif axis = "U" { set y = y + 1 }
                elseif axis = "D" { set y = y - 1 }
                else { return 0 }
            }         
        }
    }
    
    set result = minStepsSum
    
    return $$$OK
}

}
