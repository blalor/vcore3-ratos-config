#!/bin/bash
set -e -u -o pipefail

## based on https://github.com/Rat-OS/RatOS-configuration/blob/master/boards/btt-octopus-11/make-and-flash-mcu.sh

declare -r VENDORDEVICEID="1209:beba"

basedir=$( dirname "$( readlink -f "${0}" )" )
declare -r basedir

declare -r KSRC="/home/pi/klipper"
declare -r KCFG="/home/pi/klipper_config"
declare -r FW_BIN=${KCFG}/firmware_binaries

declare -r MAKE=( make KCONFIG_CONFIG="${basedir}/firmware.config" )
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

cp -f out/klipper.bin ${FW_BIN}/huvud.bin
cp -f out/klipper.dict ${FW_BIN}/huvud.dict

service klipper stop

echo "==== install jumper on BOOT1"
echo "Flashing Huvud via vendor and device ids"
"${MAKE_FLASH_DFU[@]}"

echo "==== remove jumper from BOOT1"
