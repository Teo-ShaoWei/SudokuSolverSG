module SudokuSolver

typealias PossibleValue Uint

IN_BLOCK = Array(Int, 81); IN_ROW = Array(Int, 81); IN_COL = Array(Int, 81)

const BLANK = 0
const ONES = 0x3fe #0x1111111110

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

    Square = 9(i - 1) + j
    valbit::PossibleValue = 1 << val

    # Add suitable checks for data consistency.

    setEntry(Square, valbit)

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
        setEntry(Square, valbit)
        Place(S + 1)
        clearEntry(Square)
    end

    SwapSeqEntries(S, S2)
end


# Get the remaining number left that can be filled into given `square`.
getRemainingNumbers(square::Int) = BLOCK[IN_BLOCK[square]] & ROW[IN_ROW[square]] & COL[IN_COL[square]]


# Set entry of given `square` to be the possible value represented by `value`.
# E.g. if `square == 1` and `value == 0x100` (representing 2 for 2 trailing zeroes),
# then we will set entry of square (1, 1) with the value of 2.
# Notice that we will also remove 2 as a choice for the remaining empty squares.
function setEntry(square::Int, value::PossibleValue)
    ENTRY[square] = value
    BLOCK[IN_BLOCK[square]] &= ~value
    ROW[IN_ROW[square]] &= ~value
    COL[IN_COL[square]] &= ~value
end

# Clear entry does the opposite of set entry.
# Clear entry of given `square` will remove its value from the corresponding entry,
# while reinstating its possibility to be use by other empty squares.
function clearEntry(square::Int)
    BLOCK[IN_BLOCK[square]] |= ENTRY[square]
    ROW[IN_ROW[square]] |= ENTRY[square]
    COL[IN_COL[square]] |= ENTRY[square]
    ENTRY[square] = BLANK
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
        Square = 9(i - 1) + j
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
