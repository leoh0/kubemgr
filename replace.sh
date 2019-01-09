#!/bin/bash

set -eo pipefail

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

after=$("$dir"/merge.sh)

before=$(kubectl config view --raw)

diff <(echo "$before") <(echo "$after") && echo "Same as current config. just quit.." && exit 0

echo

read -r -p "Change will be applied. Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    tmpfile=$(mktemp /tmp/kubeconfig.XXXXXX)
    echo "$after" > "$tmpfile"

    # make sure
    mkdir -p "${HOME}/.kube"
    targetfile="${HOME}/.kube/config"
    if [[ -r "$targetfile" ]] && [[ -f "$targetfile" ]]; then
        cp "$targetfile" "$targetfile".bak
        echo "Current config will back up to $targetfile.bak"
    fi

    cp "$tmpfile" "$targetfile"
    echo "Replace complete"

    rm "$tmpfile"
else
    echo "No change"
fi


