#!/bin/bash
set -e -u -o pipefail

if [ $# -ne 1 ]; then
    echo "usage: $0 <canbus_uuid>"
    exit 1
fi

declare -r can_iface="can0"
declare -r canbus_uuid="${1}"

boardname=$( basename "$( dirname "${0}" )" )
basedir=$( dirname "$( readlink -f "${0}" )" )
declare -r basedir boardname

declare -r USER="${SUDO_USER:-${USER}}"
user_home=$( getent passwd "${USER}" | cut -d : -f 6 )
declare -r user_home

declare -r KSRC="${user_home}/klipper"
declare -r KCFG="${user_home}/klipper-config"

declare -r FW_BIN=${KCFG}/firmware_binaries

declare -r MAKE=( make KCONFIG_CONFIG="${basedir}/firmware.config" )

# if [ "$EUID" -ne 0 ]; then
#     echo "ERROR: Please run as root"
#     exit 1
# fi

if [ ! -d ${FW_BIN} ]; then
    mkdir ${FW_BIN}
fi

cd ${KSRC}

function cleanup() {
    rc=$?

    chown ${USER}:${USER} -R ${KSRC} ${FW_BIN}

    service klipper start

    exit $rc
}
trap cleanup EXIT

"${MAKE[@]}" olddefconfig
"${MAKE[@]}" clean
"${MAKE[@]}"

cp -f out/klipper.bin "${FW_BIN}/${boardname}.bin"
cp -f out/klipper.dict "${FW_BIN}/${boardname}.dict"

service klipper stop
if lib/canboot/flash_can.py -i "${can_iface}" -f out/klipper.bin -u "${canbus_uuid}" ; then
    echo "Flashing successful!"
else
    echo "Flashing failed :("
    exit 1
fi
