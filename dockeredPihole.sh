#!/usr/bin/env bash

function pi_unavailable() {
    
  cat <<EOF

    ___  _    _  _ ____ _    ____    _  _ ____ ___    ____ _  _ ____ _ _    ____ ___  _    ____
    |__] | __ |__| |  | |    |___    |\ | |  |  |     |__| |  | |__| | |    |__| |__] |    |___
    |    |    |  | |__| |___ |___    | \| |__|  |     |  |  \/  |  | | |___ |  | |__] |___ |___

EOF
}

function pi_available() {
    
  cat <<EOF

    ___  _    _  _ ____ _    ____    ____ _  _ ____ _ _    ____ ___  _    ____
    |__] | __ |__| |  | |    |___    |__| |  | |__| | |    |__| |__] |    |___
    |    |    |  | |__| |___ |___    |  |  \/  |  | | |___ |  | |__] |___ |___

EOF
}

function checkDocker() {
    if [ -z "$CN" ]
    then
        check
        cn=$(docker ps --format "{{.Names}}" | grep -i pihole)
        export CN=$cn
        echo "Container name detected $CN"
    fi
}

function dockerConfig() {
    export DOCKER_CONFIGS="$PWD"
    echo "Pi-hole docker config location $DOCKER_CONFIGS"
}

function ip() {
    dockerConfig
    case "$(uname -s)" in
        
        Darwin)
            echo 'Mac OS X'
            export LOCAL_IP="$(ipconfig getifaddr en1)"
        ;;
        
        Linux)
            echo 'Linux'
            # Lookups may not work for VPN / tun0
            export IP_LOOKUP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"
        ;;
        
        CYGWIN* | MINGW32* | MSYS*)
            echo 'MS Windows'
        ;;
        
        # Add here more strings to compare
        # See correspondence table at the bottom of this answer
        
        *)
            echo 'other OS'
        ;;
    esac
    echo "Host ip to be used $LOCAL_IP for setting up pihole docker container"
}

function scan() {
    #write logic to scan ports used by pihole before setup
    echo "pihole scan"
    echo "If this is first time running this script."
    echo "and if you see ports already used, either change ports in docker-compose.yml file"
    echo "or close other apps using same ports"
    case "$(uname -s)" in
        
        Darwin)
            echo 'Mac OS X'
            netstat -vanp tcp | grep 53 | grep LISTEN
            netstat -vanp tcp | grep 80 | grep LISTEN
            netstat -vanp tcp | grep 443 | grep LISTEN
            echo 'port scanned'
        ;;
        
        Linux)
            echo 'Linux'
            # Lookups may not work for VPN / tun0
            
        ;;
        
        CYGWIN* | MINGW32* | MSYS*)
            echo 'MS Windows'
        ;;
        
        # Add here more strings to compare
        # See correspondence table at the bottom of this answer
        
        *)
            echo 'other OS'
        ;;
    esac
}

function shutdown() {
    echo "pihole shutdown"
    docker-compose down
}

function start() {
    echo "pihole start in detach mode"
    docker-compose up -d
}

function clean() {
    
    echo "pihole cleaning"
    docker-compose rm -f
    docker rmi "$DOCKER_IMAGE"
}

function destroy() {
    shutdown
    clean
}

function version() {
    checkDocker
    echo "pihole version"
    docker exec "$CN" pihole -v
}

function upgrade() {
    checkDocker
    echo "pihole upgrade"
    docker exec "$CN" pihole -up
}

function password() {
    checkDocker
    echo -n "Your password for http://${LOCAL_IP}/admin/ is "
    docker logs $CN 2>/dev/null | grep 'password:'
}

function pullLatest() {
    docker pull "$DOCKER_IMAGE"
}

function shell() {
    checkDocker
    docker exec -it $CN bash
}

function updateAdlist(){
    # download data from https://v.firebog.net/hosts/lists.php?type=tick to /etc/pihole/adlists.list
    # pihole folder is always mapped because of docker volume
    curl https://v.firebog.net/hosts/lists.php?type=tick >> pihole/adlists.list
    echo "updating pihole with 3rd party lists"
    picmd -g
    
}
function picmd() {
    checkDocker
    echo "pihole command execution of $CN pihole $1"
    docker exec "$CN" pihole "$1"
}

function changePassword() {
    checkDocker
    docker exec "$CN" pihole -a -p "$1"
}

function check() {
    docker ps
    if [ $? -eq 0 ]; then
        echo "Docker daemon running"
        
    else
        echo "Is docker daemon running."
        echo "Please start the docker daemon.Exiting..."
        pi_unavailable
        exit -1
    fi
}

function restartdns(){
    checkDocker
    docker exec $CN pihole restartdns
}

function wait4url() {
    checkDocker
    WAIT_URL="http://${LOCAL_IP}/admin/"
    echo "Waiting for $WAIT_URL"
    while true; do
        STATUS=$(curl -s -o /dev/null -w '%{http_code}' "$WAIT_URL")
        if [ $STATUS -eq 200 ]; then
            echo "Got 200! Pihole is up!"
            break
            if [ ${attempt_counter} -eq ${max_attempts} ]; then
                echo "Max attempts reached"
                exit 1
            fi
        else
            printf "."
        fi
        attempt_counter=$(($attempt_counter + 1))
        sleep 2
    done
}

function setup() {
    scan
    ip
    shutdown
    clean
    pullLatest
    start
    version
    wait4url
    password
    pi_available
    upgrade
    updateAdlist
}

function usage() {
    echo "Usage:"
    echo "    ./dockeredPihole.sh [-h][--help]                Display this help message."
    echo "    ./dockeredPihole.sh setup                       Install a pi-hole in docker container."
    echo "    ./dockeredPihole.sh version                     Print pi-hole version."
    echo "    ./dockeredPihole.sh upgrade                     Do pi-hole upgrade."
    echo "    ./dockeredPihole.sh password                    Print pi-hole password."
    echo "    ./dockeredPihole.sh shell                       Get pi-hole shell."
    echo "    ./dockeredPihole.sh ip                          Get host ip."
    echo "    ./dockeredPihole.sh restartdns                  Restart pi-hole dns."
    echo "    ./dockeredPihole.sh destroy                     Remove pi-hole docker image and container."
    echo "    ./dockeredPihole.sh changePassword <<PASS>>     Change pi-hole password."
    echo "    ./dockeredPihole.sh picmd <<cmd>>               Execute pi-hole commands directly like pihole status,pihole -c ."
    
    
}

function main() {
    
    echo "Processing $1 $2"
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi
    
    case $1 in
        
        setup)
            setup
        ;;
        version)
            version
        ;;
        upgrade)
            upgrade
        ;;
        password)
            password
        ;;
        shell)
            shell
        ;;
        ip)
            ip
        ;;
        destroy)
            destroy
        ;;
        changePassword)
            changePassword "$2"
        ;;
        restartdns)
            restartdns
        ;;
        picmd)
            picmd "$2"
        ;;
        *)
            echo "No command found"
            usage
            exit 0
        ;;
    esac
    
}
clear
attempt_counter=0
max_attempts=5
DOCKER_IMAGE="pihole/pihole"
main $1 $2




