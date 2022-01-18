#!/bin/bash -

subst.exe O: $PWD
cd /o/
python build_tfm.py -m NUCLEO_L552ZE_Q_S -c RegressionIPC
cd -
./STM32_TFM_postbuild.sh
mbed compile -m NUCLEO_L552ZE_Q_S -t GCC_ARM -v
BUILD/NUCLEO_L552ZE_Q_S/GCC_ARM/regression.sh
BUILD/NUCLEO_L552ZE_Q_S/GCC_ARM/TFM_UPDATE.sh
