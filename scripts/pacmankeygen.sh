#!/usr/bin/env bash

pacman-key --init &
sleep 1s
pkPID="$(pgrep pacman-key)"

if [ -n "$pkPID" ] ; then
  if [ -n "$(command -v haveged)" ] ; then
    haveged 
    wait $pkPID
    killall haveged
  else
    while [ -n "$(ps aux | grep [p]acman-key)" ] ; do mandb &> /dev/null ; done
  fi

  gpg --no-tty --homedir /etc/pacman.d/gnupg/ --no-permission-warning \
    --import /usr/share/pacman/keyrings/archlinux.gpg &> /dev/null

  for keyid in $(cat /usr/share/pacman/keyrings/archlinux-trusted | sed 's/:.*//') ; do 
    pacman-key --lsign-key $keyid
  done

  gpg --no-tty --homedir /etc/pacman.d/gnupg/ --no-permission-warning \
    --import-ownertrust /usr/share/pacman/keyrings/archlinux-trusted &> /dev/null
fi

