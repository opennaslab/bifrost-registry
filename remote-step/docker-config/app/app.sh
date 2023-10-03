#!/bash/env bash

set -o errexit

app_path=$(cd `dirname $0`; pwd)

server_addr=$(cat /root/bifrost-data/input.json | jq '.serverAddr' | sed 's/"//g')
server_port=$(cat /root/bifrost-data/input.json | jq '.serverPort' | sed 's/"//g')
server_user=$(cat /root/bifrost-data/input.json | jq '.serverUser' | sed 's/"//g')
server_password=$(cat /root/bifrost-data/input.json | jq '.serverPassword' | sed 's/"//g')
workflow_name=$(cat /root/bifrost-data/workflow.json | jq '.workflowName' | sed 's/"//g')
step_name=$(cat /root/bifrost-data/workflow.json | jq '.stepName' | sed 's/"//g')
opetation=$(cat /root/bifrost-data/workflow.json | jq '.opetation' | sed 's/"//g')

function configuration() {
    if [ -z "$server_addr" ]; then
        echo "server_addr is empty"
        exit 1
    fi
    if [ -z "$server_port" ]; then
        echo "server_port is empty"
        exit 1
    fi
    if [ -z "$server_user" ]; then
        echo "server_user is empty"
        exit 1
    fi
    if [ -z "$server_password" ]; then
        echo "server_password is empty"
        exit 1
    fi

    sshpass -p $server_password ssh -o StrictHostKeyChecking=no $server_user@$server_addr -p $server_port "rm -rf /root/bifrost-data/workflow/$workflow_name/$step_name"
    sshpass -p $server_password ssh -o StrictHostKeyChecking=no $server_user@$server_addr -p $server_port "mkdir -p /root/bifrost-data/workflow/$workflow_name/$step_name/scripts"
    sshpass -p $server_password scp -P $server_port -r $app_path/scripts $server_user@$server_addr:/root/bifrost-data/workflow/$workflow_name/$step_name
    sshpass -p $server_password ssh -o StrictHostKeyChecking=no $server_user@$server_addr -p $server_port "chmod +x /root/bifrost-data/workflow/$workflow_name/$step_name/scripts/*.sh"
    sshpass -p $server_password ssh -o StrictHostKeyChecking=no $server_user@$server_addr -p $server_port "cd /root/bifrost-data/workflow/$workflow_name/$step_name/scripts && bash install_docker.sh"
}

function destroy() {
    # It's not necessary to uninstall docker
    sshpass -p $server_password ssh -o StrictHostKeyChecking=no $server_user@$server_addr -p $server_port "rm -rf /root/bifrost-data/workflow/$workflow_name/$step_name"
}

if [ "$opetation" == "configuration" ]; then
    configuration
elif [ "$opetation" == "destroy" ]; then
    destroy
fi
