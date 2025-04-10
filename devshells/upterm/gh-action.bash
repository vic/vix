mkdir -p ~/.ssh ~/.upterm
echo "${ssh_config_text}" >> ~/.ssh/config
ssh-keygen -q -t rsa -N '' -C "$GITHUB_TRIGGERING_ACTOR@$GITHUB_REPOSITORY:$GITHUB_RUN_ID" -f ~/.ssh/id_rsa
ssh-keygen -q -t ed25519 -N '' -C "$GITHUB_TRIGGERING_ACTOR@$GITHUB_REPOSITORY:$GITHUB_RUN_ID" -f ~/.ssh/id_ed25519
ssh-add
ssh-keyscan uptermd.upterm.dev 2> /dev/null >> ~/.ssh/known_hosts
cat <(cat ~/.ssh/known_hosts | awk '{ print "@cert-authority * " $2 " " $3 }') >> ~/.ssh/known_hosts
tmux new -d -s upterm "upterm host --accept --github-user $GITHUB_REPOSITORY_OWNER |  tee ~/.upterm/out.log"
while ! grep 'SSH Session:' ~/.upterm/out.log; do sleep 1 ; done
echo Waiting
while ! grep 'Client joined' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
echo Joined
while ! grep 'Client left' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
echo Left