### Types

# Represents the number to fill into a cell, i.e. 1 to 9.
typealias Number Int


# A subset of {1, 2, ..., 9}, which represents the leftover number that can be use to fill the corresponding cells.
type LeftoverNumbers
    val_bits::Uint16
end


# Represents a cell.
# In natural order, (1, 1) is the top left, (9, 1) the bottom left, and (9, 9) the bottom right.
immutable Cell
    row::Int
    col::Int
end


# Represent the state of all the cells
immutable CellsState
    data::Matrix{Number}
end


# Represent the state of components like the blocks, rows, and columns.
# The function `findComponentIndex` is used to find the index in the component of the given cell.
immutable ComponentState
    data::Vector{LeftoverNumbers}
    findComponentIndex::Function
end


immutable SequenceState
    data::Vector{Cell}
end


immutable LevelCount
    data::Vector{Int}
end



# The state of the game currently.
# This will evolve as the Sudoku puzzle is being solved.
type GameState
    cells::CellsState

    blocks::ComponentState
    rows::ComponentState
    cols::ComponentState

    sequence::SequenceState
    sequencePointer::Int

    currentCount::Int
    levelCount::LevelCount
end


### Constructors

# Each cell is left blank initially.
CellsState() = CellsState([BLANK for i in 1:9, j in 1:9])

# Each leftover numbers in the component is initialize with the full set {1, 2,..., 9} inside.
ComponentState(findComponentIndex::Function) = ComponentState([LeftoverNumbers(ONES) for i in 1:9], findComponentIndex)


function SequenceState()
    data = Array(Cell, 81)
    index = 1
    for i in 1:9, j in 1:9
        data[index] = Cell(i, j)
        index += 1
    end
    SequenceState(data)
end


LevelCount() = LevelCount([zero(Int) for i in 1:82])

function GameState()
    sequencePointer = one(Int)
    currentCount = zero(Int)

    return GameState(CellsState(),

                     ComponentState(getBlock),
                     ComponentState(getRow),
                     ComponentState(getCol),

                     SequenceState(),
                     sequencePointer,

                     currentCount,
                     LevelCount())
end
