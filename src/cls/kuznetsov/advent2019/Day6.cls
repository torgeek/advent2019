/// Advent Of Code 2019 in ObjectScript
/// Author: Dmitrii Kuznetsov
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
        set sc = ..ParseOrbit(.mapData, pairNum, .orbitTree)

        // Part 1/2
        w:verbose=0 "Part 1/2", !

        set (directOrbits, indirectOrbits) = 0
        
        set orbitsNum = $length(orbitTree, ",") - 1

        for i = 1:1:orbitsNum {
            set id = $piece(orbitTree, ",", i)
            do $i(directOrbits)
            while id '= "COM" {
                w:verbose=1 id, " "
                set id = orbitTree(id)
                do $i(indirectOrbits)
            }
            do $i(indirectOrbits, -1)
            w:verbose=1 !
        }

        w "Answer: ", directOrbits + indirectOrbits, !

        // Part 2/2 
        w:verbose=0 "Part 2/2", !

        set id = "YOU"
        set path(1) = ""
        while id '= "COM" {
            set path(1) = path(1) _ id _">"
            set id = orbitTree(id)
            do $i(OrbitalTransfers)
        }
        w:verbose=1 path(1), !

        set id = "SAN"
        set path(2) = ""
        while id '= "COM" {
            set path(2) = path(2) _ id _ ">"
            set id = orbitTree(id)
            do $i(OrbitalTransfers)
        }
        w:verbose=1 path(2), !

        set minOrbitalTransfers = 0
        
        set pathNum = $length(path(1), ">") - 1
        
        for i = 1:1:pathNum {
            set orbit = $piece(path(1), ">", i)
            do $i(minOrbitalTransfers)
            if $find(path(2), orbit) {
                set meetingPoint = orbit
                quit
            }
        }
        w:verbose=1 meetingPoint, !
        
        set pathNum = $length(path(2), ">") - 1
        
        for i = 1:1:pathNum {
            set orbit = $piece(path(2), ">", i)
            do $i(minOrbitalTransfers)
            if orbit = meetingPoint { quit }
        }

        w "Answer: ", minOrbitalTransfers - 4, !

    }

    return sc
}

ClassMethod ReadFromFile(ByRef mapData, Output pairNum) As %Status
{
    Set sc = $$$OK
    set stream = ..GetInput(..#InputFile)
    if stream.%IsNull() { set sc = 0 }
    else {
        set pairNum = 0
        while 'stream.AtEnd {
            set mapData($i(pairNum)) = stream.ReadLine()
        }
    }
    return sc
}

ClassMethod ParseOrbit(ByRef mapData, pairNum, Output orbitTree) As %Status
{
    set orbitTree = ""
    for i = 1:1:pairNum {
        set orbit = $piece(mapData(i), ")", 1)
        set around = $piece(mapData(i), ")", 2)
        set orbitTree(around) = orbit

        if '$find(orbitTree, orbit) {
            if orbit '= "COM" {
                set orbitTree = orbitTree_orbit_"," 
            }
        }
        if '$find(orbitTree, around) {
            set orbitTree = orbitTree_around_","
        }
             
    }

    return $$$OK
}

}
