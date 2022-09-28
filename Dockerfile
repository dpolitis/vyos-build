FROM vyos/vyos-build:equuleus

# Install various dependancies for OVA build
ARG DISPLAY=':0'
ADD misc/ovftool.bundle /tmp/ovftool.bundle
RUN chmod +x /tmp/ovftool.bundle

RUN apt-get update && apt-get install -y \
    libncursesw5 \
    parted \
    udev \
    kpartx
RUN /tmp/ovftool.bundle --eulas-agreed --console --required

# Create X509 Certificate for image sign
ENV PRIVATE_KEY_PATH /root/builder.pem
RUN cd /tmp; \
    openssl req -nodes -newkey rsa:2048 -keyout builder.key \
    -out builder.csr \
    -subj "/C=GR/ST=Attica/L=Athens/O=Acme Corp./OU=IT Dept./CN=acmecorp.gr"; \
    openssl x509 -req -days 730 -in builder.csr -signkey builder.key -out builder.crt; \
    cat builder.crt builder.key >> $PRIVATE_KEY_PATH


COPY build.sh /usr/local/bin/build.sh
RUN chmod +x /usr/local/bin/build.sh

WORKDIR /vyos

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/usr/local/bin/build.sh"]
CMD ["1.3.2"]
