#!/bin/sh
# This script is called by microservice production deployment pipelines to keep track of production deployment inside Newrelic.
# It relies on newrelic.yml generated within the GO artifactory for app_name that matches newrelic app name.
# by F. Zhang, 6/13/2018

# Params passed in from GO pipeline

ENV=$1
BANNER=$2
USER=$3
REVISION=$4

# NewRelic API_KEY is unique and tied to HBC Digital account with newrelic.
# It should not change. But in case it changes, please update the following
API_KEY=d9e556c8623142c6a

echo USER=$USER
echo REVISION=$REVISION
echo API_KEY=$API_KEY


if [ $ENV = "prod" ]; then

	#APP_NAME=`grep _$ENV newrelic.yml |awk '{ print $2}'`
	APP_NAME=`grep _prod newrelic.yml |awk '{ print $2}'`
	echo APP_NAME=$APP_NAME

	# download information from Newrelic to retrieve app_id

	curl -X GET 'https://api.newrelic.com/v2/applications.json' \
	     -H "X-Api-Key:${API_KEY}" \
	     -d "filter[name]=${APP_NAME}" \
	     -o applications.json

	APP_ID=$(jq -r --arg app_name "$APP_NAME" '.applications[] | select(.name==$app_name) | .id' applications.json)
	echo APP_ID=$APP_ID

	# Send deployment status to Newrelic

	curl -X POST 'https://api.newrelic.com/v2/applications/'$APP_ID'/deployments.json' \
	     -H "X-Api-Key:$API_KEY" -i \
	     -H 'Content-Type: application/json' \
	     -d \
	'{
	  "deployment": {
	    "revision": "'$REVISION'",
	    "user": "'$USER'"
	  }
	}'

else
	echo "NewRelic does not monitor non-production deployment";
fi

