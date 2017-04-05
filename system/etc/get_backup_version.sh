#!/system/bin/sh

bootsystem=`getprop ro.boot.system`
updatestat=`getprop bootenv.var.updatestat`
system_block="/dev/block/system"
system_block1="/dev/block/system1"
systeminfo_file="/tmp/system/build.prop"
appinfo_file="/tmp/system/vendor/app/build_info"

function err_msg() {
    echo "backup system: $1" > /dev/kmsg
}

function get_version() {
    if [ -f "$appinfo_file" -a -f "$systeminfo_file" ]; then
        #get app version
        version=`cat $appinfo_file|grep appVersion=`
        regexp='.*\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\)'
        app_version=`busybox expr match "$version" $regexp`
        setprop sys.build.appVersionP "$app_version"
        err_msg "get app version $app_version"

        #get app version ext
        version=`cat $appinfo_file|grep appVersionExt=`
        regexp='.*=\([0-9a-z]\+\)'
        app_versionext=`busybox expr match "$version" $regexp`
        setprop sys.build.appVersionExtP "$app_versionext"
        err_msg "get app version ext $app_versionext"
        
        #get app branch
        version=`cat $appinfo_file|grep type=`
        regexp='.*=\([0-9a-z]\+\)'
        app_branch=`busybox expr match "$version" $regexp`
        setprop sys.build.appBranchP "$app_branch"
        err_msg "get app branch ext $app_branch"

        #get system version
        version=`cat $systeminfo_file|grep ro.build.version.incremental`
        sys_version=${version#*=}
        setprop sys.build.osVersionP "$sys_version"
        err_msg "get system version $sys_version"
    else
        err_msg "not find version file"
    fi
}

function mount_backup_system() {
    ret=0
    mkdir /tmp/system
    if [ "$bootsystem" = "1" ]; then
       mount -t ext4 -o ro $system_block /tmp/system
       ret=$?
    elif [ "$bootsystem" = "0" ]; then
        mount -t ext4 -o ro $system_block1 /tmp/system
        ret=$?
    fi
    
    echo $ret
}

function umount_backup_system() {
    ret=0
    umount /tmp/system
    if [ "$ret" != "0" ]; then
        err_msg "umount /tmp/system failed $ret"
    fi
    echo $ret
}

if [ "$updatestat" = "1" ]; then
    ret=$(mount_backup_system)
    if [ "$ret" = "0" ]; then
        $(get_version)
    else
        err_msg "mount /tmp/system failed $ret"
    fi
    
    ret=$(umount_backup_system)
else
    err_msg "backup system is not completely!"
fi

