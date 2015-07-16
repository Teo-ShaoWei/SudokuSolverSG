# This function helps to construct `getBlock`, while keeping the data `location_in_blocks` static (local, yet compute-once and persistent).
function getBlock_constructor()
    # Function not in Julia v0.3, but will be added in Julia v0.4.
    cld(x::Int, y::Int) = fld((x - 1), y) + 1

    location_in_blocks = Array(Int, 9, 9)
    for row in 1:9, col in 1:9
        location_in_blocks[row, col] = 3 * (cld(row, 3) - 1) + cld(col, 3)
    end

    return (cell::Cell) -> location_in_blocks[cell.row, cell.col]
end
getBlock = getBlock_constructor()
getRow(cell::Cell) = cell.row
getCol(cell::Cell) = cell.col


Base.getindex(s::GameState, cell::Cell) = s.data[cell.row, cell.col]
Base.setindex!(s::GameState, number::Number, cell::Cell) = (s.data[cell.row, cell.col] = number)

Base.getindex(s::CellsState, cell::Cell) = s.data[cell.row, cell.col]
Base.setindex!(s::CellsState, number::Number, cell::Cell) = (s.data[cell.row, cell.col] = number)

Base.getindex(s::ComponentState, cell::Cell) = s.data[s.findComponentIndex(cell)]

Base.length(s::SequenceState) = Base.length(s.data)
Base.getindex(s::SequenceState, i::Int) = s.data[i]
Base.getindex(s::SequenceState, r::UnitRange) = [s.data[i] for i in r]
Base.setindex!(s::SequenceState, cell::Cell, i::Int) = (s.data[i] = cell)

Base.getindex(lc::LevelCount, i::Int) = lc.data[i]
Base.setindex!(lc::LevelCount, value::Int, i::Int) = (lc.data[i] = value)

writeSolution(solutions::Vector{Matrix{Number}}, s::CellsState) = Base.push!(solutions, deepcopy(s.data))
getTotalCount(lc::LevelCount) = sum(lc.data)

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


# Get the remaining number left that can be filled into indicated cell.
getRemainingNumbers(gs::GameState, cell::Cell) = gs.blocks[cell] ∩ gs.rows[cell] ∩ gs.cols[cell]


(∩)(set₁::LeftoverNumbers, set₂::LeftoverNumbers) = LeftoverNumbers(set₁.val_bits & set₂.val_bits)
function removeNumber!(set::LeftoverNumbers, i::Int)
    set.val_bits &= ~(1 << i)
end
function includeNumber!(set::LeftoverNumbers, i::Int)
    set.val_bits |= (1 << i)
end
getSize(set::LeftoverNumbers) = count_ones(set.val_bits)


Base.start(iter::LeftoverNumbers) = iter.val_bits
function Base.next(iter::LeftoverNumbers, state)
    i = state & (-state) #Lowest 1 bit in state.
    state &= ~i
    return (trailing_zeros(i), state)
end
Base.done(iter::LeftoverNumbers, state) = (state == zero(Uint16))


function SwapSeqEntries(gs::GameState, S1::Int, S2::Int)
    (gs.sequence[S1], gs.sequence[S2]) = (gs.sequence[S2], gs.sequence[S1])
end
