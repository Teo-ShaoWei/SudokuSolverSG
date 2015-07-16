module SudokuSolver

include("constants.jl")
include("types.jl")
include("operations.jl")


function solveSudoku(input::Matrix{Number})
    gs = GameState()
    numbersFilled = populateGame(gs, input)
    Place(gs, numbersFilled)
    @printf "\n\nTotal COUNT = %d\n" getTotalCount(gs.levelCount)

    return gs.solutions
end


function populateGame(gs::GameState, input::Matrix{Number})
    numbersFilled = 0

    for i in 1:9, j in 1:9
        if input[i, j] != 0
            cell = Cell(i, j)
            setCell(gs, cell, input[i, j])
            numbersFilled += 1
            SwapSeqEntries(gs, numbersFilled, findfirst(gs.sequence, cell))
        end
    end

    return numbersFilled
end


function PrintArray(gs::GameState)
    for i in 1:9
        (i % 3 == 1) && println()
        for j in 1:9
            (j % 3 == 1) && print(' ')
            number = gs.cells[Cell(i, j)]
            ch = number ∈ [1:9] ? '0' + number : '-'
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


function Succeed(gs::GameState)
    writeSolution(gs.solutions, gs.cells)
    PrintArray(gs)
    PrintStats(gs)
end


function NextSeq(gs::GameState, S::Int)
    S2 = zero(Int)
    MinBitCount = 100

    for T in S:81
        cell = gs.sequence[T]
        Possibles = getRemainingNumbers(gs, cell)
        BitCount = getSize(Possibles)

        if BitCount < MinBitCount
            MinBitCount = BitCount
            S2 = T
        end
    end

    return S2
end


function Place(gs::GameState, numbersFilled::Int)
    if numbersFilled ≥ 81
        Succeed(gs)
        return
    end

    currentIndex = numbersFilled + 1
    gs.levelCount[currentIndex] += 1

    S2 = NextSeq(gs, currentIndex)
    SwapSeqEntries(gs, currentIndex, S2)

    cell = gs.sequence[currentIndex]

    Possibles = getRemainingNumbers(gs, cell)
    for number in Possibles
        setCell(gs, cell, number)
        Place(gs, numbersFilled + 1)
        clearCell(gs, cell)
    end

    SwapSeqEntries(gs, currentIndex, S2)
end


end #SudokuSolver
