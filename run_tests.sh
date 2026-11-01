#!/usr/bin/env bash
set -e
(cd packages/looseleaf_ink && flutter test)
(cd packages/looseleaf_ui && flutter test)
(cd modules/gallery && flutter test)
