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
