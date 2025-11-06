AS = nasm
LD = ld

ASMFLAGS = -f elf64 -g -F dwarf
LDFLAGS =

TARGET = jit

SRCS = $(wildcard src/*.asm)
OBJS = $(SRCS:.asm=.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.asm
	$(AS) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(TARGET) $(OBJS)
