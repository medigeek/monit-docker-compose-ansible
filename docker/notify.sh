#!/bin/bash
# Generate a random number between 5 and 20
random_number=$((RANDOM % 16 + 5))

# Sleep for the random number of seconds
sleep $random_number

RUNDECK_WEBHOOK_URL=$(head -n 1 "${RUNDECK_WEBHOOK_URL_FILE}")

MESSAGE="$MONIT_DATE $APPNAME $MONIT_SERVICE $MONIT_EVENT $MONIT_ACTION $MONIT_DESCRIPTION"

curl -s -k -f -X POST -H 'Content-Type:application/json' -H 'Accept:application/json' -d "{\"message\":\"${MESSAGE}\"}" "${RUNDECK_WEBHOOK_URL}"

exit $?

