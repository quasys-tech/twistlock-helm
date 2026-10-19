#!/usr/bin/env bash
set -euo pipefail
# Run at the GitHub repository root after editing the chart.
helm lint charts/twistlock-console
mkdir -p docs
helm package charts/twistlock-console --destination docs
# Relative URLs allow GitHub Pages to serve the chart without knowing the username.
helm repo index docs
printf 'Chart packages and index are ready under docs/\n'
