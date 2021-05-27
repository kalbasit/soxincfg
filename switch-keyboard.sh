#!/bin/bash
usbkbd=`xinput -list | grep -c "USB Keyboard"`
if [[ "$usbkbd" -gt 0 ]]
then
    usbkbd_ids=`xinput -list | grep "USB Keyboard" | awk -F'=' '{print $2}' | cut -c 1-2`
    usbkbd_layout="tr(f)"
    for ID in $usbkbd_ids
    do
      setxkbmap -device "${ID}" -layout "${usbkbd_layout}"
    done
fi
exit 0

https://github.com/zsa/wally/tree/master/dist/linux64
