FROM kubeflownotebookswg/base:v1.6.0-rc.0

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get -yq install --no-install-recommends \
    openssh-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
COPY ./s6/cont-init.d/10-copy-config /etc/cont-init.d/10-copy-config 
COPY ./s6/cont-init.d/20-copy-host-keys /etc/cont-init.d/20-copy-host-keys
COPY ./s6/cont-init.d/30-copy-authorized-key /etc/cont-init.d/30-copy-authorized-key
COPY ./s6/services.d/openssh-server /etc/services.d/openssh-server
COPY ./config/sshd_config /tmp/sshd_config

RUN mkdir -p /tmp/mutagen \
  && wget -qO- https://github.com/mutagen-io/mutagen/releases/download/v0.16.3/mutagen_linux_amd64_v0.16.3.tar.gz | tar xz -C /tmp/mutagen \
  && tar xzf /tmp/mutagen/mutagen-agents.tar.gz -C /tmp/mutagen \
  && /tmp/mutagen/linux_amd64 install \
  && rm -rf /tmp/mutagen

RUN chown -R ${NB_USER}:users /home/jovyan/.mutagen

RUN mkdir /opt/ssh && \
  chown ${NB_USER}:users /opt/ssh

RUN touch /opt/ssh/authorized_keys

RUN chown -R ${NB_USER}:users /etc/cont-init.d && \
  chown -R ${NB_USER}:users /etc/services.d && \
  chown -R ${NB_USER}:users /tmp/sshd_config && \
  chown -R ${NB_USER}:users /opt/ssh/authorized_keys

USER ${NB_UID}

EXPOSE 2222

VOLUME /opt/ssh

ENTRYPOINT ["/init"]