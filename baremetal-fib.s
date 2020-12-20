.align 2
.section .text
.globl _start
_start:
        csrr    a1, mhartid             # read hardware thread id (`hart` stands for `hardware thread`)
        bnez    a1, halt                # run only on the first hardware thread (hartid == 0), halt all the other threads

        la      sp, stack_top           # setup stack pointer

        jal     main                    # call main()

halt:   j       halt

.global main
main:
        # test printf()
        la      a0, hello_fmt
        la      a1, hello_arg
        call    printf

        # calculate Fibonacci sequence
        # for (int i = 1; i < 15; i++)
        #     printf("fib(%d) = %d\n", i, fib(i));
        li      s0, 1
        li      s1, 15
1:      mv      a0, s0
        jal     fib                     # call fib() with a0 containing index of Fibonacci sequence.
                                        # fib() will return result in a0.

        addi    sp, sp, -8              # allocate 2 int arguments for printf() on the stack
        mv      a1, sp
        sd      s0, 0(a1)               # 1st printf argument s0 contains index i
        sd      a0, 4(a1)               # 2nd prinnt argument a0 contains result of fib(i)
        la      a0, fib_fmt
        call    printf                  # call printf() with a0 pointing to "fib(%d) = %d\n" pattern
                                        #                and a1 pointing to list of arguments [i, fib(i)] stored on stack
        addi    sp, sp, 8               # restore stack

        addi    s0, s0, 1               # i++
        blt     s0, s1, 1b              # loop while i < 15

        ret

.global fib
fib:
        li      t0, 1
        li      t1, 2

        beq     a0, t0, 1f
        beq     a0, t1, 1f

        mv      t0, a0
        addi    a0, t0, -1              # calculate n-1

        addi    sp, sp, -16
        sd      ra, 0(sp)
        sd      t0, 8(sp)               # preserve t0, which contains our original argument
        jal     fib
        ld      ra, 0(sp)
        ld      t0, 8(sp)
        addi    sp, sp, 16

        mv      t2, a0                  # t2 now contains fib(n-1)

        addi    a0, t0, -2              # calculate n-2

        addi    sp, sp, -16
        sd      ra, 0(sp)
        sd      t2, 8(sp)               # preserve t2, which has fib(n-1)
        jal     fib
        ld      ra, 0(sp)
        ld      t2, 8(sp)
        addi    sp, sp, 16

        mv      t3, a0                  # t3 now contains fib(n-2)
        add     a0, t2, t3              # add them and jump to return
        j       2f

1:
        li      a0, 1

2:
        ret

.section .rodata
hello_str:
        .string "Hello world!!!\n"
hello_fmt:
        .string "%sHello %% %c%c%c%c%c%c%c: %d %i %u %o %x %X _start=%p main=%p fib=%p this-str=%p unknown pattern type: %q.\n"
hello_arg:
        .dword hello_str
        .ascii "numbers"
        .int 20
        .int -30
        .int -30
        .int 0100 # 64 in octal
        .int 0xAA55
        .int -1
        .dword _start
        .dword main
        .dword fib
        .dword hello_fmt
fib_fmt:
        .string "fib(%d) = %d\n"
