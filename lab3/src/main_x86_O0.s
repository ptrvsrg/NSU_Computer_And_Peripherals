MonteCarloAlgorithm:
        pushl   %ebp                   // добавить адрес возврата в стек
        movl    %esp, %ebp             // запомнить адрес текущего кадра стека
        subl    $56, %esp              // зарезервировать 56 байт для локальных переменных
        subl    $12, %esp              // зарезервировать ещё 12 байт
        pushl   $0                     // добавить в стек NULL для time
        call    time                   // вызов time
        addl    $16, %esp              //
        subl    $12, %esp              // сместить esp, чтобы исключить NULL из стека
        pushl   %eax                   // поместить значение eax в стек (в eax хранится результат time)
        call    srand                  // вызов srand
        addl    $16, %esp              // сместить esp, чтобы исключить значение eax из стека и вернуть ранее выделившиеся 12 байт
        fldz                           // загрузить 0 в стек сопроцессора (инициализация double insideCount)
        fstpl   -16(%ebp)              // сохранить st(0) в стек
        movl    $0, -20(%ebp)          // создать i и присвоить 0
        jmp     .L2                    // безусловный переход в метку .L2
.L5:
        call    rand                   // вызов rand
        movl    %eax, -52(%ebp)        // копировать eax(результат rand()) в стек
        fildl   -52(%ebp)              // загрузить результат rand() в стек сопроцессора и преобразовать в double
        fldl    .LC1                   // загрузить константу из метки .LC1 в стек сопроцессора
        fdivrp  %st, %st(1)            // разделить результат st(1) на st(0), присвоить в st(1) и вытолкнуть st(0) (rand() / RAND_MAX)
        fstpl   -32(%ebp)              // извлечь st(0) в стек (double x)
        call    rand                   // вызов rand
        movl    %eax, -52(%ebp)        // копировать eax(результат rand) в стек
        fildl   -52(%ebp)              // загрузить результат rand в стек сопроцессора и преобразовать в double
        fldl    .LC1                   // загрузить константу из метки .LC1 в стек сопроцессора
        fdivrp  %st, %st(1)            // разделить результат st(1) на st(0), присвоить в st(1) и вытолкнуть st(0) (rand() / RAND_MAX)
        fstpl   -40(%ebp)              // извлечь st(0) в стек (double y)
        fldl    -32(%ebp)              // загрузить x в стек сопроцессора
        fld     %st(0)                 // дублировать вершину стека сопроцессора (копировать х)
        fmulp   %st, %st(1)            // умножить х на х и вытолкнуть st(0)
        fldl    -40(%ebp)              // загрузить у в стек сопроцессора
        fmul    %st(0), %st            // умножить у на у
        faddp   %st, %st(1)            // сложить х*х + у*у и вытолкнуть st(0)
        fld1                           // загрузить 1 в стек сопроцессора
        fcomip  %st(1), %st            // сравнить st(1) и st(0) ((х*х + у*у) и 1.0)
        fstp    %st(0)                 // сохранить вершину стека сопроцессора в st(0)
        jb      .L3                    // переход в метку .L3, если по результатам fcomip %st(1) < %st  
        fldl    -16(%ebp)              // загрузить insideCount в стек сопроцессора
        fldl    .LC3                   // загрузить константу из метки .LC3 (4.0) в стек сопроцессора
        faddp   %st, %st(1)            // прибавить к 4.0 insideCount
        fstpl   -16(%ebp)              // извлечь st(0) в стек (присвоить результат сложения insideCount)
.L3:
        addl    $1, -20(%ebp)          // прибавить 1 к i (++i)
.L2:
        movl    -20(%ebp), %eax        // копировать i в eax
        cmpl    8(%ebp), %eax          // сравнить i и count
        jl      .L5                    // переход в метку .L5, если i < count
        fildl   8(%ebp)                // загрузить count в стек сопроцессора и преобразовать double
        fldl    -16(%ebp)              // загрузить insideCount в стек сопроцессора
        fdivp   %st, %st(1)            // разделить st(1) на st(0) (insideCount на count)
        leave                          // сбросить кадр стека
        ret                            // выход из подпрограммы MonteCarloAlgorithm
.LC5:
        .string "PI: %lf\n"
main:
        leal    4(%esp), %ecx          // вычислить эффективный адрес 4(%esp) и поместить в ecx
        andl    $-16, %esp             // логическое и -16 & %esp
        pushl   -4(%ecx)               // добавить в стек содержимое -4(%ecx)
        pushl   %ebp                   // добавить адрес возврата в стек
        movl    %esp, %ebp             // запомнить адрес текущего кадра стека
        pushl   %ecx                   // добавить в стек содержимое %ecx
        subl    $20, %esp              // зарезервировать 20 байтов для локальных переменных
        movl    $100000000, -12(%ebp)  // создать count и инциализировать 100000000
        subl    $12, %esp              // отступить 12 байтов от локальных переменных
        pushl   -12(%ebp)              // добавить в стек count, как аргумент для вызова MonteCarloAlgorithm
        call    MonteCarloAlgorithm    // вызов MonteCarloAlgorithm
        addl    $16, %esp              // вернуть 16 байт
        fstpl   -24(%ebp)              // извлечь вершину st(0) в стек (результат MonteCarloAlgorithm)
        subl    $4, %esp               // отступить 4 байтов от локальных переменных
        pushl   -20(%ebp)              //
        pushl   -24(%ebp)              // добавить в стек pi, как второй аргумент для вызова printf 
        pushl   $.LC5                  // добавить в стек строку из метки .LC5, как первый аргумент для вызова printf 
        call    printf                 // вызов printf
        addl    $16, %esp              // вернуть 16 байт
        movl    $0, %eax               // копировать в eax 0 (код завершения функции main)
        movl    -4(%ebp), %ecx         // копировать в ecx -4(%ebp)
        leave                          // сбросить кадр стека
        leal    -4(%ecx), %esp         // вычислить эффективный адрес -4(%ecx) и поместить в esp
        ret                            // выход из подпрограммы main
.LC1:
        .long   -4194304               // RAND_MAX
        .long   1105199103
.LC3:
        .long   0                      // 4.0
        .long   1074790400