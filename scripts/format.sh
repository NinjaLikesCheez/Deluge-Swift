#!/usr/bin/env bash
set -eu

cd "$(dirname "$(realpath "$0")")/../"
swift-format format --in-place --recursive --parallel --configuration .swift-format Package.swift Sources Tests "$@"
