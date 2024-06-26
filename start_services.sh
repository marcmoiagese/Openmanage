#!/bin/sh

echo "Started at $(date)"

if [ "" = "${OMSA_USER}" -o "" = "${OMSA_PASS}" ]; then
        echo 'Please specify OMSA_USER and OMSA_PASS env vars.'
        exit 1;
fi;

# Set login credentials
USER_EXISTS=`cat /etc/passwd | grep -i "^${OMSA_USER}:"`
if [ "${USER_EXISTS}" = "" ]; then
        echo "Creating user ${OMSA_USER}..."
        adduser "${OMSA_USER}"
fi;

echo "Setting login password for ${OMSA_USER}..."
echo "$OMSA_USER:$OMSA_PASS" | chpasswd

echo "Allowing ${OMSA_USER} access to openmanage..."
echo "${OMSA_USER}    *       Administrator" > /opt/dell/srvadmin/etc/omarolemap

if [ "${UNCERTIFIED_DRIVES}" = "1" -o "${UNCERTIFIED_DRIVES}" = "yes" ]; then
        echo "Allow non-certified drives..."
        sed -i 's/^NonDellCertifiedFlag=.*$/NonDellCertifiedFlag=no/' /opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini
else
        # Reset to default.
        sed -i 's/^NonDellCertifiedFlag=.*$/NonDellCertifiedFlag=yes/' /opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini
fi

echo "Clearing old tmp files..."
rm -Rf /tmp/* /var/tmp/*

echo "Starting init..."
exec /sbin/init