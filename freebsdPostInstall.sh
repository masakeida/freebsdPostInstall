#!/bin/sh

usage() {
    cat <<EOF
Usage:
    $(basename ${0}) [<options>]
Options:
    --version, -v     print $(basename ${0}) version
    --user, -u        set new user
    --gecos, -n       set new user's name for GECOS field
    --passwd, -p      set new user's password
    --vmware, -w      configure for vmware
EOF
}

version() {
    cat <<EOF
$(basename ${0}): 20150124
EOF
}

# default vmware flag is no
VMWARE=NO

while [ $# -gt 0 ];
do
    case ${1} in

	--version|-v)
	    version
	    exit 0
	    ;;

        --user|-u)
            NUSER=${2}
            shift
            ;;

	--gecos|-n)
	    NNAME=${2}
	    shift
	    ;;

	--passwd|-p)
	    NPASSWD=${2}
	    shift
	    ;;

	--vmware|-w)
	    VMWARE=YES
	    ;;

	*)
	    echo "Invalid argment '${1}'"
	    usage
	    exit 1
	    ;;

    esac
    shift
done

# modify ports_list.txt for vmware
if [ ${VMWARE} = "YES" ]; then
    cat >> ports_list.txt <<EOF
#
x11-drivers/xf86-video-vmware
x11-drivers/xf86-input-vmmouse
emulators/open-vm-tools
EOF
fi

# adduser if define $NUSER
if [ -n "$NUSER" ]; then
    if [ -z "$NNAME" ]; then
	NNAME="FreeBSD User"
    fi
    if [ -z "$NPASSWD" ]; then
	NPASSWD="password"
    fi

    if [ ! -e /home ]; then
	mkdir /home
    fi

    echo ${NUSER}:1000:::::${NNAME}:/home/${NUSER}:/bin/csh:${NPASSWD} | adduser -f - -G wheel

    # copy files
    if [ ${VMWARE} = "YES" ]; then
	mv dot.xinitrc dot.xinitrc.ORG
	sed "s/^#//" dot.xinitrc.ORG > dot.xinitrc
	rm dot.xinitrc.ORG
    fi
    cp dot.xinitrc /home/${NUSER}/.xinitrc
    chown ${NUSER}:${NUSER} /home/${NUSER}/.xinitrc
    mkdir -p /home/${NUSER}/.config/fontconfig
    cp fonts.conf /home/${NUSER}/.config/fontconfig/
    chown -R ${NUSER}:${NUSER} /home/${NUSER}/.config
fi

# freebsd-update
freebsd-update fetch
freebsd-update install

# portsnap
portsnap fetch extract

# /etc/rc.conf update
cp /etc/rc.conf /etc/rc.conf.ORG
cat >> /etc/rc.conf <<EOF
# sendmail off
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
# other settings
snddetect_enable="YES"
mixer_enable="YES"
linux_enable="YES"
EOF

# /etc/fstab update
cp /etc/fstab /etc/fstab.ORG
cat >> /etc/fstab <<EOF
proc /proc procfs rw 0 0
linprocfs /compat/linux/proc linprocfs rw 0 0
EOF

# pkg
./pkgInstaller.sh ports_list.txt

# /etc/sysctl.conf update (for chromium)
cp /etc/sysctl.conf /etc/sysctl.conf.ORG
cat >> /etc/sysctl.conf <<EOF
kern.ipc.shm_allow_removed=1
EOF

# /etc/rc.conf.local
cat >> /etc/rc.conf.local <<EOF
dbus_enable="YES"
hald_enable="YES"
avahi_daemon_enable="YES"
avahi_dnsconfd_nable="YES"
#vmware_guest_vmblock_enable="YES"
#vmware_guest_vmhgfs_enable="YES"
#vmware_guest_vmmemctl_enable="YES"
#vmware_guest_vmxnet_enable="YES"
#vmware_guestd_enable="YES"
slim_enable="YES"
EOF

if [ ${VMWARE} = "YES" ]; then
    mv /etc/rc.conf.local /etc/rc.conf.local.ORG
    sed -e "s/^#//" /etc/rc.conf.local.ORG > /etc/rc.conf.local
    rm /etc/rc.conf.local.ORG
fi

# /etc/X11/xorg.conf.d/input.conf
mkdir /etc/X11/xorg.conf.d
cat >> /etc/X11/xorg.conf.d/input.conf <<EOF
Section "InputClass"
	Identifier		"Keyboard Defaults"
	Driver			"keyboard"
	MatchIsKeyboard		"on"
	Option			"XkbRules" "xorg"
	Option			"XkbModel" "jp106"
	Option			"XkbLayout" "jp"
	Option			"XkbOptions" "ctrl:nocaps"
EndSection

Section "InputClass"
	Identifier		"Mouse Defaults"
	Driver			"vmmouse"
	MatchIsPointer		"on"
EndSection
EOF

# /usr/local/etc/hal/fdi/policy/10-x11-kbd.fdi for keyboard settings
#cat >> /usr/local/etc/hal/fdi/policy/10-x11-kbd.fdi <<EOF
#<?xml version="1.0" encoding="ISO-8859-1"?>
#<deviceinfo version="0.2">
#  <device>
#    <match key="info.capabilities" contains="input.keyboard">
#      <match key="info.udi" string="/org/freedesktop/Hal/devices/atkbd_0">
#        <merge key="input.x11_options.XkbRules" type="string">xorg</merge>
#        <merge key="input.x11_options.XkbModel" type="string">jp106</merge>
#        <merge key="input.x11_options.XkbLayout" type="string">jp</merge>
#        <merge key="input.x11_options.XkbOptions" type="string">ctrl:nocaps</merge>
#      </match>
#    </match>
#  </device>
#</deviceinfo>
#EOF

# /usr/local/etc/PolicyKit/PolicyKit.conf for shutdown
if [ -n "$NUSER" ]; then
    cp /usr/local/etc/PolicyKit/PolicyKit.conf /usr/local/etc/PolicyKit/PolicyKit.conf.ORG
    sed -e "s/root/root|${NUSER}/" /usr/local/etc/PolicyKit/PolicyKit.conf.ORG > /usr/local/etc/PolicyKit/PolicyKit.conf
fi

# /usr/local/etc/fonts/local.conf for fontconfig settings
cat >> /usr/local/etc/fonts/local.conf <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<cachedir prefix="~">.fontconfig</cachedir>
</fontconfig>
EOF
