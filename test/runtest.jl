module TestCapsule
using FactCheck
using SudokuSolver: main

function generateTestCase()
    row = Array(String, 9)

    row[1] = "---------\n"
    row[2] = "-----3-85\n"
    row[3] = "--1-2----\n"
    row[4] = "---5-7---\n"
    row[5] = "--4---1--\n"
    row[6] = "-9-------\n"
    row[7] = "5------73\n"
    row[8] = "--2-1----\n"
    row[9] = "----4---9\n"

    return string(row...)
end

expectedOutput() = "Row[1] : Row[2] : Row[3] : Row[4] : Row[5] : Row[6] : Row[7] : Row[8] : Row[9] : \n --- --- ---\n --- --3 -85\n --1 -2- ---\n\n --- 5-7 ---\n --4 --- 1--\n -9- --- ---\n\n 5-- --- -73\n --2 -1- ---\n --- -4- --9\n\n 987 654 321\n 246 173 985\n 351 928 746\n\n 128 537 694\n 634 892 157\n 795 461 832\n\n 519 286 473\n 472 319 568\n 863 745 219\n\nLevel Counts:\n\n(3, 9):   1 (8, 9):   2 (4, 9):   4 (5, 9):   8 (6, 9):  15 (1, 9):  23 \n(3, 8):  33 (8, 8):  46 (4, 8):  79 (1, 8): 119 (5, 8): 182 (6, 8): 250 \n(9, 8): 287 (4, 7): 347 (6, 7): 478 (6, 5): 588 (6, 1): 732 (6, 3): 828 \n(6, 4): 862 (6, 6): 895 (4, 5): 795 (4, 3): 761 (5, 5): 843 (7, 5): 829 \n(2, 5): 616 (1, 5): 594 (2, 7): 543 (2, 3): 565 (7, 3): 551 (2, 4): 577 \n(3, 6): 565 (3, 4): 590 (1, 4): 572 (1, 6): 595 (7, 4): 612 (5, 4): 576 \n(7, 6): 476 (7, 7): 389 (7, 2): 262 (4, 2): 184 (2, 2): 140 (2, 1):  95 \n(5, 6):  56 (8, 7):  34 (8, 6):  18 (3, 1):  13 (8, 1):  10 (3, 7):   7 \n(3, 2):   8 (1, 7):  10 (5, 1):  10 (5, 2):   6 (8, 2):   4 (8, 4):   2 \n(9, 1):   1 (1, 1):   1 (9, 2):   1 (9, 3):   1 (9, 4):   1 (4, 1):   1 \n(9, 6):   1 (9, 7):   1 (1, 3):   1 (1, 2):   1 \n\nCount = 17698\n\n\nTotal Count = 24395\n"

@time facts("System test.") do
    originalSTDIN = STDIN
    (_, stdin) = redirect_stdin()

    originalSTDOUT = STDOUT
    (stdout, _) = redirect_stdout()

    write(stdin, generateTestCase())

    main()

    redirect_stdin(originalSTDIN)
    redirect_stdout(originalSTDOUT)

    @fact readavailable(stdout) => expectedOutput()
end

end #TestCapsule
