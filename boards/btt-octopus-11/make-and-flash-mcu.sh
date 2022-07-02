#!/bin/bash
set -e -u -o pipefail

## based on https://github.com/Rat-OS/RatOS-configuration/blob/master/boards/btt-octopus-11/make-and-flash-mcu.sh

declare -r MCU=/dev/btt-octopus-11
declare -r VENDORDEVICEID="0483:df11"

basedir=$( dirname "$( readlink -f "${0}" )" )
declare -r basedir

declare -r KSRC="/home/pi/klipper"
declare -r KCFG="/home/pi/klipper_config"
declare -r FW_BIN=${KCFG}/firmware_binaries

declare -r MAKE=( make KCONFIG_CONFIG="${basedir}/firmware.config" )
declare -r MAKE_FLASH_MCU=( "${MAKE[@]}" flash "FLASH_DEVICE=${MCU}" )
declare -r MAKE_FLASH_DFU=( "${MAKE[@]}" flash "FLASH_DEVICE=${VENDORDEVICEID}" )

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

if [ ! -d ${FW_BIN} ]; then
    mkdir ${FW_BIN}
fi

cd ${KSRC}

function cleanup() {
    rc=$?

    chown pi:pi -R ${KSRC} ${FW_BIN}

    service klipper start

    exit $rc
}
trap cleanup EXIT

"${MAKE[@]}" olddefconfig
"${MAKE[@]}" clean
"${MAKE[@]}"

cp -f out/klipper.bin ${FW_BIN}/firmware-btt-octopus-11.bin

service klipper stop
if [ -h $MCU ]; then
    echo "Flashing Octopus via path"
    "${MAKE_FLASH_MCU[@]}"
else
    echo "Flashing Octopus via vendor and device ids - 1st pass"
    "${MAKE_FLASH_DFU[@]}"
fi

sleep 5

if [ -h $MCU ]; then
    echo "Flashing Successful!"
else
    echo "Flashing Octopus via vendor and device ids - 2nd pass"
    "${MAKE_FLASH_DFU[@]}"

    sleep 5

    if [ -h $MCU ]; then
        echo "Flashing Successful!"
    else
        echo "Flashing Octopus via vendor and device ids - 3rd pass"
        if "${MAKE_FLASH_DFU[@]}" ; then
            echo "Flashing successful!"
        else
            echo "Flashing failed :("
            exit 1
        fi
    fi
fi

