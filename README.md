# mbed-os-tf-m-regression-tests

This is an Mbed-flavored application which enables the user to run the
**TF-M regression test suite (default)** or the **PSA Compliance test suite**
for **Trusted Firmware-M** (**TF-M**) integrated with the **Mbed OS**.

The version of TF-M can be found in `dependencies["released-tfm"]` in
[`psa_builder.py`](psa_builder.py).

## Prerequisites

We have provided a ready-to-use Vagrant virtual machine for building
TF-M tests, see [`vagrant/README.md`](vagrant/README.md) for instructions.

If you prefer to build and run the tests directly on your host machine,
please have the following set up.

### TF-M build environment

The following tools are needed for building TF-M:
* Commands: see [`vagrant/bootstrap.sh`](./vagrant/bootstrap.sh) for Linux,
or install equivalent packages for your operating system.
* Python environment: see [`vagrant/bootstrap-user.sh`](./vagrant/bootstrap-user.sh).
* One of the supported compilers: see "Compiler versions" on
[Arm Mbed tools](https://os.mbed.com/docs/mbed-os/v6.7/build-tools/index.html).
Make sure the compiler has been added to the `PATH` of your environment.

### Mbed OS build tools

#### Mbed CLI 2
Starting with version 6.5, Mbed OS uses Mbed CLI 2. It uses Ninja as a build system,
and CMake to generate the build environment and manage the build process in a
compiler-independent manner. If you are working with Mbed OS version prior to 6.5
then check the section [Mbed CLI 1](#mbed-cli-1).
1. [Install Mbed CLI 2](https://os.mbed.com/docs/mbed-os/latest/build-tools/install-or-upgrade.html).
1. From the command-line, import the example: `mbed-tools import mbed-os-tf-m-regression-tests`
1. Change the current directory to where the project was imported.

#### Mbed CLI 1
1. [Install Mbed CLI 1](https://os.mbed.com/docs/mbed-os/latest/quick-start/offline-with-mbed-cli.html).
1. From the command-line, import the example: `mbed import mbed-os-tf-m-regression-tests`
1. Change the current directory to where the project was imported.

### Mbed initialization

Run `mbed deploy` to obtain Mbed OS for this application. Then run
```
python3 -m pip install -r mbed-os/requirements.txt
```
to install dependencies for the Mbed tools.

## Building TF-M

We are building for the ARM Musca B1 (`ARM_MUSCA_B1`) in our example
below, but other targets can be built for by changing the `-m` option.
This builds the `CoreIPC` config by default.

```
python3 build_tfm.py -m ARM_MUSCA_B1 -t GNUARM
```

**Note**: This step does not build any test suites, but the files and binaries
generated are checked into Mbed OS repository at the time of release, which
further supports the building of [mbed-os-example-psa](https://github.com/ARMmbed/mbed-os-example-psa)
without the user requiring to go through the complex process.

To display help on supported options and targets:

```
python3 build_tfm.py -h
```

## NUCLEO-L552ZE

NUCLEO_L552ZE_Q is supported in mbed-os master repo without Trust Zone support.

Few updates are then needed to support Trsut Zone and TFM.
Please use https://github.com/jeromecoutant/mbed/tree/WIP_STM32L5_TFMz
```
python build_tfm.py -m NUCLEO_L552ZE_Q
```

For debug, memory size is too small for full debug symbol, use RelWithDebInfo option:
```
python build_tfm.py -m NUCLEO_L552ZE_Q --buildtype RelWithDebInfo
```

## Building the TF-M Regression Test suite

Use the `-c` option to specify the config to override the default.

```
python3 build_tfm.py -m ARM_MUSCA_B1 -t GNUARM -c RegressionIPC
```

Then follow [Building the Mbed OS application](#Building-the-Mbed-OS-application)
to build an application that runs the test suite.

## Building the PSA Compliance Test suites

**Note**: If you build on macOS, run:
```
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
```

Run `build_tfm.py` with the PSA API config to build for a target.
Different suites can be built using the `-s` option.

```
python3 build_tfm.py -m ARM_MUSCA_B1 -t GNUARM -c PsaApiTestIPC -s CRYPTO
```

Then follow [Building the Mbed OS application](#Building-the-Mbed-OS-application)
to build an application that runs the test suite.

**Notes**:
* To see all available suites, run `python3 build_tfm.py -h`.
* Make sure the TF-M Regression Test suite has **PASSED** on the board before
running any PSA Compliance Test suite to avoid unpredictable behavior.
* M2354 hasn't supported PSA compliance test yet.
* NUCLEO_L552ZE_Q doesn't support PSA compliance test yet.

## Building the Mbed OS application

After building the [TF-M regression](#Building-the-TF-M-Regression-Test) or
[PSA compliance tests](#Building-the-PSA-Compliance-Test) for the target, it should be
followed by building a Mbed OS application. This will execute the test suites previously built.

Configure an appropriate test in the `config` section of `mbed_app.json`. If you want to
*flash and run tests manually*, please set `wait-for-sync` to 0 so that tests start without
waiting.

Run one of the following commands to build the application

* Mbed CLI 2

    ```
    $ mbed-tools compile -m <TARGET> -t <TOOLCHAIN>
    ```

* Mbed CLI 1

    ```bash
    $ mbed compile -m <TARGET> -t <TOOLCHAIN>
    ```

The binary is located at:
* **Mbed CLI 2** - `./cmake_build/<TARGET>/<PROFILE>/<TOOLCHAIN>/mbed-os-tf-m-regression-tests.bin`</br>
* **Mbed CLI 1** - `./BUILD/<TARGET>/<TOOLCHAIN>/mbed-os-tf-m-regression-tests.bin`

## Building NUCLEO_L552ZE_Q

* Mbed CLI 2 is not supported yet

* Mbed CLI 1 release application:
```
$ mbed compile -m NUCLEO_L552ZE_Q -t GCC_ARM
```

* Mbed CLI 1 RegressionIPC test application:
```
$ mbed compile -m NUCLEO_L552ZE_Q -t GCC_ARM -DFLASH_LAYOUT_FOR_TEST
```


## Running the Mbed OS application manually

1. Connect your Mbed Enabled device to the computer over USB.
1. Copy the binary or hex file to the Mbed device.
1. Connect to the Mbed Device using a serial client application of your choice.
1. Press the reset button on the Mbed device to run the program.

**Note:** The default serial port baud rate is 115200 baud.

## NUCLEO_L552ZE_Q flashing

For NUCLEO_L552ZE_Q, drag and drop feature to copy secured binary files is not supported.

You need to install [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html) application

and add it in your environment path:
```
PATH="/C/Program Files/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/":$PATH

or

PATH="~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/":$PATH
```

Then execute 2 scripts in this order:
```
BUILD/NUCLEO_L552ZE_Q/GCC_ARM/regression.sh
BUILD/NUCLEO_L552ZE_Q/GCC_ARM/TFM_UPDATE.sh
```

## Reference logs

Greentea can be used:

- with release application:
```
htrun --skip-flashing -v --serial-output-file tfm_application.log -p COM16:115200 --sync=0 -P 40 --compare-log tfm_application_reference.log
```

- with RegressionIPC test application:
```
htrun --skip-flashing -v --serial-output-file tfm_test.log -p COM16:115200 --sync=0 -P 100 --compare-log tfm_test_reference.log
```

Expected result:
```
[1643815540.78][HTST][INF] Target log matches compare log!
[1643815540.78][HTST][INF] test suite run finished after 54.33 sec...
[1643815540.79][CONN][INF] received special event '__host_test_finished' value='True', finishing
[1643815540.82][HTST][INF] CONN exited with code: 0
[1643815540.82][HTST][INF] No events in queue
[1643815540.82][HTST][INF] stopped consuming events
[1643815540.82][HTST][INF] host test result() call skipped, received: True
[1643815540.82][HTST][WRN] missing __exit event from DUT
[1643815540.82][HTST][WRN] missing __exit_event_queue event from host test
[1643815540.82][HTST][INF] calling blocking teardown()
[1643815540.82][HTST][INF] teardown() finished
[1643815540.82][HTST][INF] {{result;success}}
```


## Automating all test suites

This will build and execute TF-M regression and PSA compliance tests with
Mbed OS application, using the [Greentea](https://os.mbed.com/docs/mbed-os/v6.7/debug-test/greentea-for-testing-applications.html) test tool. Make sure the device is connected to your local machine.

* Mbed CLI 2 (default)

    ```
    python3 test_psa_target.py -t GNUARM -m ARM_MUSCA_B1
    ```

* Mbed CLI 1

    ```
    python3 test_psa_target.py -t GNUARM -m ARM_MUSCA_B1 --cli=1
    ```

**Notes**:
* The tests cannot be run in the Vagrant
environment, which does not have access to the USB of the host machine to
connect the target. You can use it to build all the tests by running `test_psa_target.py`
with `-b` then copying `BUILD/` and `test_spec.json` to the host.
* To run all tests from an existing build, run `test_psa_target.py` with `-r`.
* If you want to flash and run tests manually instead of automating them with Greentea,
you need to pass `--no-sync` so that tests start without waiting.

To display help on supported options and targets:

```
python3 test_psa_target.py -h
```

## Expected test results

When you automate all tests, the Greentea test tool compares the test results with the logs in [`test/logs`](./test/logs) and prints a test report. *All test suites should pass or match the numbers of known failures in the logs.*

* M2354 hasn't supported PSA compliance test yet.

## Troubleshooting

### Protected Storage (PS) test failures on Musca S1

Since TF-M v1.3.0, Musca S1's Protected Storage (PS) is located in the target's QSPI flash.
Normally tests should run without issues, but in case data in the QSPI flash is not cleaned up
properly (e.g. it has been used for other purposes previously or a test run has been interrupted), you
may need to erase it as follows:

1. Unplug your Musca S1 board if connected.
1. Change the position of the "BOOT" switch on your board to "QSPI", then connect the board to your PC.
1. Copy [`tfm/utils/musca_s1_ps_erase.hex`](tfm/utils/musca_s1_ps_erase.hex) onto the board until the
board remounts.
1. Unplug your Musca S1 board, change the position of the "BOOT" switch to "MRAM", and reconnect to run
the tests again.

**Note**: `musca_s1_ps_erase.hex` is included in this repository, but you can also generate it
as follows:

1. Create an binary of 64KB filled with 0xFF. The PS area is 20KB but Musca S1's DAPLink aligns
program operations to 64KB. On Linux (or macOS with commands from GNU coreutils), it can be done
as follows

    ```
    dd if=/dev/zero bs=65536 count=1 | tr "\000" "\377" > tmp.bin
    ```

2. Convert the binary into an Intel HEX file with an offset:

    ```
    srec_cat tmp.bin -Binary -offset 0x00200000 -o musca_s1_ps_erase.hex -Intel
    ```

### Firmware Update test failures on M2354

The M2354 build configures TF-M to use a microSD card as the update staging area. Insert a microSD card into the slot on the board to allow the tests to pass.

Alternatively you can configure TF-M to use embedded flash as the update staging area with the following CMake variables:

```
set(NU_UPDATE_STAGE_SDH     ON      CACHE BOOL      "Whether enable SDH as update staging area")
set(NU_UPDATE_STAGE_FLASH   OFF     CACHE BOOL      "Whether enable embedded flash as update staging area")
```

The configuration variables must be passed in on the command line when building TF-M with CMake. The provided scripts in this repository don't have a mechanism for forwarding command line arguments to CMake, so to configure TF-M in this way you have to build TF-M using CMake commands.
