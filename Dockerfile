# Utilitzem la imatge oficial d'Ubuntu 22.04 com a base
FROM ubuntu:22.04
USER root

# Establim fus horari
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Andorra

# Actualitzem el sistema i instal·lem les dependencies necessaries
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    wget \
    apt-transport-https \
    gnupg2 \
    curl

# Afegeix el repositori de Dell OpenManage
RUN echo 'deb http://linux.dell.com/repo/community/openmanage/11010/jammy jammy main' | tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list

# Descarrega i afegeix la clau PGP per al repositori de Dell
RUN wget https://linux.dell.com/repo/pgp_pubkeys/0x1285491434D8786F.asc && \
    apt-key add 0x1285491434D8786F.asc

# Descarrega i instal·la el paquet srvadmin-all evitant l'ús de systemctl
RUN apt-get update && apt-get install -y \
    dbus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crea un script de placeholder per systemctl
RUN echo '#!/bin/bash\nexit 0' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl

# Instal·la el paquet srvadmin-all
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y srvadmin-all

# Neteja els arxius de configuració que no són necessaris per a reduir la mida de la imatge
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f 0x1285491434D8786F.asc

# Especifica l'usuari per defecte (opcional, si no es necessita executar com a root)
# USER nobody

# Crea els usuaris admin i operator amb la contrasenya perdefecte
RUN useradd -m admin && echo "admin:84356Drft" | chpasswd
RUN useradd -m -g users operator && echo "operator:84356Dçrft·" | chpasswd

# Modifica el fitxer omarolemap
RUN echo -e "\nadmin\t*\tAdministrator\noperator\t*\tUser" >> /opt/dell/srvadmin/etc/omarolemap

# Copia l'script d'inicialització al contenidor
COPY start_services.sh /usr/local/bin/start_services.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

# Afegeix permisos d'execució als scripts
RUN chmod +x /usr/local/bin/start_services.sh /usr/local/bin/healthcheck.sh

# Afegeix un health check
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

# Comanda per defecte per executar l'script d'inicialització
CMD ["/usr/local/bin/start_services.sh"]