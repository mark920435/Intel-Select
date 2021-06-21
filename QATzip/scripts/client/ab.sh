#file="xml.bz2"
#file="book1.html"
file="1mb_file_1.html"

ab -s 240 -n 1000 -c 100 -Z AES128-SHA -f TLS1.2 -H 'Accept-Encoding: gzip,deflate'  https://172.16.1.1:4400/$file &
ab -s 240 -n 1000 -c 100 -Z AES128-SHA -f TLS1.2 -H 'Accept-Encoding: gzip,deflate'  https://172.16.2.1:4400/$file &
ab -s 240 -n 1000 -c 100 -Z AES128-SHA -f TLS1.2 -H 'Accept-Encoding: gzip,deflate'  https://172.16.3.1:4400/$file &
ab -s 240 -n 1000 -c 100 -Z AES128-SHA -f TLS1.2 -H 'Accept-Encoding: gzip,deflate'  https://172.16.4.1:4400/$file &

# AES128-GCM-SHA256
# AES128-SHA
