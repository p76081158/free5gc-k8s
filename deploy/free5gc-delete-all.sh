#!/bin/bash

cd mongodb && kubectl delete -k . && cd ..
cd nrf     && kubectl delete -k . && cd ..
cd upf-1   && kubectl delete -k . && cd ..
cd upf-2   && kubectl delete -k . && cd ..
cd webui   && kubectl delete -k . && cd ..
cd amf     && kubectl delete -k . && cd ..
cd ausf    && kubectl delete -k . && cd ..
cd smf     && kubectl delete -k . && cd ..
cd nssf    && kubectl delete -k . && cd ..
cd pcf     && kubectl delete -k . && cd ..
cd udm     && kubectl delete -k . && cd ..
cd udr     && kubectl delete -k . && cd ..
kubectl delete -f free5gc-namespace.yaml
