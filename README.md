# cpu8085
BASIC Interpreter for 8085 CPU

Projet de fin d'études (PFE) École Polytechnique de Montréal (2002)
(Graduation Project)

The project presented consists of a simple BASIC interpreter built from scratch in 8085 assembly language

To get there I built:
- Prototype BASIC in C++ (basic/prototypes)
- 8085 emulator in C++ (emulatorbase)
- BASIC Interpreter in 8085 ASM (basic)

In 2018 the C++ projects were upgraded to Visual Studio 2017 and a bit of work was done to enhance the 8085 emulator.

Some IO libraries were adjusted to fit the [new hardware](https://github.com/hotkeysoft/cpu8085-kicad)

Optimizations were also made to some routines (mostly INT_ITOA)
