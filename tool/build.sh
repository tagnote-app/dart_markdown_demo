#!/bin/sh

dart tool/compile_scss.dart
rm -rf docs/*
cp -r web/highlight docs/
cp -r web/images docs/
cp  web/styles.css docs/
cp  web/index.html docs/
dart compile js -O2 -o docs/main.dart.js web/main.dart --no-source-maps