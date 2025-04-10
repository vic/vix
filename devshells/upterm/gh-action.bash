mkdir -p ~/.ssh ~/.upterm
touch ~/.upterm/out.log ~/.upterm/upterm.log
ssh-keygen -q -t rsa -N '' -C "$GITHUB_TRIGGERING_ACTOR@$GITHUB_REPOSITORY:$GITHUB_RUN_ID" -f ~/.ssh/id_rsa
ssh-keygen -q -t ed25519 -N '' -C "$GITHUB_TRIGGERING_ACTOR@$GITHUB_REPOSITORY:$GITHUB_RUN_ID" -f ~/.ssh/id_ed25519
ssh-add
echo Adding uptermd.upterm.dev to known_hosts
ssh-keyscan uptermd.upterm.dev 2> /dev/null >> ~/.ssh/known_hosts2
cat ~/.ssh/known_hosts2 >> ~/.ssh/known_hosts
awk -f '{ print "@cert-authority * " $2 " " $3 }' -- ~/.ssh/known_hosts2 >> ~/.ssh/known_hosts
cat ~/.ssh/known_hosts
echo Starting in background
set -x -e
upterm host --accept --github-user $GITHUB_REPOSITORY_OWNER  2>&1 | tee -a ~/.upterm/out.log
#screen -T xterm -dmS upterm bash -c "upterm host --accept --github-user vic 2>&1 | tee -a ~/.upterm/out.log"
sleep 1
echo Waiting for upterm to start
tail -f ~/.upterm/out.log | head -n 11
while ! grep 'SSH Session:' ~/.upterm/out.log; do sleep 1 ; done
echo Waiting for join
while ! grep 'Client joined' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
echo Joined
while ! grep 'Client left' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
echo Left