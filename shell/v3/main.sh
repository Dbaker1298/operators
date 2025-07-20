#!/bin/bash
# v3/main.sh:v0.0.3
###
# Grafzahl likes counting things, and when there are more things to counts the happier
# he is.
# This silly operator just counts Deployments and Pods in the cluster.
###
# exit on undefined variable
set -u

NUM_PODS=$(kubectl get numbers.grafzahl.io total -o jsonpath='{.spec.pods}')
NUM_DEPLOYMENTS=$(kubectl get numbers.grafzahl.io total -o jsonpath='{.spec.deployments}')

function removeAllLables() {
    local resource=$1
    declare -A MARKED=()
    while read -r a b; do
        MARKED["$a"]="$b"
    done < <(kubectl get $resource -l grafzahl=counted -A -o=jsonpath="{range .items[*]}{.metadata.name}{' '}{.metadata.namespace}{'\n'}{end}")
    
    for key in "${!MARKED[@]}"; do
        kubectl label $resource "$key" -n ${MARKED["$key"]} grafzahl-
    done
}

function patchNumbers(){
   local number=$1
   kubectl patch numbers.grafzahl.io total --type json  -p="[{\"op\": \"replace\", \"path\": \"/spec/${resource}s\", \"value\": ${number}}]"
}

function check() {
    local resource=$1

    case $resource in 
    deployment)
        PREVIOUS_NUM=$NUM_DEPLOYMENTS ;;
    pod)
        PREVIOUS_NUM=$NUM_PODS ;;
    *)
        echo -n "Unknown resource"; exit 1;
        ;;

    esac
    # create an associative array with all deployments names and namespaces
    declare -A NEW=()
    while read -r a b; do
        NEW["$a"]="$b"
    done < <(kubectl get $resource -l grafzahl!=counted -A -o=jsonpath="{range .items[*]}{.metadata.name}{' '}{.metadata.namespace}{'\n'}{end}")

    if [[ ${#NEW[@]} -gt 0 ]]; then
        echo "Found ${#NEW[@]} new ${resource^}s, ${resource} number increased! 🧛 is 😄! (previous: $PREVIOUS_NUM)"

        for key in "${!NEW[@]}"; do
            kubectl patch ${resource} "$key" -n ${NEW["$key"]} --type merge -p '{"metadata": {"labels": {"grafzahl": "counted"}}}'
        done
        NEW_TOTAL=$(( ${#NEW[@]} + PREVIOUS_NUM ))
        patchNumbers $NEW_TOTAL
        return $NEW_TOTAL
    fi

    ALL=$(kubectl get ${resource} -A -o json | jq '.items | length')
    if [[  ${ALL} -lt ${PREVIOUS_NUM} ]]; then
        echo "${resource^} number is the smaller! 🧛 is 😔  (previous: $PREVIOUS_NUM)"
        patchNumbers $ALL
    elif [[ ${ALL} -eq ${PREVIOUS_NUM} ]]; then
        echo "${resource^} number is the same! 🧛 is 😐!"
    fi
    return $ALL
}

while true
do
    check pod
    NUM_PODS=$?
    check deployment
    NUM_DEPLOYMENTS=$?
    sleep 5
done
