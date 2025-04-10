#!/bin/bash -l

client_id=${1}
client_secret=${2}
realm=${3}
idm_base_url=${4}
workflow_api_base_url=${5}
execution_id=${6}
stackspot_workflow_job=${7}

if [[ -z "$execution_id" ]]; then
    echo "'execution_id' is empty."
    exit 0
fi

if [[ -z "$stackspot_workflow_job" ]]; then
    echo "'stackspot_workflow_job' is empty."
    exit 0
fi

secret_stk_login=$(curl -s --location --request POST "$idm_base_url/realms/$realm/protocol/openid-connect/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=$client_id" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_secret=$client_secret" | jq -r .access_token)

github_run_id="${GITHUB_RUN_ID}"
echo "GITHUB RUN ID:" $github_run_id

put_workflow_scm_execution_id_url="$workflow_api_base_url/v1/executions/$execution_id/bind-scm"

echo "Associating the GitHub execution ID '$github_id' to the workflow execution ID '$execution_id', including the job '$stackspot_workflow_job'."

http_code=$(curl -s -o output.json -w '%{http_code}' --request PUT "$put_workflow_scm_execution_id_url" \
    --header "Authorization: Bearer $secret_stk_login" \
    --header 'Content-Type: application/json' \
    --data "{\"scmWorkflowExecutionId\": \"$github_run_id\", \"stackspotWorkflowJob\": \"$stackspot_workflow_job\"}")

if [[ "$http_code" -ne "204" ]]; then
    echo "OOPS! Something went wrong binding the execution id $github_id to workflow with execution id: $execution_id"
    echo "HTTP_CODE:" $http_code
    echo "RESPONSE_CONTENT:" $(cat output.json)
else
    echo "Successfully bound the execution"
fi