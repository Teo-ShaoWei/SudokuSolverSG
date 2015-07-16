### Types

# Represents the number to fill into a cell, i.e. 1 to 9.
typealias Number Int

# A subset of {1, 2, ..., 9}, which represents the leftover number that can be use to fill the corresponding cells.
type LeftoverNumbers
    val_bits::Uint16
end

# Represents the index of a cell.
# The index counts from 1, starting at the top left, moving to right, then row-by-row to the bottom, ending with 81.
typealias Index Int


# Represent the state of the blocks, rows, and columns respectively.
type ComponentState
    data::Vector{LeftoverNumbers}
    location::Vector{Index}
end


# The state of the game currently.
# This will evolve as the Sudoku puzzle is being solved.
type GameState
    cell::Vector{Number}

    blocks::ComponentState
    rows::ComponentState
    cols::ComponentState

    sequence::Vector{Index}
    sequencePointer::Index

    currentCount::Int
    levelCount::Vector{Int}
end


### Constructors

# Each leftover numbers in the component is initialize with the full set {1, 2,..., 9} inside.
function ComponentState(location::Vector{Index})
    data = [LeftoverNumbers(ONES) for i in 1:9]
    return ComponentState(data, location)
end


function GameState()
    cell = Array(Number, 81)

    location_in_blocks = Array(Index, 81)
    location_in_rows = Array(Index, 81)
    location_in_cols = Array(Index, 81)

    sequence = Array(Index, 81)
    sequencePointer = one(Index)

    currentCount = zero(Int)
    levelCount = Array(Int, 82)

    for i in 1:9, j in 1:9
        square = getCell(i, j)

        cell[square] = BLANK

        location_in_blocks[square] = 3 * (cld(i, 3) - 1) + cld(j, 3)
        location_in_rows[square] = i
        location_in_cols[square] = j

        sequence[square] = square
        levelCount[square] = zero(Int)
    end

    blocks = ComponentState(location_in_blocks)
    rows = ComponentState(location_in_rows)
    cols = ComponentState(location_in_cols)


    return GameState(cell,

                     blocks,
                     rows,
                     cols,

                     sequence,
                     sequencePointer,

                     currentCount,
                     levelCount)
end
