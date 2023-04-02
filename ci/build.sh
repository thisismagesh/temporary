#!/usr/bin/env bash

set -e
rom_name=$(grep init $CIRRUS_WORKING_DIR/build_rom.sh -m 1 | cut -d / -f 4)
branch_name=$(grep init $CIRRUS_WORKING_DIR/build_rom.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
rom_name=$rom_name-$branch_name
ax613_roms=" crdroidandroid-13.0 Octavi-Staging-thirteen "
if [[ $ax613_roms != *" $rom_name "* ]]; then exit 0; fi
device=$(grep unch $CIRRUS_WORKING_DIR/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
grep _jasmine_sprout $CIRRUS_WORKING_DIR/build_rom.sh > /dev/null && device=jasmine_sprout
grep _laurel_sprout $CIRRUS_WORKING_DIR/build_rom.sh > /dev/null && device=laurel_sprout
grep _GM8_sprout $CIRRUS_WORKING_DIR/build_rom.sh > /dev/null && device=GM8_sprout
grep _maple_dsds $CIRRUS_WORKING_DIR/build_rom.sh > /dev/null && device=maple_dsds
cd ~/roms/$rom_name
export CCACHE_DIR=~/ccache/$rom_name/$device
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 8G
ccache -z
ls device/*/*/vendorsetup.sh | grep -v generic && echo "Please remove vendorsetup.sh file from device tree, use local manifest for cloning and removing repositories." && exit 1 || true
command=$(tail $CIRRUS_WORKING_DIR/build_rom.sh -n +$(expr $(grep 'build/envsetup.sh' $CIRRUS_WORKING_DIR/build_rom.sh -n | cut -f1 -d:) - 1)| head -n -1 | grep -v 'rclone copy')
bash -c "$command"
