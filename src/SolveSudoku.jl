module SudokuSolver

InBlock = Array(Int, 81); InRow = Array(Int, 81); InCol = Array(Int, 81)

const BLANK = 0
const ONES = 0x3fe

Entry = Array(Int,81)
Block = Array(Int, 9); Row = Array(Int, 9); Col = Array(Int, 9)

SeqPtr = 1
Sequence = Array(Int, 81)

Count = 0
LevelCount = Array(Int, 82)


function SwapSeqEntries(S1::Int, S2::Int)
    temp = Sequence[S2]
    Sequence[S2] = Sequence[S1]
    Sequence[S1] = temp
end


function InitEntry(i::Int, j::Int, val::Int)
    global SeqPtr

    Square = 9(i - 1) + j
    valbit = 1 << val

    # Add suitable checks for data consistency.

    Entry[Square] = valbit
    Block[InBlock[Square]] &= ~valbit
    Col[InCol[Square]] &= ~valbit #Simpler Col[j] &= ~valbit
    Row[InRow[Square]] &= ~valbit #Simpler Row[i] &= ~valbit

    SeqPtr2 = SeqPtr
    while SeqPtr2 ≤ 81 && Sequence[SeqPtr2] != Square
        SeqPtr2 += 1
    end

    SwapSeqEntries(SeqPtr, SeqPtr2)
    SeqPtr += 1
end


function PrintArray()
    Square = 1

    for i in 1:9
        (i % 3 == 1) && println()
        for j in 1:9
            (j % 3 == 1) && print(' ')
            valbit = Entry[Square]
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
        @printf "Row[%d] : " i
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
    while LevelCount[S] == 0
        S += 1
    end

    i = 1

    while S ≤ 81
        Seq = Sequence[S]
        @printf "(%d, %d):%4d " cld(Seq, 9) rem1(Seq, 9) LevelCount[S]
        if (i ≥ 4)
            @printf "\n"
            i = 1
        else
            i += 1
        end
        S += 1
    end

    @printf "\n\nCount = %d\n" Count
end


function Succeed()
    PrintArray()
    PrintStats()
end


function NextSeq(S::Int)
    S2 = zero(Int)
    MinBitCount = 100

    for T in S:81
        Square = Sequence[T]
        Possibles = Block[InBlock[Square]] & Row[InRow[Square]] & Col[InCol[Square]]
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
    global Count

    LevelCount[S] += 1
    Count += 1

    if S > 81
        Succeed()
        return
    end

    S2 = NextSeq(S)
    SwapSeqEntries(S, S2)

    Square = Sequence[S]

    BlockIndex = InBlock[Square]
    RowIndex = InRow[Square]
    ColIndex = InCol[Square]

    Possibles = Block[BlockIndex] & Row[RowIndex] & Col[ColIndex]
    while Possibles != 0
        valbit = Possibles & (-Possibles) #Lowest 1 bit in Possibles.
        Possibles &= ~valbit
        Entry[Square] = valbit
        Block[BlockIndex] &= ~valbit
        Row[RowIndex] &= ~valbit
        Col[ColIndex] &= ~valbit

        Place(S + 1)

        Entry[Square] = BLANK #Could be moved out of the loop.
        Block[BlockIndex] |= valbit
        Row[RowIndex] |= valbit
        Col[ColIndex] |= valbit
    end

    SwapSeqEntries(S, S2)
end



function main()
    for i in 1:9, j in 1:9
        Square = 9(i - 1) + j
        InRow[Square] = i
        InCol[Square] = j
        InBlock[Square] = 3 * (cld(i, 3) - 1) + cld(j, 3)
    end

    for Square in 1:81
        Sequence[Square] = Square
        Entry[Square] = BLANK
        LevelCount[Square] = 0
    end

    for i in 1:9
        Block[i] = Row[i] = Col[i] = ONES
    end

    ConsoleInput()
    Place(SeqPtr)
    @printf "\n\nTotal Count = %d\n" Count

    return 0
end


# Function not in Julia v0.3, but will be added in Julia v0.4.
cld(x::Int, y::Int) = fld((x - 1), y) + 1

end #SudokuSolver
