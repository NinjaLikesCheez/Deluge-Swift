#!/usr/bin/env bash
set -eu

cd "$(dirname "$(realpath "$0")")/../"
xcrun swift-format lint --recursive --parallel --configuration .swift-format Package.swift Sources Tests "$@"
