SCRIPTS=/root/scripts
TREX_CFG=$SCRIPTS/trex/trex_cfg.yaml
PACKET_JASON=$SCRIPTS/trex/in_256.json
RFC2544_DIR=$SCRIPTS/trex/rfc2544
RFC2544_TEST_PYTHON=$SCRIPTS/trex/test.py
PROXY=$SCRIPTS/set-proxy.sh
TREX_PATH=/opt/trex/v2.80

source $PROXY
cp ${TREX_CFG} /etc/.

yum install -y tmux
yum install -y dos2unix
yum install -y pciutils

tmux kill-session -t trex
tmux new -s trex -d
tmux send-keys -t trex 'cd /opt/trex/v2.80 && ./t-rex-64 -i' Enter


#cp -r ${RFC2544_DIR} ${TREX_PATH}/
#cp ${PACKET_JASON} ${TREX_PATH}/rfc2544/
#cp ${RFC2544_TEST_PYTHON} ${TREX_PATH}/rfc2544/

#sleep 20

#tmux kill-session -t rfc2544
#tmux new -s rfc2544 -d
#tmux send-keys -t rfc2544 'export TREX_PATH=/opt/trex/v2.80 && \
#                           export PYTHONPATH=${TREX_PATH}/automation/trex_control_plane/interactive && \
#                           cd ./trex/rfc2544
#                           dos2unix ./test.py && \
#                           ./test.py --type in --packet 256 --bitrate 10000000000 --output rfc2544.log' Enter

tmux ls
echo "Use 'tmux a -t trex' to login to trex session"
echo "Use 'tmux a -t rfc2544' to login to rfc2544 session"
echo "Use 'Ctrl+b then d' to detach the session"
