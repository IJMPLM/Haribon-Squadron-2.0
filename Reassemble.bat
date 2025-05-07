@echo off
REM Clean reassembly batch file for Haribon Squadron
TASM /m2 /zi Main.asm
TLINK /v Main.obj
DEL Main.obj