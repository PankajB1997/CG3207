@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto bca7e3ccb3814e87ae07dbada2a553f2 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot test_top_behav xil_defaultlib.test_top -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
