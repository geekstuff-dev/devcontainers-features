#!/bin/sh

curl -s https://fluxcd.io/install.sh | bash
flux completion bash > /etc/bash_completion.d/fluxcd
