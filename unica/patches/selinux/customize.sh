# UN1CA SELinux entries removal list (VENDORLESS)
# Cleans ONLY system_ext and plat sepolicy
# Vendor is NOT present and NOT referenced

# One UI 8.0 additions
ENTRIES+="
heatmap_default
heatmap_default_exec
"

# One UI 7.0 additions
ENTRIES+="
attiqi_app
attiqi_app_data_file
ker_app
kpp_app
kpp_data_file
"

# One UI 6.1.1 additions
ENTRIES+="
hal_dsms_default
hal_dsms_default_exec
proc_compaction_proactiveness
sbauth
sbauth_exec
"

# One UI 5.1.1 additions
ENTRIES+="
audiomirroring
audiomirroring_exec
audiomirroring_service
fabriccrypto
fabriccrypto_exec
fabriccrypto_data_file
hal_dsms_service
uwb_regulation_skip_prop
"

GET_SYSTEM_EXT()
{
    if $TARGET_HAS_SYSTEM_EXT; then
        echo "system_ext"
    else
        echo "system/system/system_ext"
    fi
}

# Detect current platform mapping CIL
CIL_NAME="33.0"
API_LIST="$(ls "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping" \
            | sed '/.compat./d' | sed 's/.cil//' | sed 's/\./_/' | sort)"

for e in $ENTRIES; do
    LOG "- Removing \"$e\" from system_ext"

    sed -i "/($e)/d" \
        "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"

    for a in $API_LIST; do
        sed -i "/${e}_${a}/d" \
            "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"
    done

    if [ -f "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil" ]; then
        sed -i "/genfscon.*$e/d" \
            "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil"
    fi

    if [ -f "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil" ]; then
        sed -i "/genfscon.*$e/d" \
            "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
    fi
done

LOG_STEP_IN "- Apply genfscon rules fix to plat_sepolicy.cil"

PLAT_SEPOLICY="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
[ -f "$PLAT_SEPOLICY" ] && sed -i "$PLAT_SEPOLICY" \
    -e '\#(genfscon bpf "/cputimeinstate" (u object_r fs_bpf_cputimeinstate ((s0) (s0))))#d' \
    -e '\#(genfscon proc "/sys/vm/dirty_writeback_centisecs" (u object_r proc_dirty ((s0) (s0))))#d' \
    -e '\#(genfscon proc "/sys/kernel/firmware_config" (u object_r proc_firmware_config ((s0) (s0))))#d' \
    -e '\#(genfscon sysfs "/devices/virtual/misc/ublk-control/" (u object_r sysfs_ublk ((s0) (s0))))#d' \
    -e '\#(genfscon sysfs "/devices/virtual/block/ublk" (u object_r sysfs_ublk ((s0) (s0))))#d' \
    -e '\#(genfscon sysfs "/class/ublk-char/" (u object_r sysfs_ublk ((s0) (s0))))#d' \
    -e '\#(genfscon sysfs "/kernel/btf" (u object_r sysfs_btf ((s0) (s0))))#d' \
    -e '\#(genfscon tracefs "/events/f2fs/f2fs_set_page_dirty/" (u object_r debugfs_tracing ((s0) (s0))))#d' \
    -e '\#(genfscon tracefs "/hypervisor" (u object_r debugfs_tracing ((s0) (s0))))#d'

LOG_STEP_OUT

unset ENTRIES CIL_NAME API_LIST
unset -f GET_SYSTEM_EXT
