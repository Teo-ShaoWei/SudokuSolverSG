module SudokuSolver

include("constants.jl")
include("types.jl")

IN_BLOCK = Array(Int, 81); IN_ROW = Array(Int, 81); IN_COL = Array(Int, 81)

ENTRY = Array(PossibleValue, 81)
BLOCK = Array(PossibleValue, 9); ROW = Array(PossibleValue, 9); COL = Array(PossibleValue, 9)

SEQ_PTR = 1
SEQUENCE = Array(Int, 81)

COUNT = 0
LEVEL_COUNT = Array(Int, 82)


function SwapSeqEntries(S1::Int, S2::Int)
    (SEQUENCE[S1], SEQUENCE[S2]) = (SEQUENCE[S2], SEQUENCE[S1])
end

function InitEntry(i::Int, j::Int, val::Int)
    global SEQ_PTR

    Square = getCell(i, j)
    valbit::PossibleValue = 1 << val

    # Add suitable checks for data consistency.

    setCell(Square, valbit)

    SeqPtr2 = SEQ_PTR
    while SeqPtr2 ≤ 81 && SEQUENCE[SeqPtr2] != Square
        SeqPtr2 += 1
    end

    SwapSeqEntries(SEQ_PTR, SeqPtr2)
    SEQ_PTR += 1
end


function PrintArray()
    Square = 1

    for i in 1:9
        (i % 3 == 1) && println()
        for j in 1:9
            (j % 3 == 1) && print(' ')
            valbit = ENTRY[Square]
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


function ConsoleInput()
    for i in 1:9
        @printf "ROW[%d] : " i
        InputString = readline(STDIN)

        for j in 1:9
            ch = InputString[j]
            if ch ≥ '1' && ch ≤ '9'
                InitEntry(i, j, ch - '0')
            end
        end
    end

    PrintArray()
end


function PrintStats()
    @printf "\nLevel Counts:\n\n"

    S = 1
    while LEVEL_COUNT[S] == 0
        S += 1
    end

    i = 1

    while S ≤ 81
        Seq = SEQUENCE[S]
        @printf "(%d, %d):%4d " cld(Seq, 9) rem1(Seq, 9) LEVEL_COUNT[S]
        if (i > 5)
            @printf "\n"
            i = 1
        else
            i += 1
        end
        S += 1
    end

    @printf "\n\nCOUNT = %d\n" COUNT
end


function Succeed()
    PrintArray()
    PrintStats()
end


function NextSeq(S::Int)
    S2 = zero(Int)
    MinBitCount = 100

    for T in S:81
        Square = SEQUENCE[T]
        Possibles = getRemainingNumbers(Square)
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


function Place(S::Int)
    global COUNT

    LEVEL_COUNT[S] += 1
    COUNT += 1

    if S > 81
        Succeed()
        return
    end

    S2 = NextSeq(S)
    SwapSeqEntries(S, S2)

    Square = SEQUENCE[S]

    Possibles = getRemainingNumbers(Square)
    while Possibles != 0
        valbit = Possibles & (-Possibles) #Lowest 1 bit in Possibles.
        Possibles &= ~valbit
        setCell(Square, valbit)
        Place(S + 1)
        clearCell(Square)
    end

    SwapSeqEntries(S, S2)
end


# Get the remaining number left that can be filled into given `square`.
getRemainingNumbers(square::Int) = BLOCK[IN_BLOCK[square]] & ROW[IN_ROW[square]] & COL[IN_COL[square]]


# Get cell number from row and column index.
getCell(i::Int, j::Int) = 9(i - 1) + j


# Set cell 'square' to be the possible value represented by `value`.
# E.g. if `square == 1` and `value == 0x100` (representing 2 for 2 trailing zeroes),
# then we will set entry of square (1, 1) with the value of 2.
# Notice that we will also remove 2 as a choice for the remaining empty squares.
function setCell(square::Int, value::PossibleValue)
    writeNumberToCell(square, value)
    removeNumberFromBlock(square, value)
    removeNumberFromRow(square, value)
    removeNumberFromCol(square, value)
end

# Clear cell does the opposite of set cell.
# Clear cell `square` will remove its value from the corresponding entry,
# while reinstating its possibility to be use by other empty squares.
function clearCell(square::Int)
    returnNumberToBlock(square)
    returnNumberToRow(square)
    returnNumberToCol(square)
    eraseNumberFromCell(square)
end


# Write number to cell.
function writeNumberToCell(square::Int, value::PossibleValue)
    ENTRY[square] = value
end
# Erase number from cell.
function eraseNumberFromCell(square::Int)
    ENTRY[square] = BLANK
end


# Remove the number from corresponding (block/row/column) because it has been allocated to a cell within them.
function removeNumberFromBlock(square::Int, value::PossibleValue)
    BLOCK[IN_BLOCK[square]] &= ~value
end
function removeNumberFromRow(square::Int, value::PossibleValue)
    ROW[IN_ROW[square]] &= ~value
end
function removeNumberFromCol(square::Int, value::PossibleValue)
    COL[IN_COL[square]] &= ~value
end


# Return the number to corresponding (block/row/column) because it is freed from a cell within them.
function returnNumberToBlock(square::Int)
    BLOCK[IN_BLOCK[square]] |= ENTRY[square]
end
function returnNumberToRow(square::Int)
    ROW[IN_ROW[square]] |= ENTRY[square]
end
function returnNumberToCol(square::Int)
    COL[IN_COL[square]] |= ENTRY[square]
end


function main()
    initializeGlobalVariables()
    ConsoleInput()
    Place(SEQ_PTR)
    @printf "\n\nTotal COUNT = %d\n" COUNT

    return 0
end


# Initialize the global variable.
function initializeGlobalVariables()
    for i in 1:9, j in 1:9
        Square = getCell(i, j)
        IN_ROW[Square] = i
        IN_COL[Square] = j
        IN_BLOCK[Square] = 3 * (cld(i, 3) - 1) + cld(j, 3)
        SEQUENCE[Square] = Square
        ENTRY[Square] = BLANK
        LEVEL_COUNT[Square] = 0
    end

    for i in 1:9
        BLOCK[i] = ROW[i] = COL[i] = ONES
    end

    global SEQ_PTR = 1
    global COUNT = 0
end


# Function not in Julia v0.3, but will be added in Julia v0.4.
cld(x::Int, y::Int) = fld((x - 1), y) + 1

end #SudokuSolver
