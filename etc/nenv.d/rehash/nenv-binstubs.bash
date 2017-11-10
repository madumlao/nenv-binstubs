#!/usr/bin/env bash

no_rehash_binaries() {
  # filesystem hierarchy standard 2.3 bin paths
  FHS_BIN="cat chgrp chmod chown cp date dd df dmesg echo false hostname kill ln login ls mkdir mknod more mount mv ps pwd rm rmdir sed sh stty su sync true umount uname \\[ test csh ed tar cpio gzip zcat netstat ping ftp tftp setserial"
  FHS_SBIN="shutdown fastboot fasthalt fdisk fsck fsck\\..* getty halt ifconfig init mkfs mkfs\\..* mkswap reboot route swapon swapoff update mh"
  FHS_USRBIN="X11 perl python tclsh wish expect"

  # linux standard base 5.0 bin paths
  LSB_BIN="\\[ du install mv strings ar echo install_initd newgrp strip at ed ipcrm nice stty awk egrep ipcs nl su basename env join nohup sync batch expand kill od tail bc expr killall passwd tar cat false ln paste tee chfn fgrep locale patch test chgrp file localedef pathchk tic chmod find logger pax time chown fold logname pidof touch chsh fuser lp pr tput cksum gencat lpr printf tr cmp getconf ls ps true col gettext lsb_release pwd tsort comm grep m4 remove_initd tty cp groupadd mailx renice umount cpio groupdel make rm uname crontab groupmod man rmdir unexpand csplit groups md5sum sed uniq cut gunzip mkdir sendmail useradd date gzip mkfifo seq userdel dd head mknod sh usermod df hostname mktemp shutdown wc diff iconv more sleep xargs dirname id mount sort zcat dmesg infocmp msgfmt split"

  # gnu coreutils
  COREUTILS_BIN="mknod date rmdir df mkdir stty ls mv echo ln cp chgrp rm uname chmod sleep vdir chown dd sync false mktemp readlink dir true touch pwd cat bin shuf hostid stdbuf md5sum basename dircolors unlink stat tty uniq unexpand nice tail join tee pathchk tr printenv nohup sha1sum tsort nl factor tac test seq chcon yes printf id base64 link \\[ logname sha384sum od pinky truncate sha224sum mkfifo cksum users nproc sum ptx cut shred sha256sum du whoami fmt runcon groups numfmt realpath env comm fold csplit arch expand timeout sort wc split pr dirname paste install expr sha512sum base32 who head md5sum.textutils"
  COREUTILS_SBIN="chroot"

  # debian utils
  DEBIANUTILS="run-parts which tempfile installkernel savelog ischroot remove-shell add-shell"

  echo $FHS_BIN $FHS_SBIN $FHS_USRBIN $LSB_BIN $COREUTILS_BIN $COREUTILS_SBIN $DEBIANUTILS
}

register_binstubs()
{
  local root
  local modules_binpath
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi
  modules_binpath='node_modules/.bin'
  while [ -n "$root" ]; do
    if [ -f "$root/package.json" ]; then
      for shim in $root/$modules_binpath/*; do
        if [ -x "$shim" ]; then
          if ! echo "${shim##*/}" | egrep -qw "$(no_rehash_binaries | tr ' ' '|')"; then
            # the shim does not overwrite one of the "standard" system binaries
            register_shim "${shim##*/}"
	  fi
        fi
      done
      IFS="$OLD_IFS"
      break
    fi
    root="${root%/*}"
  done
}

register_bundles ()
{
  # go through the list of bundles and run make_shims
  if [ -f "${NENV_ROOT}/bundles" ]; then
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${NENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      register_binstubs "$bundle"
    done
  fi
}

add_to_bundles ()
{
  local root
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi

  # update the list of bundles to remove any stale ones
  local new_bundle
  new_bundle=true
  new_bundles=${NENV_ROOT}/bundles.new.$$
  : > $new_bundles
  if [ -s ${NENV_ROOT}/bundles ]; then
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${NENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      if [ "X$bundle" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle/package.json" ]; then
        echo "$bundle" >> $new_bundles
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    if [ -f "$root/package.json" ]; then
      echo "$root" >> $new_bundles
    fi
  fi
  mv -f $new_bundles ${NENV_ROOT}/bundles
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  add_to_bundles
  register_bundles
fi

