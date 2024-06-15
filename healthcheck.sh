#!/bin/bash

# Llista de serveis a comprovar
services=(
  "systemd-journald"
  "/systemd-logind"
  "dbus-broker-launch"
  "dsm_sa_eventmgrd"
  "dsm_sa_datamgrd"
  "dsm_sa_snmpd"
  "dsm_om_connsvcd"
)

# Funció per comprovar si un servei està actiu
check_service() {
  local service=$1
  if pgrep -f "$service" > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Comprovar els serveis
for service in "${services[@]}"; do
  if ! check_service "$service"; then
    echo "El servei '$service' NO està actiu."
    exit 1
  fi
done

# Comprovar si algun procés està escoltant el port 1311
if netstat -tuln | grep ':1311' > /dev/null; then
  exit 0
else
  echo "NO hi ha cap servei escoltant el port 1311."
  exit 1
fi