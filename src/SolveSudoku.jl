module SudokuSolver

include("constants.jl")
include("types.jl")
include("operations.jl")
include("process solution.jl")


# Solve the input Sudoku puzzle.
# All solutions found are printed to STDOUT, and returned.
function solveSudoku(input::Matrix{Number})
    gs = GameState()
    numbersFilled = populateGame!(gs, input)
    placeNextNumber!(gs, numbersFilled)

    @printf "\n\nTotal COUNT = %d\n" getTotalCount(gs.levelCount)

    return gs.solutions
end


# Populate the initial state of the game using the input Sudoku puzzle.
# Return the number of cells filled up by the input.
function populateGame!(gs::GameState, input::Matrix{Number})
    numbersFilled = 0

    for i in 1:9, j in 1:9
        if input[i, j] != 0
            cell = Cell(i, j)
            setCell!(gs, cell, input[i, j])
            numbersFilled += 1
            swapSequenceEntries!(gs, numbersFilled, findfirst(gs.sequence, cell))
        end
    end

    return numbersFilled
end


# Place the next number.
# Choose a cell and run through all the possible numbers we can place in it.
# A solution is found if we filled up all the cells successfully.
function placeNextNumber!(gs::GameState, numbersFilled::Int)
    if numbersFilled ≥ 81
        # Solution found.
        processSolution!(gs)
        return
    end

    currentIndex = numbersFilled + 1
    gs.levelCount[currentIndex] += 1

    nextCellIndex = chooseNextCell(gs, currentIndex)
    swapSequenceEntries!(gs, currentIndex, nextCellIndex)

    cell::Cell = gs.sequence[currentIndex]

    leftoverNumbers::LeftoverNumbers = getLeftoverNumbers(gs, cell)
    for number in leftoverNumbers
        setCell!(gs, cell, number)
        placeNextNumber!(gs, numbersFilled + 1)
        clearCell!(gs, cell)
    end

    swapSequenceEntries!(gs, currentIndex, nextCellIndex)

    return
end


# Choose the next cell to fill in number.
# Not all cell are equally good,
# we choose one that has the least possible numbers to fill in, for efficiency sake.
# This is to reduce branching, and increase chance of early termination.
function chooseNextCell(gs::GameState, currentIndex::Int)
    nextIndex = currentIndex
    MinTotalChoices = 10 #Max bitCount of any cell is 9.

    for T in currentIndex:81
        cell::Cell = gs.sequence[T]
        leftoverNumbers::LeftoverNumbers = getLeftoverNumbers(gs, cell)
        totalChoices = getSize(leftoverNumbers)

        if totalChoices < MinTotalChoices
            MinTotalChoices = totalChoices
            nextIndex = T
        end
    end

    return nextIndex
end


end #SudokuSolver
