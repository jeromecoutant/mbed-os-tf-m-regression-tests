#!/bin/bash -

# Execute postbuild.sh in order to update regression.sh and TFM_UPDATE.sh before copy to mbed-os
tfm/repos/trusted-firmware-m/cmake_build/postbuild.sh
cp -v tfm/repos/trusted-firmware-m/cmake_build/regression.sh mbed-os/targets/TARGET_STM/TARGET_STM32L5/TARGET_STM32L552xE/TARGET_NUCLEO_L552ZE_Q/TFM_S_FW/
cp -v tfm/repos/trusted-firmware-m/cmake_build/TFM_UPDATE.sh mbed-os/targets/TARGET_STM/TARGET_STM32L5/TARGET_STM32L552xE/TARGET_NUCLEO_L552ZE_Q/TFM_S_FW/

# Copy all bin/map/elf files locally
mkdir tfm/bin
cp -v tfm/repos/trusted-firmware-m/cmake_build/bin/* tfm/bin/

# few patches before mbed-os build
cd mbed-os/targets/TARGET_STM/TARGET_STM32L5/TARGET_STM32L552xE/TARGET_NUCLEO_L552ZE_Q/TFM_S_FW/
sed -i 's/FLASH_LAYOUT_FOR_TEST/MBED_CONF_APP_REGRESSION_TEST/' partition/flash_layout.h
sed -i '/STM32CubeProgrammer/d' regression.sh
sed -i 's/tfm_ns_signed/tfm_mbed-os-tf-m-regression-tests_signed/' TFM_UPDATE.sh
sed -i 's/-el $external_loader//g' TFM_UPDATE.sh
sed -i '/STM32CubeProgrammer/d' TFM_UPDATE.sh
echo >> TFM_UPDATE.sh
echo '$stm32programmercli $connect' >> TFM_UPDATE.sh

# check if STM32CubeProgrammer is available in environment path
which STM32_Programmer_CLI &> /dev/null
if [ $? -ne 0 ]; then
    echo STM32_Programmer_CLI is not part of environment path
    echo 'PATH="/C/Program Files/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/":$PATH'
    echo 'PATH="~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/":$PATH'
    exit 1
fi
