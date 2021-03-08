#!/bin/bash

checkpod () {
while [[ $(kubectl -n free5gc get pods -l app=$1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" $1 && sleep 1; done
}

kubectl apply -f free5gc-namespace.yaml && sleep 1
cd mongodb && kubectl apply -k . && cd ..

# Depends on mongodb
checkpod free5gc-mongodb
cd nrf     && kubectl apply -k . && cd ..
cd upf-1   && kubectl apply -k . && cd ..
cd upf-2   && kubectl apply -k . && cd ..
cd webui   && kubectl apply -k . && cd ..

# Depends on nrf & upf
checkpod free5gc-nrf
checkpod free5gc-upf-1
checkpod free5gc-upf-2
cd amf     && kubectl apply -k . && cd ..
cd ausf    && kubectl apply -k . && cd ..
cd smf     && kubectl apply -k . && cd ..
cd nssf    && kubectl apply -k . && cd ..
cd pcf     && kubectl apply -k . && cd ..
cd udm     && kubectl apply -k . && cd ..
cd udr     && kubectl apply -k . && cd ..

