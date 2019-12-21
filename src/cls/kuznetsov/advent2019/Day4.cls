Class kuznetsov.Advent2019.Day4 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile;

// w ##class(kuznetsov.Advent2019.Day4).Run()

ClassMethod Run(verbose = 0) As %Status
{
    // Part 1/2

    set count = 0
    for i = 240298:1:784956 {
        for same = 1:1:1 { 
            if $extract(i, 1, 1) > $extract(i, 2, 2) { quit }
            elseif $extract(i, 2, 2) > $extract(i, 3, 3) { quit }
            elseif $extract(i, 3, 3) > $extract(i, 4, 4) { quit }
            elseif $extract(i, 4, 4) > $extract(i, 5, 5) { quit }
            elseif $extract(i, 5, 5) > $extract(i, 6, 6) { quit }
            else {
                if $find(i, 33) 
                || $find(i, 44) 
                || $find(i, 55) 
                || $find(i, 66) 
                || $find(i, 77) 
                || $find(i, 88) 
                || $find(i, 99) {
                    set count = count + 1
                }
            }
        }
    }

    w !, "Part 1/2 Answer: ", count, !

    // Part 2/2 

    #; }
    return $$$OK
}

}
