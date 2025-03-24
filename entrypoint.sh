#!/bin/bash -l

client_id=${1}
client_secret=${2}
realm=${3}
idm_base_url=${4}
workflow_api_base_url=${5}
execution_id=${6}

export client_id=$client_id
export client_secret=$client_secret


secret_stk_login=$(curl -s --location --request POST "$idm_base_url/realms/$realm/protocol/openid-connect/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=$client_id" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_secret=$client_secret" | jq -r .access_token)

github_run_id="${GITHUB_RUN_ID}"
echo "GITHUB RUN ID:" $github_run_id

put_workflow_scm_execution_id_url="$workflow_api_base_url/v1/executions/$execution_id/bind-scm"

echo "Binding the execution id $github_id to workflow with execution id $execution_id"

http_code=$(curl -s -o output.json -w '%{http_code}' --request PUT "$put_workflow_scm_execution_id_url" \
    --header "Authorization: Bearer $secret_stk_login" \
    --header 'Content-Type: application/json' \
    --data "{\"scmWorkflowExecutionId\": \"$github_run_id\"}")

if [[ "$http_code" -ne "204" ]]; then
    echo "OOPS! Something went wrong binding the execution id $github_id to workflow with execution id: $execution_id"
    echo "HTTP_CODE:" $http_code
    echo "RESPONSE_CONTENT:" $(cat output.json)
else
    echo "Successfully bound the execution"
fi