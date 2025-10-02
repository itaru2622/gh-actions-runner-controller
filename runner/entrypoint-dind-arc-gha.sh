#!/bin/bash
source logger.sh

function wait_for_dockerd () {
    local max_time_wait=30
    local waited_sec=0
    while ! docker ps -qa >/dev/null && ((waited_sec < max_time_wait)); do
        log.debug "docker is not ready yet. wait 1 seconds ($waited_sec / $max_time_wait)"
        sleep 1
        ((waited_sec=waited_sec+1))
        if ((waited_sec >= max_time_wait)); then
            return 1
        fi
    done
    return 0
}

log.debug 'Starting Docker daemon'
sudo /usr/bin/dockerd &

log.debug 'Waiting dockerd to be running..'.

if ! wait_for_dockerd ; then
     log.error "docker is not running after max time"
     exit 0
else
     log.debug "docker is ready"
fi

# skip executing config.sh, feeded via env: ACTIONS_RUNNER_INPUT_JITCONFIG

if [ -e /etc/environment ]; then
      mapfile -t env </etc/environment
fi

update-status "Idle"
log.debug 'Starting run.sh ...'
exec env -- "${env[@]}" ./run.sh
