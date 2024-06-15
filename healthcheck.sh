#!/bin/bash

# Verifica si el procés està en execució
if pgrep -f "dsm_om_connsvcd" > /dev/null && netstat -tuln | grep ":1311 " > /dev/null; then
  exit 0
else
  exit 1
fi