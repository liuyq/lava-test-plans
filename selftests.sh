#!/bin/bash

function call_submit_for_testing_py(){
    local device_type="$1"
    local test_case="$2"
    local f_variables_ini="$3"
    local dir_testplan_path="$4"
    local dir_testplan_device_path="$5"

    opt_testplan_path=""
    opt_testplan_device_path=""
    [ -n "${dir_testplan_path}" ] && opt_testplan_path="--testplan-path ${dir_testplan_path}"
    [ -n "${dir_testplan_device_path}" ] && opt_testplan_device_path="--testplan-device-path ${dir_testplan_device_path}"

    ./submit_for_testing.py \
                --device-type "${device_type}" \
                --test-case "${test_case}" \
                --variables "${f_variables_ini}" \
                ${opt_testplan_path} \
                ${opt_testplan_device_path} \
                --dry-run
    return $?
}

function test_for_templates(){
    local exit_code=0
    for F_DEVICE_TYPE in $(find ./devices/ -type f); do
        if echo "${F_DEVICE_TYPE}" | grep -q "./devices/android/"; then
            DEVICE_TYPE=$(echo "${F_DEVICE_TYPE}" | sed 's|./devices/android/||')
            if [ "X${DEVICE_TYPE}" = "Xdevice-base" ];then
                # device_base is the generic template files for all devices
                continue
            fi
            DIR_TESTCASES="./testcases/android"
            DIR_DEVICES="./devices/android"
            F_VARIABLES_INI="variables-android.ini"
        else
            DEVICE_TYPE=$(echo "${F_DEVICE_TYPE}" | sed 's|./devices/||')
            DIR_TESTCASES="./testcases"
            DIR_DEVICES="./devices"
            F_VARIABLES_INI="variables.ini"
        fi

        for F_PATH_TESTCASE in $(find "${DIR_TESTCASES}" -maxdepth 1 -type f -name '*.yaml'); do
            F_NAME_TESTCASE=$(basename "${F_PATH_TESTCASE}")
            call_submit_for_testing_py "${DEVICE_TYPE}" "${F_NAME_TESTCASE}" "${F_VARIABLES_INI}" "${DIR_TESTCASES}" "${DIR_DEVICES}"
            [ $? -gt $exit_code ] && exit_code=$?
        done
    done

    return $exit_code
}

test_for_templates
