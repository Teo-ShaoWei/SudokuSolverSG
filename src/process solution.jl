# Solution found.  To write solution and print statistic to STDOUT.
function processSolution!(gs::GameState)
    writeSolution!(gs.solutions, gs.cells)
    PrintArray(gs)
    PrintStats(gs)
end


function PrintArray(gs::GameState)
    for i in 1:9
        (i % 3 == 1) && println()
        for j in 1:9
            (j % 3 == 1) && print(' ')
            number = gs.cells[Cell(i, j)]
            ch = number ∈ 1:9 ? '0' + number : '-'
            print(ch)
        end
        println()
    end
end


function PrintStats(gs::GameState)
    @printf "\nLevel Counts:\n\n"

    S = 1
    while gs.levelCount[S] == 0
        S += 1
    end

    i = 1

    while S ≤ 81
        cell = gs.sequence[S]
        @printf "(%d, %d):%4d " cell.row cell.col gs.levelCount[S]
        if (i > 5)
            @printf "\n"
            i = 1
        else
            i += 1
        end
        S += 1
    end

    @printf "\n\nCOUNT = %d\n" getTotalCount(gs.levelCount)
end
