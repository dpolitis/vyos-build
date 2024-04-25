FROM vyos/vyos-build:sagitta

# Install various dependancies for OVA build
ARG DISPLAY=':0'
ADD misc/ovftool.bundle /root/ovftool.bundle
RUN chmod +x /root/ovftool.bundle

RUN apt-get update && apt-get install -y \
    libncursesw5 \
    parted \
    udev \
    kpartx

RUN /root/ovftool.bundle --eulas-agreed --console --required; \
    rm /root/ovftool.bundle

# Create X509 Certificate for image sign
ENV PRIVATE_KEY_PATH /root/builder.pem
RUN cd /tmp; \
    openssl req -nodes -newkey rsa:2048 -keyout builder.key \
    -out builder.csr \
    -subj "/C=GR/ST=Attica/L=Athens/O=Acme Corp./OU=IT Dept./CN=acmecorp.gr"; \
    openssl x509 -req -days 730 -in builder.csr -signkey builder.key -out builder.crt; \
    cat builder.crt builder.key >> $PRIVATE_KEY_PATH

COPY misc/build.sh /usr/local/bin/build.sh
COPY misc/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/build.sh; \
    chmod +x /usr/local/bin/entrypoint.sh

RUN apt update; \
    apt upgrade -y; \
    apt clean packages

WORKDIR /vyos

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/usr/local/bin/build.sh"]
CMD ["1.4.0"]
