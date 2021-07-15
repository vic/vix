set -e
declare -x OUTER_PATH="$PATH"
declare -x outer="$out"
mkdir -p $outer

function mk_setenv() { 
  awk '/declare -x/{sub("declare -x", "setenv");sub(/=/, " ");print}'
}

cat <<EOF > $outer/input-derivation
#!$SHELL
source $shell_intput_derivation
if [ "\$phases" != "nobuildPhase" ]; then
  echo "Expected \$name to be an mkShell derivation" >&2
  exit 1
fi
declare -x nobuildPhase=true
declare -x IN_NIX_SHELL=impure
source \$stdenv/setup
export > $outer/shell-vars
EOF

env -i $SHELL --norc --noprofile -e -x "$outer/input-derivation"

(
cat <<'EOF'
# Variables that should never be set
if [ "$(type -t path_add)" = function ]; then
for vname in \
  HOME USER LOGNAME DISPLAY TERM \
  IN_NIX_SHELL NIX_BUILD_TOP NIX_BUILD_SHELL NIX_ENFORCE_PURITY \
  TZ PAGER SHELL SHLVL TMP TMPDIR TEMP TEMPDIR OLDPWD PWD SHELL
do
  eval "function ${vname}_add () { :; }"
done
fi


# Variables that are always commulative with values from previous shells
if [ "$(type -t path_add)" = function ]; then
for vname in \
PATH XDG_DATA_DIRS LD_LIBRARY_PATH LIBRARY_PATH \
PKG_CONFIG_PATH GOPATH NODE_PATH CLASSPATH
do
  eval "function ${vname}_add () { path_add $vname \"\${@}\" ; }"
done
fi

function setenv() {
  local name
  local value
  name="$1";
  value="$1";
  if [ "$(type -t "${name}_add")" = function ]; then
    "${name}_add" "$value"
  else
    declare -x "$name" "$value"
  fi
}

EOF
cat "$outer/shell-vars" | mk_setenv 
cat <<'EOF'

if [ -n "$shellHook" ]; then
  $shellHook
fi
EOF
) >  "$outer/env"


set +e