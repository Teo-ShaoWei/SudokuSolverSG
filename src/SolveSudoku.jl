module SudokuSolver

include("constants.jl")
include("types.jl")
include("operations.jl")


function SwapSeqEntries(gs::GameState, S1::Int, S2::Int)
    (gs.sequence[S1], gs.sequence[S2]) = (gs.sequence[S2], gs.sequence[S1])
end

function InitEntry(gs::GameState, i::Int, j::Int, number::Number)
    cell = Cell(i, j)

    # Add suitable checks for data consistency.

    setCell(gs, cell, number)

    SeqPtr2 = gs.sequencePointer
    while SeqPtr2 ≤ 81 && gs.sequence[SeqPtr2] != cell
        SeqPtr2 += 1
    end

    SwapSeqEntries(gs, gs.sequencePointer, SeqPtr2)
    gs.sequencePointer += 1
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


function ConsoleInput(gs::GameState)
    for i in 1:9
        @printf "ROW[%d] : " i
        InputString = readline(STDIN)

        for j in 1:9
            ch = InputString[j]
            if ch ≥ '1' && ch ≤ '9'
                InitEntry(gs, i, j, ch - '0')
            end
        end
    end

    PrintArray(gs)
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

    @printf "\n\nCOUNT = %d\n" gs.currentCount
end


function Succeed(gs::GameState)
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


function Place(gs::GameState, S::Int)
    gs.levelCount[S] += 1
    gs.currentCount += 1

    if S > 81
        Succeed(gs)
        return
    end

    S2 = NextSeq(gs, S)
    SwapSeqEntries(gs, S, S2)

    cell = gs.sequence[S]

    Possibles = getRemainingNumbers(gs, cell)
    for number in Possibles
        setCell(gs, cell, number)
        Place(gs, S + 1)
        clearCell(gs, cell)
    end

    SwapSeqEntries(gs, S, S2)
end


# Get the remaining number left that can be filled into indicated cell.
getRemainingNumbers(gs::GameState, cell::Cell) = gs.blocks[cell] ∩ gs.rows[cell] ∩ gs.cols[cell]


# Set cell to be the given number.
# E.g. if `cell == 1` and `number == 2`,
# then we will set entry of cell (1, 1) with the value of 2.
# Notice that we will also remove 2 from corresponding component so it will not be used for subsequent allocations.
function setCell(gs::GameState, cell::Cell, number::Number)
    writeNumberToCell(gs, cell, number)
    removeNumberFromBlock(gs, cell, number)
    removeNumberFromRow(gs, cell, number)
    removeNumberFromCol(gs, cell, number)
end

# Clear cell does the opposite of set cell.
# Clear cell will erase the number allocated to it,
# while reinstating its possibility to be use by other empty cells.
function clearCell(gs::GameState, cell::Cell)
    reinstateNumberToBlock(gs, cell)
    reinstateNumberToRow(gs, cell)
    reinstateNumberToCol(gs, cell)
    eraseNumberFromCell(gs, cell)
end


# Write number to cell.
function writeNumberToCell(gs::GameState, cell::Cell, number::Number)
    gs.cells[cell] = number
end
# Erase number from cell.
function eraseNumberFromCell(gs::GameState, cell::Cell)
    gs.cells[cell] = BLANK
end


# Remove the number from corresponding (block/row/column) because it has been allocated to a cell within them.
removeNumberFromBlock(gs::GameState, cell::Cell, number::Number) = removeNumber!(gs.blocks[cell], number)
removeNumberFromRow(gs::GameState, cell::Cell, number::Number) = removeNumber!(gs.rows[cell], number)
removeNumberFromCol(gs::GameState, cell::Cell, number::Number) = removeNumber!(gs.cols[cell], number)


# Reinstate the number to corresponding (block/row/column) because it is freed from a cell within them.
reinstateNumberToBlock(gs::GameState, cell::Cell) = includeNumber!(gs.blocks[cell], gs.cells[cell])
reinstateNumberToRow(gs::GameState, cell::Cell) = includeNumber!(gs.rows[cell], gs.cells[cell])
reinstateNumberToCol(gs::GameState, cell::Cell) = includeNumber!(gs.cols[cell], gs.cells[cell])


function main()
    gs = GameState()
    ConsoleInput(gs)
    Place(gs, gs.sequencePointer)
    @printf "\n\nTotal COUNT = %d\n" gs.currentCount

    return 0
end


end #SudokuSolver
