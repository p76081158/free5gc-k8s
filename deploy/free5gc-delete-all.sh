#!/bin/bash

kustomizedelete () {
cd $1 && kubectl delete -k .
cd ../../
}

cd mongodb && kustomizedelete base
cd gnbsim  && kustomizedelete overlays
cd nrf     && kustomizedelete base
cd upf-1   && kustomizedelete overlays
# cd upf-2   && kustomizedelete overlays
cd webui   && kustomizedelete base
cd amf     && kustomizedelete overlays
cd ausf    && kustomizedelete base
cd smf     && kustomizedelete overlays
cd nssf    && kustomizedelete base
cd pcf     && kustomizedelete base
cd udm     && kustomizedelete base
cd udr     && kustomizedelete base
kubectl delete -f free5gc-namespace.yaml
