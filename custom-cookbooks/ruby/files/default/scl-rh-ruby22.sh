# This file is managed by chef. Any changes will be lost

source /opt/rh/rh-ruby22/enable
export PATH=$PATH:/opt/rh/rh-ruby22/root/usr/local/bin
export X_SCLS="$(scl enable rh-ruby22 'echo $X_SCLS')"
