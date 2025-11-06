# AsmJIT

## What is this?

Just a toy Just-In-Time (JIT) compiler I'm hacking on. It's written 100% in x86-64 NASM assembly for Linux.

I was just messing around to see if I could build one from scratch, right from the syscalls up.

## What's it do?

**--- (New changes) ---**

It now reads a text file (like `test.sb`) containing a *super* simple math expression (literally just `number + number` for now).

Then it:
1.  Uses syscalls (`open`, `read`) to get the expression from the file.
2.  Parses the numbers.
3.  Allocates some executable memory using `mmap`.
4.  Generates the raw machine code for `mov rax, num1; add rax, num2; ret` and writes it into that memory.
5.  Jumps to that new code and runs it.
6.  The program exits, and the answer is returned as the exit code.

It used to segfault all the time, but I went back and **added proper error checking** for all the syscalls, so it's much more stable now.

## How to use

You'll need `nasm` and `ld`.

**1. Build it:**
Just run make.
```sh
make
