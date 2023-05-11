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
                                  debian_11, debian_12, ubuntu_1804, ubuntu_2004 and ubuntu_2204.
    --infra-image IMAGE           Container image that will be used for the infra container.
                                  Defaults to '$infra_image_default'.
    -h, --help                    Print usage.
________EOF
    }

    cmd_args=()
    detach="no"
    distribution=""
    distribution_default="debian_11"
    infra_image=""
    infra_image_default="alpine:latest"

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
            "--infra-image")
                if [ -z "$2" ]; then
                    error "flag is missing arg: --infra-image"
                    return 255
                fi

                infra_image="$2"
                shift
                ;;
            "-h"|"--help")
                help
                return 0
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
    [ -n "$infra_image" ] || infra_image=$infra_image_default

    case "$distribution" in
        "centos_8"|"centos_9"|"debian_10"|"debian_11"|"debian_12"|"ubuntu_1804"|"ubuntu_2004"|"ubuntu_2204")
            ;;
        *)
            error "Unsupported distribution: $distribution"
            return 255
            ;;
    esac

    distribution_alt="$(echo "$distribution" | tr '_' '-')"

    cmd="$(readlink -f "$0")"
    cd "$(dirname "$cmd")"

    # Podman 3.0.1 does not support podman network exists and does not support regular expressions in filters
    if ! podman network ls -q '--filter=name=cloudy' | grep -q -e '^cloudy$'; then
        podman network create --driver=bridge \
            --subnet=192.168.150.0/24 \
            --ip-range=192.168.150.0/24 \
            --gateway=192.168.150.1 \
            cloudy
    fi

    for volume in "cloudy-$distribution_alt-images" "cloudy-$distribution_alt-ssh"; do
        # Podman 3.0.1 does not support podman volume exists and does not support regular expressions in filters
        if ! podman volume ls -q "--filter=name=$volume" | grep -q -e "^$volume\$"; then
            podman volume create "$volume"
        fi
    done

    if podman container exists cloudy-infra; then
        if [ -z "$(podman container ls -a -q '--filter=name=^cloudy-infra$' --filter=status=running)" ]; then
            warn "Stopped container cloudy-infra will be (re)started, but not rebuild."\
                 "Remove container first to force rebuild."
            podman start cloudy-infra
        fi
    else
        # Start a container to bring up Podman network cloudy
        # Podman network cloudy has to be started for the following ip route add commands
        podman run --detach --stop-signal SIGKILL --network cloudy --name cloudy-infra \
            "$infra_image" sleep infinity
    fi

    if ! gateway=$(ip -json route get 192.168.157.0 | jq -r -e '.[0] | .prefsrc') \
       || [ "$gateway" != "192.168.150.1" ]; then
        ip route add 192.168.157.0/24 via 192.168.150.1
    fi

    if ! gateway=$(ip -json route get 192.168.158.0 | jq -r -e '.[0] | .prefsrc') \
       || [ "$gateway" != "192.168.150.1" ]; then
        ip route add 192.168.158.0/24 via 192.168.150.1
    fi

    if podman container exists "cloudy-$distribution_alt"; then
        # Container exists
        if [ -z "$(podman container ls -a -q "--filter=name=^cloudy-$distribution_alt\$" --filter=status=running)" ]
        then
            warn "Stopped container cloudy-$distribution_alt will be (re)started, but not rebuild."\
                 "Remove container first to force rebuild."
            podman start "cloudy-$distribution_alt"

            if [ "$detach" != "yes" ]; then
                podman attach "cloudy-$distribution_alt"
            fi
        fi
    else # Container does not exist
        if ! podman image exists "cloudy-$distribution_alt:latest"; then
            podman image build -f "Dockerfile.$distribution" -t "cloudy-$distribution_alt:latest" .
        fi

        podman_args=()

        # privileged is required for libvirtd to be able to write to /proc/sys/net/ipv6/conf/*/disable_ipv6
        podman_args+=(--privileged)

        # libvirt tcp transport
        podman_args+=(--publish '127.0.0.1:16509:16509/tcp')

        # VNC connections
        podman_args+=(--publish '127.0.0.1:5900-5999:5900-5999/tcp')

        # Persist storage volumes of libvirt domains
        podman_args+=(-v "cloudy-$distribution_alt-images:/home/cloudy/.local/share/libvirt/images/")

        # Persist SSH credentials and configuration for accessing virtual machines
        podman_args+=(-v "cloudy-$distribution_alt-ssh:/home/cloudy/.ssh/")
        # Or instead:
        # Grant access to SSH credentials and configuration on Ansible controller for accessing virtual machines
        #podman_args+=(-v "$HOME/.ssh/:/home/cloudy/.ssh/:ro")

        # Grant access to user's playbooks, inventories and Ansible configuration
        podman_args+=(-v "$PWD/../:/home/cloudy/project/:ro")

        # For development only
        podman_args+=(-v "$PWD/entrypoint.sh:/usr/local/bin/entrypoint.sh:ro")

        if [ "$detach" = "yes" ]; then
            podman_args+=(--detach)
        fi

        podman run \
            --init \
            --interactive \
            --tty \
            --name "cloudy-$distribution_alt" \
            --security-opt label=disable \
            -e "DEBUG=${DEBUG:=no}" \
            -e "DEBUG_SHELL=${DEBUG_SHELL:=no}" \
            --network cloudy \
            --device '/dev/kvm:/dev/kvm' \
            --sysctl "net.ipv4.conf.eth0.proxy_arp=1" \
            "${podman_args[@]}" \
            "cloudy-$distribution_alt:latest" "${cmd_args[@]}"
    fi
}

stop() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd stop [OPTIONS]

Stop containers.

OPTIONS:
    -h, --help      Print usage
________EOF
    }

    while [ $# -ne 0 ]; do
        case "$1" in
            "-h"|"--help")
                help
                return 0
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

    for distribution_alt in \
        "centos-8" "centos-9" "debian-10" "debian-11" "debian-12" "ubuntu-1804" "ubuntu-2004" "ubuntu-2204"; do
        podman stop --ignore "cloudy-$distribution_alt"
    done

    ip route del 192.168.158.0/24 via 192.168.150.1 || true
    ip route del 192.168.157.0/24 via 192.168.150.1 || true
    podman stop --ignore cloudy-infra
}

down() {
    help() {
        cmd=$(basename "$0")
        cat << ________EOF
Usage:  $cmd down [OPTIONS]

Stop and remove containers, volumes and networks.

OPTIONS:
    -h, --help      Print usage
________EOF
    }

    while [ $# -ne 0 ]; do
        case "$1" in
            "-h"|"--help")
                help
                return 0
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

    for distribution_alt in \
        "centos-8" "centos-9" "debian-10" "debian-11" "debian-12" "ubuntu-1804" "ubuntu-2004" "ubuntu-2204"; do
        podman stop --ignore "cloudy-$distribution_alt"
        podman rm --force --ignore "cloudy-$distribution_alt"
    done

    ip route del 192.168.158.0/24 via 192.168.150.1 || true
    ip route del 192.168.157.0/24 via 192.168.150.1 || true
    podman rm --force --ignore cloudy-infra

    for distribution_alt in \
        "centos-8" "centos-9" "debian-10" "debian-11" "debian-12" "ubuntu-1804" "ubuntu-2004" "ubuntu-2204"; do
        podman image rm --force "cloudy-$distribution_alt:latest" || true
        podman volume rm --force "cloudy-$distribution_alt-images" || true
        podman volume rm --force "cloudy-$distribution_alt-ssh" || true
    done

    podman network rm --force cloudy || true
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
