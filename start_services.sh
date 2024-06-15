#!/bin/bash

# Elimina el fitxer de PID del servei si existeix
rm -f /var/run/dsm_om_connsvcd.pid

# Executa el servei DSM SA Connection Service
LD_LIBRARY_PATH=$(/opt/dell/srvadmin/sbin/dsm_om_connsvc-helper) /opt/dell/srvadmin/sbin/dsm_om_connsvcd -run

# Manté el contenidor actiu
tail -f /dev/null