Class kuznetsov.Advent2019.Day4 Extends kuznetsov.Advent2019.Base
{

Parameter InputFile;

// w ##class(kuznetsov.Advent2019.Day4).Run()

ClassMethod Run(verbose = 0) As %Status
{
    // Part 1/2

    set count = 0
    for i = 240298:1:784956 {
        if $extract(i, 1, 1) > $extract(i, 2, 2) { continue }
        elseif $extract(i, 2, 2) > $extract(i, 3, 3) { continue }
        elseif $extract(i, 3, 3) > $extract(i, 4, 4) { continue }
        elseif $extract(i, 4, 4) > $extract(i, 5, 5) { continue }
        elseif $extract(i, 5, 5) > $extract(i, 6, 6) { continue }
        else {
            if $find(i, 33) 
            || $find(i, 44) 
            || $find(i, 55) 
            || $find(i, 66) 
            || $find(i, 77) 
            || $find(i, 88) 
            || $find(i, 99) {
                set count = count + 1
                set passList(count) = i
            }
        }
    }

    w !, "Part 1/2 Answer: ", count, !

    
    // Part 2/2 

    for j = 1:1:count {
        set i = passList(j)
        for k = 3:1:9 {
            if $find(i, k * 11111) || $find(i, k * 111111) { 
                kill passList(j)
                quit
            }
            elseif $find(i, k * 1111) {
                kill passList(j)
                for l = 3:1:9 {
                    if (l = k) { continue }
                    if $find(i, l * 11) {
                        set passList(j) = i
                    }
                }
                quit
            }
            elseif $find(i, k * 111) {
                kill passList(j)
                for l = 3:1:9 {
                    if (l = k) { continue }
                    if $find(i, l * 11) && '$find(i, l * 111) {
                        set passList(j) = i
                    }
                }
                quit
            }
        }
    }

    set count2 = 0
    for j = 1:1:count {
        if $data(passList(j)) { set count2 = count2 + 1}
    }

    w !, "Part 2/2 Answer: ", count2, !
    
    return $$$OK
}

}
