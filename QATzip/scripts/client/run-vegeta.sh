/root/go/bin/vegeta attack -insecure -duration=60s -rate=0 -max-workers=10000 -targets targets.txt | tee results.bin | /root/go/bin/vegeta report
# /root/go/bin/vegeta attack -insecure -duration=60s -rate=100 -targets targets.txt | tee results.bin | /root/go/bin/vegeta report
