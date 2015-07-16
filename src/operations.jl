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

Base.getindex(s::CellsState, cell::Cell) = s.data[cell.row, cell.col]
Base.setindex!(s::CellsState, number::Number, cell::Cell) = (s.data[cell.row, cell.col] = number)

Base.getindex(s::ComponentState, cell::Cell) = s.data[s.findComponentIndex(cell)]

Base.getindex(s::SequenceState, i::Int) = s.data[i]
Base.setindex!(s::SequenceState, cell::Cell, i::Int) = (s.data[i] = cell)

Base.getindex(lc::LevelCount, i::Int) = lc.data[i]
Base.setindex!(lc::LevelCount, value::Int, i::Int) = (lc.data[i] = value)


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
