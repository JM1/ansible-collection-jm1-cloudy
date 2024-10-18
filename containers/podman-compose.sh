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
Usage: $cmd [OPTIONS] COMMAND
       $cmd [ --help ]

Start, stop or remove Podman networks, volumes and containers.

OPTIONS:
    -h, --help      Print usage

COMMANDS:
    up        Create and start networks, volumes and containers.
    stop      Stop containers.
    down      Stop and remove containers, volumes and networks.
    help      Print usage

Run '$cmd COMMAND --help' for more information on each command.
____EOF
}

up() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd up [OPTIONS] [COMMAND] [ARGS...]

Create and start networks, volumes, containers and run COMMAND ARGS in the primary container. If COMMAND is not
specified, then a shell is run.

OPTIONS:
    -d, --detach                  Detached mode.
    --distribution DISTRIBUTION   Linux distribution used in containers. Options are centos_8, centos_9, debian_10,
                                  debian_11, debian_12, debian_13, fedora_rawhide, ubuntu_1804, ubuntu_2004, ubuntu_2204
                                  and ubuntu_2404.
    --project DIR                 Directory where Ansible playbooks and the inventory are stored.
                                  Defaults to the parent directory of the directory that contains this script.
    --project-name NAME           Name to label and find containers, images and volumes with.
                                  Defaults to '$project_name_default'.
    -h, --help                    Print usage.
________EOF
    }

    cmd_args=()
    detach="no"
    distribution=""
    distribution_default="debian_11"
    project=""
    project_name=""
    project_name_default="cloudy"

    while [ $# -ne 0 ]; do
        case "$1" in
            "-d"|"--detach")
                detach="yes"
                ;;
            "--distribution")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --distribution"
                    return 255
                fi

                distribution="$2"
                shift
                ;;
            "-h"|"--help")
                help
                return 0
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
                return 255
                ;;
            *)
                cmd_args=("$@")
                set -- 'FOR_NEXT_SHIFT_ONLY'
                ;;
        esac
        shift
    done

    [ -n "$distribution" ] || distribution=$distribution_default
    [ -n "$project_name" ] || project_name=$project_name_default

    case "$distribution" in
        "centos_8"|"centos_9")
            ;;
        "debian_10"|"debian_11"|"debian_12"|"debian_13")
            ;;
        "fedora_rawhide")
            ;;
        "ubuntu_1804"|"ubuntu_2004"|"ubuntu_2204"|"ubuntu_2404")
            ;;
        *)
            error "Unsupported distribution: $distribution"
            return 255
            ;;
    esac

    # Locate script directory
    # NOTE: Symbolic links are followed first in order to always resolve to
    #       the script's directory even if called through a symbolic link.
    cmd_dir=$(dirname "$(readlink -f "$0")")

    # Locate project directory
    if [ -n "$project" ]; then
        project_dir=$(readlink -f "$project")
    else
        project_dir=$(readlink -f "$cmd_dir/..")
    fi

    for volume in "${project_name}-images" "${project_name}-ssh"; do
        # Podman 3.0.1 does not support podman volume exists and does not support regular expressions in filters
        if ! podman volume ls -q "--filter=name=$volume" | grep -q -e "^$volume\$"; then
            podman volume create "$volume"
        fi
    done

    if podman container exists "${project_name}"; then
        # Container exists
        if [ -z "$(podman container ls -a -q "--filter=name=^${project_name}\$" --filter=status=running)" ]
        then
            warn "Stopped container ${project_name} will be (re)started, but not rebuild."\
                 "Remove container first to force rebuild."
            podman start "${project_name}"

            if [ "$detach" != "yes" ]; then
                podman attach "${project_name}"
            fi
        fi
    else # Container does not exist
        if ! podman image exists "${project_name}:latest"; then
            (cd "$cmd_dir" && podman image build -f "Dockerfile.$distribution" -t "${project_name}:latest" .)
        fi

        podman_args=()

        # Disable SELinux separation for the container
        podman_args+=(--security-opt label=disable)

        # privileged is required for libvirtd to be able to write to /proc/sys/net/ipv6/conf/*/disable_ipv6
        podman_args+=(--privileged)

        # Persist storage volumes of libvirt domains
        podman_args+=(-v "${project_name}-images:/home/cloudy/.local/share/libvirt/images/")

        # Persist SSH credentials and configuration for accessing virtual machines
        podman_args+=(-v "${project_name}-ssh:/home/cloudy/.ssh/")
        # Or instead:
        # Grant access to SSH credentials and configuration on Ansible controller for accessing virtual machines
        #podman_args+=(-v "$HOME/.ssh/:/home/cloudy/.ssh/:ro")

        # Grant access to user's playbooks, inventories and Ansible configuration
        podman_args+=(-v "$project_dir/:/home/cloudy/project/:ro")

        # For development only
        podman_args+=(-v "$cmd_dir/entrypoint.sh:/usr/local/bin/entrypoint.sh:ro")

        # Bind mount collection into container which allows derived collections to pin this collection and allows
        # developers of this collection to test changes to this collection, skipping the collection installation from
        # Ansible Galaxy.
        collection_dir=$(readlink -f "$cmd_dir/..")
        if [ -e "$collection_dir/galaxy.yml" ] \
           && grep -q -e '^name: cloudy$' "$collection_dir/galaxy.yml" \
           && grep -q -e '^namespace: jm1$' "$collection_dir/galaxy.yml"
        then
            podman_args+=(-v "$collection_dir/:/usr/share/ansible/collections/ansible_collections/jm1/cloudy/:ro")
        fi

        if [ "$detach" = "yes" ]; then
            podman_args+=(--detach)
        fi

        podman run \
            --init \
            --interactive \
            --tty \
            --name "${project_name}" \
            -e "DEBUG=${DEBUG:=no}" \
            -e "DEBUG_SHELL=${DEBUG_SHELL:=no}" \
            --network "host" \
            --device '/dev/kvm:/dev/kvm' \
            "${podman_args[@]}" \
            "${project_name}:latest" "${cmd_args[@]}"
    fi
}

