if [[ $TARGET_SINGLE_SYSTEM_IMAGE == "qssi" || $TARGET_SINGLE_SYSTEM_IMAGE == "essi" ]]; then
    LOG_STEP_IN "- Target device with 32-Bit HALs detected."

    LOG_STEP_IN "- Adding S23 FE (r11sxxx) lib/ blobs"
    ADD_TO_WORK_DIR "r11sxxx" "system" "system/lib" 0 0 644

    BLOBS_LIST="
    system/apex/com.android.i18n.apex
    system/apex/com.android.runtime.apex
    system/apex/com.google.android.tzdata6.apex
    system/bin/bootstrap/linker
    system/bin/bootstrap/linker_asan
    "
    for blob in $BLOBS_LIST
    do
        ADD_TO_WORK_DIR "r11sxxx" "system" "$blob"
    done
    LOG_STEP_OUT

    LOG_STEP_IN "- Creating symlinks"
    ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker"
    ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker_asan"
    SET_METADATA "system" "system/bin/linker" 0 0 755 "u:object_r:system_file:s0"
    SET_METADATA "system" "system/bin/linker_asan" 0 0 755 "u:object_r:system_file:s0"

    ln -sf "/apex/com.android.runtime/lib/bionic/libc.so" "$WORK_DIR/system/system/lib/libc.so"
    ln -sf "/apex/com.android.runtime/lib/bionic/libdl.so" "$WORK_DIR/system/system/lib/libdl.so"
    ln -sf "/apex/com.android.runtime/lib/bionic/libdl_android.so" "$WORK_DIR/system/system/lib/libdl_android.so"
    ln -sf "/apex/com.android.runtime/lib/bionic/libm.so" "$WORK_DIR/system/system/lib/libm.so"
    SET_METADATA "system" "system/lib/libc.so" 0 0 644 "u:object_r:system_lib_file:s0"
    SET_METADATA "system" "system/lib/libdl.so" 0 0 644 "u:object_r:system_lib_file:s0"
    SET_METADATA "system" "system/lib/libdl_android.so" 0 0 644 "u:object_r:system_lib_file:s0"
    SET_METADATA "system" "system/lib/libm.so" 0 0 644 "u:object_r:system_lib_file:s0"
    LOG_STEP_OUT

    LOG_STEP_IN "- Setting props"
    SET_PROP "vendor" "ro.vendor.product.cpu.abilist" "arm64-v8a"
    SET_PROP "vendor" "ro.vendor.product.cpu.abilist32" ""
    SET_PROP "vendor" "ro.vendor.product.cpu.abilist64" "arm64-v8a"
    SET_PROP "vendor" "ro.zygote" "zygote64"
    SET_PROP "vendor" "dalvik.vm.dex2oat64.enabled" "true"
    SET_PROP "vendor" "ro.apex.updateable" "true"
    LOG_STEP_OUT

    LOG_STEP_OUT
else
    LOG "- Target device does not use 32-Bit HALs. Ignoring."
fi
LOG_STEP_IN "- Replacing SoundBooster"
DELETE_FROM_WORK_DIR "system" "system/lib64/lib_SoundBooster_ver2060.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/lib_SAG_EQ_ver2060.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libsoundboostereq_legacy.so"
if [[ "$TARGET_CODENAME" != "m30s"  ]]; then
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/lib_SoundBooster_ver1000.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsamsungSoundbooster_plus_legacy.so" 0 0 644 "u:object_r:system_lib_file:s0"
else 
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/lib_SoundBooster_ver1000.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsamsungSoundbooster_plus_legacy.so" 0 0 644 "u:object_r:system_lib_file:s0"
fi
LOG_STEP_OUT
echo "Settling up configuration"
IFS=':' read -a SOURCE_EXTRA_FIRMWARES <<< "$SOURCE_FIRMWARE"
MODEL=$(echo -n "${SOURCE_FIRMWARE[0]}" | cut -d "/" -f 1)
REGION=$(echo -n "${SOURCE_FIRMWARE[0]}" | cut -d "/" -f 2)

echo "Setting up prism"

echo "Debloating prism"
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/app
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/HWRDB
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/lost+found
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/media
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/priv-app

echo "Settling up a prism symlink"
rm -rf $WORK_DIR/system/prism
ln -s /system/prism $WORK_DIR/system/prism

SET_METADATA "system" "system/prism" 0 0 755 "u:object_r:system_file:s0"

# Intentionally break the source firmwares file contexts to make our life easier
{
    sed "s/^\/prism/\/system\/prism/g" "$FW_DIR/${MODEL}_${REGION}/file_context-prism"
} >> "$FW_DIR/${MODEL}_${REGION}/file_context-system"

{
    sed "1d" "$FW_DIR/${MODEL}_${REGION}/fs_config-prism" | sed "s/^prism/system\/prism/g"
} >> "$FW_DIR/${MODEL}_${REGION}/fs_config-system"

cat "$FW_DIR/${MODEL}_${REGION}/fs_config-system" | grep -F "system/prism" >> "$WORK_DIR/configs/fs_config-system"
cat "$FW_DIR/${MODEL}_${REGION}/file_context-system" | grep -F "system/prism" >> "$WORK_DIR/configs/file_context-system"

echo "Installing prism"
cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/prism" "$WORK_DIR/system/system"

echo "Setting up optics"

rm -rf $FW_DIR/${MODEL}_${REGION}/optics/lost+found

echo "Settling up an optics symlink"
rm -rf $WORK_DIR/system/optics
ln -s /system/optics $WORK_DIR/system/optics

SET_METADATA "system" "system/optics" 0 0 755 "u:object_r:system_file:s0"

# Intentionally break the source firmwares file contexts to make our life easier
{
    sed "s/^\/optics/\/system\/optics/g" "$FW_DIR/${MODEL}_${REGION}/file_context-optics"
} >> "$FW_DIR/${MODEL}_${REGION}/file_context-system"

{
    sed "1d" "$FW_DIR/${MODEL}_${REGION}/fs_config-optics" | sed "s/^optics/system\/optics/g"
} >> "$FW_DIR/${MODEL}_${REGION}/fs_config-system"

cat "$FW_DIR/${MODEL}_${REGION}/fs_config-system" | grep -F "system/optics" >> "$WORK_DIR/configs/fs_config-system"
cat "$FW_DIR/${MODEL}_${REGION}/file_context-system" | grep -F "system/optics" >> "$WORK_DIR/configs/file_context-system"

echo "Installing optics"
cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/optics" "$WORK_DIR/system/system"

echo "CSC was adapted successfully!"
