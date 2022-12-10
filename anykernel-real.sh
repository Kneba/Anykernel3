### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
kernel.for=KernelForDriver
kernel.compiler=SDPG
kernel.made=kernel@made
kernel.version=4.4.xxx
message.word=ooflol
build.date=2077
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=X00TD
device.name2=X00T
device.name3=Zenfone Max Pro M1 (X00TD)
device.name4=ASUS_X00TD
device.name5=ASUS_X00T
supported.versions=
supported.patchlevels=
'; } # end properties

### AnyKernel install
# begin attributes
attributes() {
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 755 755 $ramdisk/init* $ramdisk/sbin;
} # end attributes

## boot shell variables
block=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh && attributes;

# Mount partitions as rw
mount /system;
mount /vendor;
mount -o remount,rw /system;
mount -o remount,rw /vendor;


# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

# begin EAS patch changes
if [ ! -e "/vendor/etc/powerhint.json" ]; then
    ui_print " You are using an HMP based ROM"
    ui_print "EAS PerfHAL is required only If you want to flash EAS kernel on HMP ROM"
    ui_print " Installing EAS PerfHAL automatically..."
    rm -rf /data/adb/modules/SDM660PerfHAL;
    cp -rf $home/tools/SDM660PerfHAL /data/adb/modules/SDM660PerfHAL;
else
    ui_print " " "You are using an EAS based ROM"
    ui_print "Then you no longer need to install PerfHAL"
fi

# init.rc
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";

# init.tuna.rc
backup_file init.tuna.rc;
insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
append_file init.tuna.rc "bootscript" init.tuna;

# fstab.tuna
backup_file fstab.tuna;
patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
patch_fstab fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
patch_fstab fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
append_file fstab.tuna "usbdisk" fstab;

# remove spectrum profile
if [ -e $ramdisk/init.spectrum.rc ];then
  rm -rf $ramdisk/init.spectrum.rc
  ui_print "delete /init.spectrum.rc"
fi
if [ -e $ramdisk/init.spectrum.sh ];then
  rm -rf $ramdisk/init.spectrum.sh
  ui_print "delete /init.spectrum.sh"
fi
if [ -e $ramdisk/sbin/init.spectrum.rc ];then
  rm -rf $ramdisk/sbin/init.spectrum.rc
  ui_print "delete /sbin/init.spectrum.rc"
fi
if [ -e $ramdisk/sbin/init.spectrum.sh ];then
  rm -rf $ramdisk/sbin/init.spectrum.sh
  ui_print "delete /sbin/init.spectrum.sh"
fi
if [ -e $ramdisk/etc/init.spectrum.rc ];then
  rm -rf $ramdisk/etc/init.spectrum.rc
  ui_print "delete /etc/init.spectrum.rc"
fi
if [ -e $ramdisk/etc/init.spectrum.sh ];then
  rm -rf $ramdisk/etc/init.spectrum.sh
  ui_print "delete /etc/init.spectrum.sh"
fi
if [ -e $ramdisk/init.aurora.rc ];then
  rm -rf $ramdisk/init.aurora.rc
  ui_print "delete /init.aurora.rc"
fi
if [ -e $ramdisk/sbin/init.aurora.rc ];then
  rm -rf $ramdisk/sbin/init.aurora.rc
  ui_print "delete /sbin/init.aurora.rc"
fi
if [ -e $ramdisk/etc/init.aurora.rc ];then
  rm -rf $ramdisk/etc/init.aurora.rc
  ui_print "delete /etc/init.aurora.rc"
fi


write_boot;
## end boot install


## init_boot shell variables
#block=init_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#block=vendor_kernel_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot shell variables
#block=vendor_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install

