#!/bin/bash

SCRIPT="./manage.py"
STD_CREDENTIALS="/docker/secrets/creds_std"
MS_CREDENTIALS="/docker/secrets/creds_ms"
KT_CREDENTIALS="/docker/secrets/creds_kt"

. "$STD_CREDENTIALS"
. "$MS_CREDENTIALS"
. "$KT_CREDENTIALS"

"$SCRIPT" flush --no-input
"$SCRIPT" generate-packages
"$SCRIPT" generate-analysis-material
"$SCRIPT" generate-static-users
"$SCRIPT" generate-variants
