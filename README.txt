mkdir -p ~/.zr-data \
  && curl -sL https://txt.black/~jack/zr-public/public.tar.bz2 \
       | tar -C ~/.zr-data/ -xvjf -
       

zr -k public/man,public/rfc network protocol