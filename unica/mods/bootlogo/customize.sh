if [[ $TARGET_SINGLE_SYSTEM_IMAGE == "essi" || $TARGET_SINGLE_SYSTEM_IMAGE == "essi_64" ]]; then
    LOG_STEP_IN "- Exynos device detected. Adding custom up_param."
    if $TARGET_HAS_QHD_DISPLAY; then
        cp -a "$SRC_DIR/unica/mods/bootlogo/up_param_1440p.bin" "$WORK_DIR/up_param.bin"
    else
        cp -a "$SRC_DIR/unica/mods/bootlogo/up_param_1080p.bin" "$WORK_DIR/up_param.bin"
    fi
    LOG_STEP_OUT
else
    LOG "- Non-Exynos device detected. Skipping custom up_param."
fi

# S25 Ultra OneUI 8.5 -> SoundBooster 2060
# S21 Series -> SoundBooster 1050
# S21 FE -> SoundBooster 1070

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
