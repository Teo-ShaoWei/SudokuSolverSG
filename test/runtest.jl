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

@time facts("System test.") do
    originalSTDIN = STDIN
    (_, stdin) = redirect_stdin()

    originalSTDOUT = STDOUT
    (stdout, _) = redirect_stdout()

    write(stdin, generateTestCase())

    main()

    redirect_stdin(originalSTDIN)
    redirect_stdout(originalSTDOUT)

    cd(dirname(@__FILE__)) do
        writedlm("result", [readavailable(stdout)])

        result = readall("result")
        expected = readall("expected")

        @fact result => expected
    end
end

end #TestCapsule
