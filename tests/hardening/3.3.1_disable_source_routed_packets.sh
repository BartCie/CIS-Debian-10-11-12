# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    dismiss_count_for_test
    # shellcheck disable=2154
    run blank "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    if [ -f "/.dockerenv" ]; then
        skip "SKIPPED on docker"
    else
        describe Tests purposely failing
        sysctl -w net.ipv4.conf.all.accept_source_route=1 net.ipv4.conf.default.accept_source_route=1 net.ipv6.conf.all.accept_source_route=1 net.ipv6.conf.default.accept_source_route=1 2>/dev/null
        register_test retvalshouldbe 1
        register_test contain "net.ipv4.conf.all.accept_source_route was not set to 0"
        register_test contain "net.ipv4.conf.default.accept_source_route was not set to 0"
        register_test contain "net.ipv6.conf.all.accept_source_route was not set to 0"
        register_test contain "net.ipv6.conf.default.accept_source was not set to 0"

        run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

        describe correcting situation
        sed -i 's/audit/enabled/' "${CIS_CONF_DIR}/conf.d/${script}.cfg"
        "${CIS_CHECKS_DIR}/${script}.sh" --apply || true

        describe Checking resolved state
        register_test retvalshouldbe 0
        register_test contain "correctly set to 0"
        register_test contain "net.ipv4.conf.all.accept_source_route correctly set to 0"
        register_test contain "net.ipv4.conf.default.accept_source_route correctly set to 0"
        register_test contain "net.ipv6.conf.all.accept_source_route correctly set to 0"
        register_test contain "net.ipv6.conf.default.accept_source correctly set to 0"
        run resolved "${CIS_CHECKS_DIR}/${script}.sh" --audit-all
    fi
}
