# cpu8085
BASIC Interpreter for 8085 CPU

Graduation Project École Polytechnique de Montréal (2002)

The project presented consists of a simple BASIC interpreter built from scratch in 8085 assembly language

To get there I built:
- Prototype BASIC in C++ (CPU8085/basic/prototypes)
- 8085 emulator in C++ (CPU8085/emulatorbase)
- BASIC Interpreter in 8085 ASM (CPU8085/basic)

In 2018 the C++ projects were upgraded to Visual Studio 2017 and a bit of work was done to enhance the 8085 emulator.

Some IO libraries were adjusted to fit the new hardware

Optimizations were also made to some routines (mostly INT_ITOA)
