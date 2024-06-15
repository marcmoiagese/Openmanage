FROM almalinux:9.3-minimal
MAINTAINER Marc Moya Gesse
LABEL org.opencontainers.image.authors "Marc Moya Gesse"
LABEL org.opencontainers.image.description "Dell OpenManage Server Administrator in Docker."
LABEL org.opencontainers.image.url "https://github.com/marcmoiagese/Openmanage"

# Variables d'entorn
ENV PATH $PATH:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin
ENV SYSTEMCTL_SKIP_REDIRECT=1

# Instalan paquets i requisits
ADD https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi /tmp/bootstrap.sh-tmp-t0quen
ADD https://linux.dell.com/repo/hardware/dsu/copygpgkeys.sh /tmp/copygpgkeys.sh-tmp-t0quen
RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/almalinux-crb.repo && \
    ln -s /usr/bin/microdnf /usr/bin/dnf && \
    ln -s /usr/bin/microdnf /usr/bin/yum && \
    dnf -y update && \
    dnf -y install passwd procps kmod tar which net-tools && \
    cat /tmp/copygpgkeys.sh-tmp-t0quen | bash && \
    sed -i 's/IMPORT_GPG_CONFIRMATION="na"/IMPORT_GPG_CONFIRMATION="yes"/' /tmp/bootstrap.sh-tmp-t0quen && \
    cat /tmp/bootstrap.sh-tmp-t0quen | bash && \
    dnf -y install srvadmin-all dell-system-update-2.0.2.3-23.11.00 && \
    dnf clean all && \
    rm -Rfv /usr/lib/systemd/system/autovt@.service /usr/lib/systemd/system/getty@.service /tmp/bootstrap.sh-tmp-t0quen /tmp/copygpgkeys.sh-tmp-t0quen

# copiem es scripts locals"
COPY start_services.sh /usr/local/bin/start_services.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

# Afegeix permisos d'execució als scripts
RUN chmod +x /usr/local/bin/start_services.sh /usr/local/bin/healthcheck.sh

# Afegeix un health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD /usr/local/bin/healthcheck.sh

# arranquem l'aplicacio
CMD ["/usr/local/bin/start_services.sh"]