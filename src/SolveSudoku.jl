module SudokuSolver

include("constants.jl")
include("types.jl")
include("operations.jl")


function SwapSeqEntries(gs::GameState, S1::Int, S2::Int)
    (gs.sequence[S1], gs.sequence[S2]) = (gs.sequence[S2], gs.sequence[S1])
end

function InitEntry(gs::GameState, i::Int, j::Int, number::Number)
    Square = getCell(i, j)

    # Add suitable checks for data consistency.

    setCell(gs, Square, number)

    SeqPtr2 = gs.sequencePointer
    while SeqPtr2 ≤ 81 && gs.sequence[SeqPtr2] != Square
        SeqPtr2 += 1
    end

    SwapSeqEntries(gs, gs.sequencePointer, SeqPtr2)
    gs.sequencePointer += 1
end


function PrintArray(gs::GameState)
    Square = 1

    for i in 1:9
        (i % 3 == 1) && println()
        for j in 1:9
            (j % 3 == 1) && print(' ')
            number = gs.cell[Square]
            Square += 1
            if number ∈ [1:9]
                ch = '0' + number
            else
                ch = '-'
            end
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
        Seq = gs.sequence[S]
        @printf "(%d, %d):%4d " cld(Seq, 9) rem1(Seq, 9) gs.levelCount[S]
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
        Square = gs.sequence[T]
        Possibles = getRemainingNumbers(gs, Square)
        BitCount = getSize(Possibles)

        if BitCount < MinBitCount
            MinBitCount = BitCount
            S2 = T
        end
    end

    return S2
end


function Place(gs::GameState, S::Index)
    gs.levelCount[S] += 1
    gs.currentCount += 1

    if S > 81
        Succeed(gs)
        return
    end

    S2 = NextSeq(gs, S)
    SwapSeqEntries(gs, S, S2)

    Square = gs.sequence[S]

    Possibles = getRemainingNumbers(gs, Square)
    for number in Possibles
        setCell(gs, Square, number)
        Place(gs, S + 1)
        clearCell(gs, Square)
    end

    SwapSeqEntries(gs, S, S2)
end


# Get the remaining number left that can be filled into given `square`.
getRemainingNumbers(gs::GameState, square::Int) = gs.blocks[square] ∩ gs.rows[square] ∩ gs.cols[square]


# Get cell number from row and column index.
getCell(i::Int, j::Int) = 9(i - 1) + j


# Set cell 'square' to be the given number.
# E.g. if `square == 1` and `number == 2`,
# then we will set entry of square (1, 1) with the value of 2.
# Notice that we will also remove 2 as a choice for the remaining empty squares.
function setCell(gs::GameState, square::Int, number::Number)
    writeNumberToCell(gs, square, number)
    removeNumberFromBlock(gs, square, number)
    removeNumberFromRow(gs, square, number)
    removeNumberFromCol(gs, square, number)
end

# Clear cell does the opposite of set cell.
# Clear cell `square` will remove its number from the corresponding entry,
# while reinstating its possibility to be use by other empty squares.
function clearCell(gs::GameState, square::Int)
    returnNumberToBlock(gs, square)
    returnNumberToRow(gs, square)
    returnNumberToCol(gs, square)
    eraseNumberFromCell(gs, square)
end


# Write number to cell.
function writeNumberToCell(gs::GameState, square::Int, number::Number)
    gs.cell[square] = number
end
# Erase number from cell.
function eraseNumberFromCell(gs::GameState, square::Int)
    gs.cell[square] = BLANK
end


# Remove the number from corresponding (block/row/column) because it has been allocated to a cell within them.
removeNumberFromBlock(gs::GameState, square::Int, number::Number) = removeNumber!(gs.blocks[square], number)
removeNumberFromRow(gs::GameState, square::Int, number::Number) = removeNumber!(gs.rows[square], number)
removeNumberFromCol(gs::GameState, square::Int, number::Number) = removeNumber!(gs.cols[square], number)


# Return the number to corresponding (block/row/column) because it is freed from a cell within them.
returnNumberToBlock(gs::GameState, square::Int) = includeNumber!(gs.blocks[square], gs.cell[square])
returnNumberToRow(gs::GameState, square::Int) = includeNumber!(gs.rows[square], gs.cell[square])
returnNumberToCol(gs::GameState, square::Int) = includeNumber!(gs.cols[square], gs.cell[square])


function main()
    gs = GameState()
    ConsoleInput(gs)
    Place(gs, gs.sequencePointer)
    @printf "\n\nTotal COUNT = %d\n" gs.currentCount

    return 0
end


# Function not in Julia v0.3, but will be added in Julia v0.4.
cld(x::Int, y::Int) = fld((x - 1), y) + 1

end #SudokuSolver
