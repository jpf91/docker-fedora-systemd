# https://fedoramagazine.org/building-smaller-container-images/
FROM registry.fedoraproject.org/fedora-minimal:33

RUN microdnf install \
    systemd && \
    microdnf clean all

# Forward journal logs to console
RUN echo "ForwardToConsole=yes" >> /etc/systemd/journald.conf

# Do not display a login prompt
RUN systemctl mask console-getty.service getty@tty1.service

# Add infrastructure to run setup and start scripts
ADD initial-setup.service /etc/systemd/system/initial-setup.service
ADD start-scripts.service /etc/systemd/system/start-scripts.service
ADD initial-setup.sh /etc/initial-setup.sh
ADD start-scripts.sh /etc/start-scripts.sh
ADD 00-setup-user-units.sh /etc/initial-setup.d/00-setup-user-units.sh
 
RUN mkdir -p /etc/initial-setup.d && \
    mkdir -p /etc/initial-setup.user.d && \
    mkdir -p /etc/start-scripts.d && \
    mkdir -p /etc/start-scripts.user.d && \
    mkdir -p /etc/systemd/user-units && \
    systemctl enable initial-setup.service && \
    systemctl enable start-scripts.service

ENTRYPOINT ["/sbin/init"]
