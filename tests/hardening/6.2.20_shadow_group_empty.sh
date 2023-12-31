# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    dismiss_count_for_test
    # shellcheck disable=2154
    run blank "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    local test_user="testshadowuser"

    describe Tests purposely failing
    useradd "$test_user"
    usermod -aG shadow "$test_user"
    register_test retvalshouldbe 1
    register_test contain "Some users belong to shadow group"
    run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all
    userdel "$test_user"

    describe Tests purposely failing
    useradd --no-user-group -g shadow "$test_user"
    register_test retvalshouldbe 1
    register_test contain "Some users have shadow id as their primary group"
    run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all
    userdel "$test_user"

}
