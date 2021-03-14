#!/bin/bash

checkpod () {
while [[ $(kubectl -n free5gc get pods -l app=$1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" $1 && sleep 1; done
}

kustomizeapply () {
cd $1 && kubectl apply -k .
cd ../../
}

kubectl apply -f free5gc-namespace.yaml && sleep 1
cd mongodb && kustomizeapply base
cd gnbsim  && kustomizeapply overlays

# Depends on mongodb
checkpod free5gc-mongodb
cd nrf     && kustomizeapply base
cd upf-1   && kustomizeapply overlays
# cd upf-2   && kustomizeapply overlays
cd webui   && kustomizeapply base

# Depends on nrf & upf
checkpod free5gc-nrf
checkpod free5gc-upf-1
# checkpod free5gc-upf-2
cd amf     && kustomizeapply overlays
cd ausf    && kustomizeapply base
cd smf     && kustomizeapply overlays
cd nssf    && kustomizeapply base
cd pcf     && kustomizeapply base
cd udm     && kustomizeapply base
cd udr     && kustomizeapply base
