echo "[Install Go]"
cd /root/
wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
/usr/local/go/bin/go get -u github.com/tsenart/vegeta
/root/go/bin/vegeta -h
