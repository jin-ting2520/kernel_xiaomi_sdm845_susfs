#!/usr/bin/env bash

set -e -u -o pipefail

OUTPUT_DIR=out
MAKE_VARIABLES=(
    ARCH=arm64
    SUBARCH=arm64
    CROSS_COMPILE=aarch64-linux-gnu-
    CROSS_COMPILE_ARM32=arm-none-eabi-
    O="$OUTPUT_DIR"
)

config() {
    make "${MAKE_VARIABLES[@]}" dipper_defconfig
}

xconfig() {
    make "${MAKE_VARIABLES[@]}" xconfig
}

menuconfig() {
    #make "${MAKE_VARIABLES[@]}" menuconfig
    echo menuconfig is not working
}

build() {
    make "${MAKE_VARIABLES[@]}" -j "$(nproc)"
}

clean() {
    make "${MAKE_VARIABLES[@]}" clean
}

distclean() {
    make "${MAKE_VARIABLES[@]}" distclean
}

case "${1:-}" in
*)
    "$1"
    ;;
esac
