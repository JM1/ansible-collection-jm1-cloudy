#!/bin/bash
# vim:set tabstop=8 shiftwidth=4 expandtab:
# kate: space-indent on; indent-width 4;
#
# Copyright (c) 2023 Jakob Meng, <jakobmeng@web.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

set -euo pipefail

# Environment variables
DEBUG=${DEBUG:=no}

if [ "$DEBUG" = "yes" ] || [ "$DEBUG" = "true" ]; then
    set -x
fi

error() {
    echo "ERROR: $*" 1>&2
}

warn() {
    echo "WARNING: $*" 1>&2
}

help() {
    cmd=$(basename "$0")
    cat << ____EOF
Usage: $cmd [OPTIONS] [COMMAND]
       $cmd [ --help ]

Test Podman containers, Ansible inventory and playbooks.

OPTIONS:
    -h, --help            Print usage
    --project DIR         Directory where Ansible playbooks and the inventory are stored.
                          Defaults to the directory that contains this script.
    --project-name NAME   Name to label and find containers, images and volumes with.
                          Defaults to '$project_name_default'.

COMMANDS:
    podman_compose   Test Podman containers
    ansible_hosts    Test Ansible inventory and playbooks
    help             Print usage

Run '$cmd COMMAND --help' for more information on each command.
____EOF
}

podman_compose() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd podman_compose [OPTIONS]

Test Podman containers.

OPTIONS:
    --distributions DISTRIS   Comma-separated list of Linux distribution used in containers.
                              Defaults to '$distributions_default'.
    --project-name NAME       Name to label and find containers, images and volumes with.
                              Defaults to '$project_name_default'.
    -h, --help                Print usage.
________EOF
    }

    distributions=""
    distributions_default="centos_8,centos_9,debian_10,debian_11,debian_12,ubuntu_1804,ubuntu_2004,ubuntu_2204"
    project_name=""
    project_name_default="cloudy-test"

    while [ $# -ne 0 ]; do
        case "$1" in
            "--distributions")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --distributions"
                    return 255
                fi

                distributions="$2"
                shift
                ;;
            "-h"|"--help")
                help
                return 0
                ;;
            "--project-name")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --project-name"
                    return 255
                fi

                project_name="$2"
                shift
                ;;
            -*)
                error "Unknown flag: $1"
                return 255
                ;;
            *)
                error "Unknown command: $1"
                return 255
                ;;
        esac
        # shellcheck disable=SC2317
        shift
    done

    [ -n "$distributions" ] || distributions=$distributions_default
    [ -n "$project_name" ] || project_name=$project_name_default

    # Locate script directory
    # NOTE: Symbolic links are followed first in order to always resolve to
    #       the script's directory even if called through a symbolic link.
    cmd_dir=$(dirname "$(readlink -f "$0")")

    # Locate project directory
    project_dir=$(readlink -f "$cmd_dir")

    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root"
        exit 125
    fi

    cd "$project_dir/containers"

    for distribution in $(echo "$distributions" | tr ',' ' '); do
        echo "Running Podman container tests with distribution $distribution"

        echo "Cleaning test environment for Podman containers"
        ./podman-compose.sh down --project-name "$project_name" || return

        echo "Launching Podman containers"
        ./podman-compose.sh up --project-name "$project_name" --distribution "$distribution" --detach true || return

        echo "Waiting for Podman containers"
        for _ in $(seq 5); do # Retry
            if [ -z "$(podman container ls -a -q "--filter=name=^${project_name}\$" --filter=status=running)" ]; then
                if [ "$(podman inspect "${project_name}" --format='{{ .State.ExitCode }}')" = "0" ]; then
                    break
                else
                    warn "Crashed container ${project_name} will be (re)started."
                    podman start "${project_name}"
                fi
            fi

            while [ -n "$(podman container ls -a -q "--filter=name=^${project_name}\$" --filter=status=running)" ]; do
                echo "Waiting until Podman container ${project_name} has stopped"
                sleep 60
            done
        done

        if [ "$(podman inspect "${project_name}" --format='{{ .State.ExitCode }}')" != "0" ]; then
            error "Podman container ${project_name} failed:"
            podman logs "${project_name}" 2>&1 | tail | sed 's/^/  /g' >&2
            return 1
        fi

        echo "Stopping Podman containers"
        ./podman-compose.sh stop --project-name "$project_name" || return

        echo "Removing Podman containers"
        ./podman-compose.sh down --project-name "$project_name" || return

        echo "Finished Podman container tests with distribution $distribution"
    done
}

