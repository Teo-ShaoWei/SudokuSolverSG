### Types

# Represents the number to fill into a cell, i.e. 1 to 9.
typealias Number Int

# A subset of {1, 2, ..., 9}, which represents the leftover number that can be use to fill the corresponding cells.
type LeftoverNumbers
    val_bits::Uint16
end

# Represents a cell.
# The index counts from 1, starting at the top left, moving to right, then row-by-row to the bottom, ending with 81.
typealias Cell Int


# Represent the state of the blocks, rows, and columns respectively.
type ComponentState
    data::Vector{LeftoverNumbers}
    location::Vector{Cell}
end


# The state of the game currently.
# This will evolve as the Sudoku puzzle is being solved.
type GameState
    cells::Vector{Number}

    blocks::ComponentState
    rows::ComponentState
    cols::ComponentState

    sequence::Vector{Cell}
    sequencePointer::Cell

    currentCount::Int
    levelCount::Vector{Int}
end


### Constructors

# Each leftover numbers in the component is initialize with the full set {1, 2,..., 9} inside.
function ComponentState(location::Vector{Cell})
    data = [LeftoverNumbers(ONES) for i in 1:9]
    return ComponentState(data, location)
end


function GameState()
    cells = Array(Number, 81)

    location_in_blocks = Array(Cell, 81)
    location_in_rows = Array(Cell, 81)
    location_in_cols = Array(Cell, 81)

    sequence = Array(Cell, 81)
    sequencePointer = one(Cell)

    currentCount = zero(Int)
    levelCount = Array(Int, 82)

    for i in 1:9, j in 1:9
        index = getCell(i, j)

        cells[index] = BLANK

        location_in_blocks[index] = 3 * (cld(i, 3) - 1) + cld(j, 3)
        location_in_rows[index] = i
        location_in_cols[index] = j

        sequence[index] = index
        levelCount[index] = zero(Int)
    end

    blocks = ComponentState(location_in_blocks)
    rows = ComponentState(location_in_rows)
    cols = ComponentState(location_in_cols)


    return GameState(cells,

                     blocks,
                     rows,
                     cols,

                     sequence,
                     sequencePointer,

                     currentCount,
                     levelCount)
end
