# This file is managed by chef. Any changes will be lost

source /opt/rh/rh-ruby23/enable
export PATH=$PATH:/opt/rh/rh-ruby23/root/usr/local/bin
export X_SCLS="$(scl enable rh-ruby23 'echo $X_SCLS')"
