FROM alpine:3.20

LABEL maintainer="Bonitoo <ops@bonitoo.io>"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp
EXPOSE 1194/tcp

CMD ["ovpn_run"]

COPY ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

COPY ./otp/openvpn /etc/pam.d/

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD pgrep openvpn > /dev/null || exit 1