stop() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd stop [OPTIONS]

Stop containers.

OPTIONS:
    --project-name NAME   Name to label and find containers, images and volumes with.
                          Defaults to '$project_name_default'.
    -h, --help            Print usage
________EOF
    }

    project_name=""
    project_name_default="cloudy"

    while [ $# -ne 0 ]; do
        case "$1" in
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
        shift
    done

    [ -n "$project_name" ] || project_name=$project_name_default

    podman stop --ignore "${project_name}"
}

down() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd down [OPTIONS]

Stop and remove containers, volumes and networks.

OPTIONS:
    --project-name NAME   Name to label and find containers, images and volumes with.
                          Defaults to '$project_name_default'.
    -h, --help            Print usage
________EOF
    }

    project_name=""
    project_name_default="cloudy"

    while [ $# -ne 0 ]; do
        case "$1" in
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
        shift
    done

    [ -n "$project_name" ] || project_name=$project_name_default


    podman stop --ignore "${project_name}"
    podman rm --force --ignore "${project_name}"

    podman image rm --force "${project_name}:latest" || true
    podman volume rm --force "${project_name}-images" || true
    podman volume rm --force "${project_name}-ssh" || true
}

if [ $# -eq 0 ]; then
    help
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    error "Please run as root"
    exit 125
fi

for cmd in ip podman; do
    if ! command -v "$cmd" >/dev/null; then
        error "$cmd not found"
        exit 255
    fi
done

while [ $# -ne 0 ]; do
    case "$1" in
        "up"|"stop"|"down"|"help")
            ("$@")
            exit
            ;;
        "-h"|"--help")
            help
            exit 0
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
    shift
done
