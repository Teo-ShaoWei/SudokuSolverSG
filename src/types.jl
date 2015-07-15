# Represents the number to fill into a cell, i.e. 1 to 9.
typealias Number Int

# Represents a subset of {1, 2, ..., 9},
# which in turn represents the leftover number that can be use to fill the corresponding cells.
typealias PossibleValue Uint
typealias LeftoverNumbers Uint

# Represents the index of a cell.
# The index counts from 1, starting at the top left, moving to right, then row-by-row to the bottom, ending with 81.
typealias Index Int

# The state of the game currently.
# This will evolve as the Sudoku puzzle is being solved.
type GameState
    cell::Vector{Number}

    leftoverNumbers_block::Vector{LeftoverNumbers}
    leftoverNumbers_row::Vector{LeftoverNumbers}
    leftoverNumbers_col::Vector{LeftoverNumbers}

    block_of::Vector{Index}
    row_of::Vector{Index}
    col_of::Vector{Index}

    sequence::Vector{Index}
    sequencePointer::Index

    currentCount::Int
    levelCount::Vector{Int}
end

function GameState()
    cell = Array(Number, 81)

    leftoverNumbers_block = Array(LeftoverNumbers, 9)
    leftoverNumbers_row = Array(LeftoverNumbers, 9)
    leftoverNumbers_col = Array(LeftoverNumbers, 9)

    block_of = Array(Index, 81)
    row_of = Array(Index, 81)
    col_of = Array(Index, 81)

    sequence = Array(Index, 81)
    sequencePointer = one(Index)

    currentCount = zero(Int)
    levelCount = Array(Int, 82)

    for i in 1:9, j in 1:9
        square = getCell(i, j)

        cell[square] = BLANK

        block_of[square] = 3 * (cld(i, 3) - 1) + cld(j, 3)
        row_of[square] = i
        col_of[square] = j

        sequence[square] = square
        levelCount[square] = zero(Int)
    end

    for i in 1:9
        leftoverNumbers_block[i] = leftoverNumbers_row[i] = leftoverNumbers_col[i] = ONES
    end


    return GameState(cell,

                     leftoverNumbers_block,
                     leftoverNumbers_row,
                     leftoverNumbers_col,

                     block_of,
                     row_of,
                     col_of,

                     sequence,
                     sequencePointer,

                     currentCount,
                     levelCount)
end
