DUPLICATES+="
init.svc.vendor.wvkprov_server_hal
"
for e in $DUPLICATES; do
 # the problematic entry is found in target vendor
 LOG "- \"$e\" SELinux duplicate entry found. Removing"
 sed -i "s/^$e/#SEC_DUPLICATE: $e/g" "$WORK_DIR/vendor/etc/selinux/vendor_property_contexts"
done

LOG_STEP_IN "- Apply genconfsrulesfix to platsepolicy.cil"
# Delete specific genfscon lines
PLAT_SEPOLICY="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
sed -i "$PLAT_SEPOLICY" \
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

unset ENTRIES DUPLICATES CIL_NAME VENDOR_API_LIST
unset -f GET_SYSTEM_EXT
