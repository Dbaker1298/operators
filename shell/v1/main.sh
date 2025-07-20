#!/bin/bash
# Grafzahl likes counting things, more things to counts the happier he is.
shopt -s extglob

NUM_PODS=0; NUM_DEPLOYMENTS=0

while true
do
    DEPLOYMENTS=$(kubectl get deployments.apps -A -o json | jq '.items | length')
    PODS=$(kubectl get pods -A -o json | jq '.items | length')
    echo Deployments now $DEPLOYMENTS, previously $NUM_DEPLOYMENTS
    echo Pods now $PODS, previously  $NUM_PODS
    
    DELTA_PODS=$(( $PODS - $NUM_PODS ))
    
    # https://unix.stackexchange.com/a/525551/7362
    # https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching
    case ${DELTA_PODS} in
        -+([[:digit:]]))
           echo "Pods number is the smaller! 🧛 is 😔"
           ;;
        0)
           echo "Pods number is the same! 🧛 is 😐!"
           ;;
        +([[:digit:]]))
           echo "Pods number increased! 🧛 is 😄!"
           ;;
    esac

    DELTA_DEPLOYMENTS=$(( $DEPLOYMENTS - $NUM_DEPLOYMENTS ))

    case ${DELTA_DEPLOYMENTS} in
        -+([[:digit:]]))
           echo "Deployments number is the smaller! 🧛 is !😔"
           ;;
        0)
           echo "Deployments number is the same! 🧛 is 😐!"
           ;;
        +([[:digit:]]))
           echo "Deployments number increased! 🧛 is 😄!"
           ;;
    esac

    NUM_PODS=$PODS; NUM_DEPLOYMENTS=$DEPLOYMENTS
    sleep 10
done
