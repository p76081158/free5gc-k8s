#!/bin/bash

kustomizedelete () {
cd $1 && kubectl delete -k . && cd ../../
}

cd mongodb && kustomizedelete base
cd nrf     && kustomizedelete base
cd upf-1   && kustomizedelete base
cd upf-2   && kustomizedelete base
cd webui   && kustomizedelete base
cd amf     && kustomizedelete base
cd ausf    && kustomizedelete base
cd smf     && kustomizedelete base
cd nssf    && kustomizedelete base
cd pcf     && kustomizedelete base
cd udm     && kustomizedelete base
cd udr     && kustomizedelete base
kubectl delete -f free5gc-namespace.yaml
