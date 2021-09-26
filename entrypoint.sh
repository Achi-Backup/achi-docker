#!/bin/bash
set -e

if [[ -n "${TZ}" ]]; then
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone
    printf '%s\n' "[$(date +"%T")] [OK] Set system timezone to ${TZ}"
fi

cd /achi-blockchain || exit 1

. ./activate && achi init

if [[ ${ACHI_KEYS} == "persistent" ]]; then
    printf '%s\n' "[$(date +"%T")] [INFO] Not touching key directories"
elif [[ ${ACHI_KEYS} == "generate" ]]; then
    printf '%s\n' "[$(date +"%T")] [INFO] To use your own keys pass them as a text file -v /path/to/keyfile:/path/in/container and -e keys=\"/path/in/container\""
    achi keys generate
elif [[ ${ACHI_KEYS} == "copy" ]]; then
    if [[ -z ${ACHI_CA} ]]; then
        printf '%s\n' "[$(date +"%T")] [Error] A path to a copy of the farmer peer's ssl/ca required."
        exit
    else
        achi init -c "${ACHI_CA}"
        printf '%s\n' "[$(date +"%T")] [OK] Initialized achi with copied keys"
    fi
else
    achi keys add -f "${ACHI_KEYS}"
fi

if [[ -n "${ACHI_WALLET_KEY}" ]]; then
    echo "$ACHI_WALLET_KEY" | achi keys add
    printf '%s\n' "[$(date +"%T")] [OK] Added wallet"
fi

if [[ -z ${FARMER_ADDRESS} || -z ${FARMER_PORT} || -z ${ACHI_CA} ]]; then
    achi configure --set-farmer-peer "${FARMER_ADDRESS}:${FARMER_PORT}"
    printf '%s\n' "[$(date +"%T")] [OK] Set farmer peer to ${FARMER_ADDRESS}:${FARMER_PORT}"
fi

for p in ${ACHI_PLOTS_DIR//:/ }; do
    mkdir -p "${p}"
    if [[ ! $(ls -A "$p") ]]; then
        printf '%s\n' "[$(date +"%T")] [WARNING] Plots directory '${p}' appears to be empty, try mounting a plot directory with the docker -v command"
    fi
    achi plots add -d "${p}"
    printf '%s\n' "[$(date +"%T")] [OK] Added ${p} to plots directories"
done

if [[ -n "${ACHI_LOG_LEVEL}" ]]; then
    achi configure --log-level "${ACHI_LOG_LEVEL}"
    printf '%s\n' "[$(date +"%T")] [OK] Set log level to ${ACHI_LOG_LEVEL}"
fi

sed -i 's/localhost/127.0.0.1/g' "$ACHI_ROOT/config/config.yaml"

cp /etc/hosts /etc/hosts~
sed -ri 's/^::1/#::1/g' /etc/hosts~
cat /etc/hosts~ > /etc/hosts
rm -rf /etc/hosts~

# Ensures the log file actually exists, so we can tail successfully
touch "$ACHI_ROOT/log/debug.log"
tail -f "$ACHI_ROOT/log/debug.log"
