# This file is managed by chef. Any changes will be lost

source /opt/rh/devtoolset-6/enable
export PATH=$PATH:/opt/rh/devtoolset-6/root/usr/bin
export X_SCLS="$(scl enable devtoolset-6 'echo $X_SCLS')"
