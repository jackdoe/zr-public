cat << EOF | zr-fetch -list -
public/man https://txt.black/~jack/zr-public/man.tar.gz
public/rfc https://txt.black/~jack/zr-public/rfc.tar.gz
EOF

zr -k public/man,public/rfc network protocol