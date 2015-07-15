module SudokuSolver

include("constants.jl")
include("types.jl")


function SwapSeqEntries(gs::GameState, S1::Int, S2::Int)
    (gs.sequence[S1], gs.sequence[S2]) = (gs.sequence[S2], gs.sequence[S1])
end

function InitEntry(gs::GameState, i::Int, j::Int, val::Int)
    Square = getCell(i, j)
    valbit::Number = 1 << val

    # Add suitable checks for data consistency.

    setCell(gs, Square, valbit)

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
            valbit = gs.cell[Square]
            Square += 1
            if valbit == 0
                ch = '-'
            else
                for val in 1:9
                    if valbit == (1 << val)
                        ch = '0' + val
                        break
                    end
                end
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
        BitCount = 0
        while Possibles != 0
            Possibles &= ~(Possibles & -Possibles)
            BitCount += 1
        end

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
    while Possibles != 0
        valbit = Possibles & (-Possibles) #Lowest 1 bit in Possibles.
        Possibles &= ~valbit
        setCell(gs, Square, valbit)
        Place(gs, S + 1)
        clearCell(gs, Square)
    end

    SwapSeqEntries(gs, S, S2)
end


# Get the remaining number left that can be filled into given `square`.
getRemainingNumbers(gs::GameState, square::Int) = gs.leftoverNumbers_block[gs.block_of[square]] & gs.leftoverNumbers_row[gs.row_of[square]] & gs.leftoverNumbers_col[gs.col_of[square]]


# Get cell number from row and column index.
getCell(i::Int, j::Int) = 9(i - 1) + j


# Set cell 'square' to be the possible value represented by `value`.
# E.g. if `square == 1` and `value == 0x100` (representing 2 for 2 trailing zeroes),
# then we will set entry of square (1, 1) with the value of 2.
# Notice that we will also remove 2 as a choice for the remaining empty squares.
function setCell(gs::GameState, square::Int, value::LeftoverNumbers)
    writeNumberToCell(gs, square, value)
    removeNumberFromBlock(gs, square, value)
    removeNumberFromRow(gs, square, value)
    removeNumberFromCol(gs, square, value)
end

# Clear cell does the opposite of set cell.
# Clear cell `square` will remove its value from the corresponding entry,
# while reinstating its possibility to be use by other empty squares.
function clearCell(gs::GameState, square::Int)
    returnNumberToBlock(gs, square)
    returnNumberToRow(gs, square)
    returnNumberToCol(gs, square)
    eraseNumberFromCell(gs, square)
end


# Write number to cell.
function writeNumberToCell(gs::GameState, square::Int, value::LeftoverNumbers)
    gs.cell[square] = value
end
# Erase number from cell.
function eraseNumberFromCell(gs::GameState, square::Int)
    gs.cell[square] = BLANK
end


# Remove the number from corresponding (block/row/column) because it has been allocated to a cell within them.
function removeNumberFromBlock(gs::GameState, square::Int, value::LeftoverNumbers)
    gs.leftoverNumbers_block[gs.block_of[square]] &= ~value
end
function removeNumberFromRow(gs::GameState, square::Int, value::LeftoverNumbers)
    gs.leftoverNumbers_row[gs.row_of[square]] &= ~value
end
function removeNumberFromCol(gs::GameState, square::Int, value::LeftoverNumbers)
    gs.leftoverNumbers_col[gs.col_of[square]] &= ~value
end


# Return the number to corresponding (block/row/column) because it is freed from a cell within them.
function returnNumberToBlock(gs::GameState, square::Int)
    gs.leftoverNumbers_block[gs.block_of[square]] |= gs.cell[square]
end
function returnNumberToRow(gs::GameState, square::Int)
    gs.leftoverNumbers_row[gs.row_of[square]] |= gs.cell[square]
end
function returnNumberToCol(gs::GameState, square::Int)
    gs.leftoverNumbers_col[gs.col_of[square]] |= gs.cell[square]
end


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
