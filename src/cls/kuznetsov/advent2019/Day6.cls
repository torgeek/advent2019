Class kuznetsov.Advent2019.Day6 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile = "input6.txt";

// w ##class(kuznetsov.Advent2019.Day6).Run()

ClassMethod Run(verbose = 0) As %Status
{
    set sc = ..ReadFromFile(.mapData, .pairNum)
    if $$$ISERR(sc) {
        w "Panic! File " _ ..#InputFile _ " is empty or not found!", !
    } else {
        set sc = ..ParseOrbit(.mapData, pairNum, .orbitSet)

        // Part 1/2
        if verbose { w "Part 1/2", ! }


        // Part 2/2 
        if verbose { w !, "Part 2/2", ! }

    }

    return sc
}

ClassMethod ReadFromFile(mapData, pairNum) As %Status
{
    Set sc = $$$OK
    set stream = ..GetInput(..#InputFile)
    if stream.%IsNull() { set sc = 0 }
    else {
        set pairNum = 0
        while 'stream.AtEnd {
            set pairNum = pairNum + 1
            set mapData(pairNum) = stream.ReadLine()
        }
    }
    return sc
}

ClassMethod ParseOrbit(mapData, pairNum, orbitSet) As %Status
{
    for i = 1:1:pairNum {
        set around = $EXTRACT(mapData(i), 1, 3)
        set orbitSet(around) = ($EXTRACT(mapData(i), 5, 7)) 
    }
    return $$$OK
}

}
