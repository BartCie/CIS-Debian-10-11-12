# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    dismiss_count_for_test
    # shellcheck disable=2154
    run blank "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    local test_user="testetcgroupuser"
    local test_file="/etc/group"

    describe Tests purposely failing
    chmod 777 "$test_file"
    register_test retvalshouldbe 1
    register_test contain "permissions were not set to"
    run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    describe correcting situation
    sed -i 's/audit/enabled/' "${CIS_CONF_DIR}/conf.d/${script}.cfg"
    "${CIS_CHECKS_DIR}/${script}.sh" --apply || true

    describe Tests purposely failing
    useradd "$test_user"
    chown "$test_user":"$test_user" "$test_file"
    register_test retvalshouldbe 1
    register_test contain "ownership was not set to"
    run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    describe correcting situation
    sed -i 's/audit/enabled/' "${CIS_CONF_DIR}/conf.d/${script}.cfg"
    "${CIS_CHECKS_DIR}/${script}.sh" --apply || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "has correct permissions"
    register_test contain "has correct ownership"
    run resolved "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    # Cleanup
    userdel "$test_user"
}
