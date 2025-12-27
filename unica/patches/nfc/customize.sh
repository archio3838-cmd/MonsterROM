TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci.conf" 0 0 644 "u:object_r:system_file:s0"
else
    DELETE_FROM_WORK_DIR "system" "system/etc/libnfc-nci.conf"
fi
if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci_temp.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci_temp.conf" 0 0 644 "u:object_r:system_file:s0"
else
    DELETE_FROM_WORK_DIR "system" "system/etc/libnfc-nci_temp.conf"
fi
if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci-NXP_SN100U.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-NXP_SN100U.conf" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci-NXP_PN553.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-NXP_PN553.conf" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci-SLSI.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-SLSI.conf" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/libnfc-nci-STM_ST21.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/libnfc-nci-STM_ST21.conf" 0 0 644 "u:object_r:system_file:s0"
fi

if [ "$(GET_PROP "vendor" "ro.vendor.nfc.feature.chipname")" ] && \
        ! [[ "$(GET_PROP "vendor" "ro.vendor.nfc.feature.chipname")" =~ NXP_SN100U|SLSI|STM_ST21 ]]; then
    ABORT "Unknown NFC chip name: $(GET_PROP "vendor" "ro.vendor.nfc.feature.chipname")"
fi

# SEC_PRODUCT_FEATURE_NFC_CHIP_NAME:=SLSI
# - Same lib name as before, check for TARGET_PLATFORM_SDK_VERSION instead
if [ -f "$WORK_DIR/system/system/lib/libnfc_sec_jni.so" ]; then
    if [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib/libnfc_sec_jni.so" ] && \
            [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib64/libnfc_sec_jni.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib/libnfc_sec_jni.so"
    fi
elif [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib/libnfc_sec_jni.so" ] || \
        [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib64/libnfc_sec_jni.so" ]; then
    if [ "$TARGET_PLATFORM_SDK_VERSION" -ge "36" ]; then
        ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib/libnfc_sec_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"
    else
        ADD_TO_WORK_DIR "r11sxxx" "system" "system/lib/libnfc_sec_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
fi
if [ -f "$WORK_DIR/system/system/lib64/libnfc_sec_jni.so" ]; then
    if [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib64/libnfc_sec_jni.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libnfc_sec_jni.so"
    fi
elif [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib64/libnfc_sec_jni.so" ]; then
    if [ "$TARGET_PLATFORM_SDK_VERSION" -ge "36" ]; then
        ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libnfc_sec_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"
    else
        ADD_TO_WORK_DIR "r11sxxx" "system" "system/lib64/libnfc_sec_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
fi

unset TARGET_FIRMWARE_PATH
