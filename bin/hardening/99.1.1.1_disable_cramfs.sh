#!/bin/bash

# run-shellcheck
#
# CIS Debian Hardening Bonus Check
#

#
# 99.1.1.1 Ensure mounting of cramfs filesystems is disabled (Not Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Disable mounting of cramfs filesystems."

KERNEL_OPTION="CONFIG_CRAMFS"
MODULE_NAME="cramfs"

# This function will be called if the script status is on enabled / audit mode
audit() {
    is_kernel_option_enabled "$KERNEL_OPTION" "$MODULE_NAME"
    if [ "$FNRET" = 0 ]; then # 0 means true in bash, so it IS activated
        crit "$KERNEL_OPTION is enabled!"
    else
        ok "$KERNEL_OPTION is disabled"
    fi
    :
}

# This function will be called if the script status is on enabled mode
apply() {
    is_kernel_option_enabled "$KERNEL_OPTION"
    if [ "$FNRET" = 0 ]; then # 0 means true in bash, so it IS activated
        warn "I cannot fix $KERNEL_OPTION enabled, recompile your kernel please"
    else
        ok "$KERNEL_OPTION is disabled, nothing to do"
    fi
    :
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    # shellcheck source=../../debian/default
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_LIB_DIR" ]; then
    echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
    echo "Cannot source CIS_LIB_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r "${CIS_LIB_DIR}"/main.sh ]; then
    # shellcheck source=../../lib/main.sh
    . "${CIS_LIB_DIR}"/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_LIB_DIR in /etc/default/cis-hardening"
    exit 128
fi
