/// Advent Of Code 2019 in ObjectScript
/// Author: Dmitrii Kuznetsov
Class kuznetsov.Advent2019.Day8 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input8.txt";

// w ##class(kuznetsov.Advent2019.Day8).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.image) // instructionSet As %String
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        set layerSize = 25 * 6
        set sc = ..ParseFromString(.image, layerSize, .numberOfLayer, .layer)

        // Part 1/2
        if verbose { w !, "Part 1/2 result: ", ! }
        
        set countZero = layerSize
        for i = 1:1:numberOfLayer {
            do ..DigitsCounter(.layer, i, 0, .result)
            if countZero > result { 
                set countZero = result
                set layerWithFewestZero = i 
            }  
        }
        if verbose { w "layerWithFewestZero: "_ layerWithFewestZero _" "_ countZero, ! }

        do ..DigitsCounter(.layer, layerWithFewestZero, 1, .result)
        set answer = result

        do ..DigitsCounter(.layer, layerWithFewestZero, 2, .result)
        set answer = answer * result

        w "Answer: "_ answer, !

        // Part 2/2 
        if verbose { w !, "Part 2/2 result: ", ! }
        do ..DecodeTheImage(.layer, numberOfLayer, layerSize)
        do ..ViewImage(.layer, "image")
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

ClassMethod ParseFromString(image, layerSize, numberOfLayer, layer) As %Status
{
    set numberOfLayer = $LENGTH(image) / layerSize
    set j = 1
    for i = 1 : layerSize : numberOfLayer * layerSize {
        set layer(j) = $EXTRACT(image, i , i + layerSize - 1)
        set j = j + 1
    }
    return $$$OK
}

ClassMethod DigitsCounter(layer, layerN, digit, result) As %Status
{
    Set sc = $$$OK
    set result = -1
    set pos = 1
    do {
        set result = result + 1
        set pos = $FIND(layer(layerN), digit, pos)
    } while pos
    return sc
}

ClassMethod DecodeTheImage(layer, numberOfLayer, layerSize) As %Status
{
    set layer("image") = ""
    for pos = 1:1:layerSize {
        for n = 1:1:numberOfLayer {
            set pixel = $EXTRACT(layer(n), pos, pos)
            if pixel = 0 { set layer("image") = layer("image")_" " quit }
            elseif pixel = 1 { set layer("image") = layer("image")_"#" quit }
        }
    }
}

ClassMethod ViewImage(layer, layerN, wide = 25, tall = 6) As %Status
{
    w !
    for i = 1:1:tall {
        w $EXTRACT(layer(layerN), (i - 1) * wide + 1, i * wide)
        w !
    }
    return $$$OK
}

}