ansible_hosts() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd ansible_hosts [OPTIONS]

Test Ansible inventory and playbooks.

OPTIONS:
    --containerless       Run tests natively, without a container
    --hosts HOSTS         Run tests for a comma-separated list of hosts only
    --keep-containers     Do not purge Podman containers before and after tests
    --keep-domains        Do not purge libvirt domains before and after tests
    --playbook PLAY       Playbook which will be run to test the hosts.
                          Defaults to '$playbook_default'.
    --project DIR         Directory where Ansible playbooks and the inventory are stored.
                          Defaults to the directory that contains this script.
    --project-name NAME   Name to label and find containers, images and volumes with.
                          Defaults to '$project_name_default'.
    --test-sets SETS      Run tests for a comma-separated list of test sets only
    --skip-hosts HOSTS    Skip tests for a comma-separated list of hosts
    -h, --help            Print usage
________EOF
    }

    containerless="no"
    hosts=""
    keep_containers="no"
    keep_domains="no"
    playbook=""
    playbook_default="playbooks/site.yml"
    project=""
    project_name=""
    project_name_default="cloudy-test"
    test_sets=""
    skip_hosts=""

    while [ $# -ne 0 ]; do
        case "$1" in
            "--containerless")
                containerless="yes"
                ;;
            "--hosts")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --hosts"
                    return 255
                fi

                hosts="$2"
                shift
                ;;
            "-h"|"--help")
                help
                return 0
                ;;
            "--keep-containers")
                keep_containers="yes"
                ;;
            "--keep-domains")
                keep_domains="yes"
                ;;
            "--playbook")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --playbook"
                    return 255
                fi

                playbook="$2"
                shift
                ;;
            "--project")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --project"
                    return 255
                fi

                project="$2"
                shift
                ;;
            "--project-name")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --project-name"
                    return 255
                fi

                project_name="$2"
                shift
                ;;
            "--test-sets")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --test-sets"
                    return 255
                fi

                test_sets="$2"
                shift
                ;;
            "--skip-hosts")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --skip-hosts"
                    return 255
                fi

                skip_hosts="$2"
                shift
                ;;
            -*)
                error "Unknown flag: $1"
                return 255
                ;;
            *)
                error "Unknown command: $1"
                return 255
                ;;
        esac
        # shellcheck disable=SC2317
        shift
    done

    [ -n "$playbook" ] || playbook=$playbook_default
    [ -n "$project_name" ] || project_name=$project_name_default

    # Locate script directory
    # NOTE: Symbolic links are followed first in order to always resolve to
    #       the script's directory even if called through a symbolic link.
    cmd_dir=$(dirname "$(readlink -f "$0")")

    # Locate project directory
    if [ -n "$project" ]; then
        project_dir=$(readlink -f "$project")
    else
        project_dir=$(readlink -f "$cmd_dir")
    fi

    if [ "$containerless" != "yes" ]; then
        if [ "$(id -u)" -ne 0 ]; then
            error "Please run as root"
            exit 125
        fi

        cmd_path_in_project=$(realpath "--relative-to=$project_dir" "$(readlink -f "$0")")
        case "$cmd_path_in_project" in
            "../"*)
                # This script must be located below the project dir
                # in order to be accessible from the container.
                error "$0 is not located in '$project_dir' or one of its subdirectories"
                return 1
                ;;
        esac

        if [ ! -e "$playbook" ]; then
            error "Playbook $playbook not found"
            return 1
        fi

        playbook_path_in_project=$(realpath "--relative-to=$project_dir" "$(readlink -f "$playbook")")
        case "$playbook_path_in_project" in
            "../"*)
                # The playbook must be located below the project dir
                # in order to be accessible from the container.
                error "$playbook is not located in '$project_dir' or one of its subdirectories"
                return 1
                ;;
        esac

        if [ "$keep_containers" != "yes" ]; then
            echo "Cleaning test environment for Podman containers"
            "$cmd_dir/containers/podman-compose.sh" down --project-name "$project_name" || return
        fi

        echo "Launching Podman containers"
        "$cmd_dir/containers/podman-compose.sh" up --project "$project_dir" --project-name "$project_name" --detach \
            sh -c "touch '/tmp/${project_name}.done' && sleep infinity"

        initialized="no"
        for _ in $(seq 5); do # Retry
            if [ -z "$(podman container ls -a -q "--filter=name=^${project_name}\$" --filter=status=running)" ]
            then
                warn "Stopped container ${project_name} will be (re)started."
                podman start "${project_name}"

                echo "Waiting until Podman containers reinitialized.."
                sleep 60
            fi

            while true; do
                # Ensure container is still running
                podman exec "${project_name}" true || break

                if podman exec "${project_name}" test -e "/tmp/${project_name}.done"; then
                    initialized="yes"
                    break
                fi

                echo "Waiting until Podman containers initialized.."
                sleep 60
            done
        done

        if [ "$initialized" != "yes" ]; then
            error "Podman container ${project_name} failed to initialize:"
            podman logs "${project_name}" 2>&1 | tail | sed 's/^/  /g' >&2
            return 1
        fi

        echo "Podman containers initialized"

        echo "Launching tests for Ansible hosts in Podman container"
        ansible_hosts_args=()
        if [ "$keep_domains" = "yes" ]; then
            ansible_hosts_args+=(--keep-domains)
        fi

        if [ -n "$hosts" ]; then
            ansible_hosts_args+=(--hosts "$hosts")
        fi

        if [ -n "$test_sets" ]; then
            ansible_hosts_args+=(--test-sets "$test_sets")
        fi

        if [ -n "$skip_hosts" ]; then
            ansible_hosts_args+=(--skip-hosts "$skip_hosts")
        fi

        podman exec -ti --user cloudy --workdir "/home/cloudy/project" "${project_name}" \
            "./$cmd_path_in_project" ansible_hosts \
                --containerless \
                --playbook "$playbook_path_in_project" \
                --project "/home/cloudy/project" \
                --project-name "${project_name}" \
                "${ansible_hosts_args[@]}"

        if [ "$keep_containers" != "yes" ]; then
            echo "Removing Podman containers"
            "$cmd_dir/containers/podman-compose.sh" down --project-name "$project_name" || return
        fi
    else # [ "$containerless" = "yes" ]
        cd "$project_dir"

        echo "Discovering Ansible hosts"
        inventory=$(ansible-inventory --list | jq --compact-output 'del(.["_meta"])')

        all_hosts=$(echo "$inventory" | jq --raw-output '[ .[] | .hosts // [] | .[] ] | sort | unique')
        if [ -z "$all_hosts" ]; then
            error "No hosts found"
            return 1
        fi

        ungrouped_hosts=$(echo "$inventory" | jq --raw-output '.ungrouped.hosts // [] | .[]')
        if [ -n "$ungrouped_hosts" ]; then
            error "Found ungrouped hosts: $(echo "$ungrouped_hosts" | tr '\n' ' ')"
            return 1
        fi

        all_test_sets=$(echo "$inventory" | jq --raw-output '.test_sets.children // [] | .[]')
        if [ -z "$all_test_sets" ]; then
            error "No test sets found"
            return 1
        fi

        if [ -n "$test_sets" ]; then
            test_sets="$(echo "$test_sets" | tr ',' '\n')"

            invalid_test_sets=$(comm -2 -3 \
                                    <(echo "$test_sets" | sort) \
                                    <(echo "$all_test_sets" | sort))

            if [ -n "$invalid_test_sets" ]; then
                error "Invalid test sets found: $(echo "$test_sets" | tr '\n' ' ')"
                return 1
            fi
        else
            test_sets="$all_test_sets"
        fi

        build_levels=$(echo "$inventory" | jq --raw-output '.build_dependencies.children // [] | .[]')
        if [ -z "$build_levels" ]; then
            warn "No build levels for hosts found"
        fi

        hosts_done=()
        for test_set in $test_sets; do
            echo "Identifying hosts in test set $test_set"
            hosts_in_test_set=$(echo "$inventory" \
                                | jq --raw-output --arg test_set "$test_set" '.[$test_set].hosts // [] | .[]')
            if [ -z "$hosts_in_test_set" ]; then
                continue
            fi

            if [ -z "$hosts" ]; then
                hosts_todo_in_test_set="$hosts_in_test_set"
            else
                hosts_todo_in_test_set=$(comm -1 -2 \
                                            <(echo "$hosts_in_test_set" | sort) \
                                            <(echo "$hosts" | tr ',' '\n' | sort))
            fi

            if [ -z "$hosts_todo_in_test_set" ]; then
                echo "Found no matching hosts for test set $test_set"
                continue
            fi

            if [ -n "$skip_hosts" ]; then
                hosts_todo_in_test_set=$(comm -1 -2 \
                                            <(echo "$hosts_todo_in_test_set" | sort) \
                                            <(echo "$skip_hosts" | tr ',' '\n' | sort))
            fi

            if [ -z "$hosts_todo_in_test_set" ]; then
                echo "Found no matching hosts for test set $test_set after skipping hosts"
                continue
            fi

            echo "Found the following hosts for test set $test_set:"
            # shellcheck disable=SC2001
            echo "$hosts_todo_in_test_set" | sed 's/^/  /g'

            if [ "$keep_domains" != "yes" ]; then
                echo "Purging all libvirt domains before running test set $test_set"
                for domain in $(virsh list --name); do
                    echo "Purging libvirt domain $domain"
                    virsh destroy "$domain" || true
                    virsh undefine --remove-all-storage --nvram "$domain" || true
                done
            fi

            for build_level in $build_levels; do
                echo "Identifying hosts in build level $build_level during test set $test_set"
                hosts_in_build_level=$(echo "$inventory" \
                                       | jq --raw-output --arg build_level "$build_level" \
                                            '.[$build_level].hosts // [] | .[]')

                if [ -z "$hosts_in_build_level" ]; then
                    continue
                fi

                hosts_todo_in_build_level=$(comm -1 -2 \
                                                <(echo "$hosts_todo_in_test_set" | sort) \
                                                <(echo "$hosts_in_build_level" | sort))
                if [ -z "$hosts_todo_in_build_level" ]; then
                    echo "Found no matching hosts in build level $build_level for test set $test_set"
                    continue
                fi

                echo "Found the following hosts in build level $build_level for test set $test_set:"
                # shellcheck disable=SC2001
                echo "$hosts_todo_in_build_level" | sed 's/^/  /g'

                echo "Running playbook $playbook for hosts of build level $build_level in test set $test_set"
                passed="no"
                for retry in $(seq 5); do
                    if ansible-playbook "$playbook" --limit "$(echo "$hosts_todo_in_build_level" | tr '\n' ',')"
                    then
                        passed="yes"
                        break
                    fi
                    warn "Ansible playbook $playbook failed $retry times."
                done
                if [ "$passed" != "yes" ]; then
                    return 1
                fi

                echo "Playbook $playbook for hosts of build level $build_level in test set $test_set finished"
                for host in $hosts_todo_in_build_level; do
                    hosts_done+=("$host")
                done
            done

            if [ "$keep_domains" != "yes" ]; then
                echo "Purging all libvirt domains after running test set $test_set"
                for domain in $(virsh list --name); do
                    echo "Purging libvirt domain $domain"
                    virsh destroy "$domain" || true
                    virsh undefine --remove-all-storage --nvram --tpm "$domain" \
                        || virsh undefine --remove-all-storage --nvram "$domain" || true
                done
            fi

            echo "Finished test set $test_set"
        done

        if [ -n "$hosts" ]; then
            hosts_todo=$(echo "$hosts" | tr ',' '\n')
        else
            hosts_todo="$all_hosts"
        fi

        if [ -n "$skip_hosts" ]; then
            hosts_todo=$(comm -1 -2 \
                            <(echo "$hosts_todo" | sort) \
                            <(echo "$skip_hosts" | tr ',' '\n' | sort))
        fi

        hosts_missed=$(comm -2 -3 \
                        <(echo "$hosts_todo" | sort) \
                        <(printf "%s\n" "${hosts_done[@]}" | sort))
        if [ -n "$hosts_missed" ]; then
            warn "The following hosts have not been tested: $(echo "$hosts_missed" | tr '\n' ' ')"
        fi
    fi
}

project=""
project_name=""
project_name_default="cloudy-test"

while [ $# -ne 0 ]; do
    case "$1" in
        "podman_compose"|"ansible_hosts"|"help")
            ("$@")
            exit
            ;;
        "-h"|"--help")
            help
            exit 0
            ;;
        "--project")
            if [ -z "$2" ]; then
                error "flag is missing arg: --project"
                return 255
            fi

            project="$2"
            shift
            ;;
        "--project-name")
            if [ -z "$2" ]; then
                error "flag is missing arg: --project-name"
                return 255
            fi

            project_name="$2"
            shift
            ;;
        -*)
            error "Unknown flag: $1"
            exit 1
            ;;
        *)
            error "Unknown command: $1"
            exit 1
            ;;
    esac
    # shellcheck disable=SC2317
    shift
done

[ $# -eq 0 ] # assert

[ -n "$project_name" ] || project_name=$project_name_default

podman_compose_args=(--project-name "$project_name")
podman_compose "${podman_compose_args[@]}"

ansible_hosts_args=(--project-name "$project_name")
if [ -n "$project" ]; then
    ansible_hosts_args+=(--project "$project")
fi
ansible_hosts "${ansible_hosts_args[@]}"
