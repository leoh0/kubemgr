#!/bin/bash

set -eo pipefail

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=/dev/null
source "$dir/.function"

merge_kubeconfig
