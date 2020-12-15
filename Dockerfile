FROM debian:stable
LABEL maintainer="Pedro Nunes <pgh.nunes@gmail.com>"

ENV CONF_FILE=/etc/squid/squid.conf

# Update system and install squid
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y squid nano curl cron && \
    apt-get -y autoremove --purge && \
    apt-get clean

# Script to download/update ad servers list
COPY scripts/* /

# Configure squid networks
RUN sed -i '1iacl localnet src 10.0.0.0/8     # RFC1918 possible internal network' $CONF_FILE && \
    sed -i '1iacl localnet src 172.16.0.0/12  # RFC1918 possible internal network' $CONF_FILE && \
    sed -i '1iacl localnet src 192.168.0.0/16 # RFC1918 possible internal network' $CONF_FILE && \
    sed -i '1iacl localnet src fc00::/7       # RFC 4193 local private network range' $CONF_FILE && \
    sed -i '1iacl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines' $CONF_FILE && \
    sed -i "/#http_access allow localnet/c\http_access allow localnet" $CONF_FILE

# Configure squid to block ad servers
RUN sed -i '1ihttp_access deny yoyo' $CONF_FILE && \
    sed -i '1ihttp_access deny StevenBlack' $CONF_FILE && \
    sed -i '1ihttp_access deny AdAway' $CONF_FILE && \
    sed -i '1iacl yoyo dstdom_regex "/etc/squid/adServersListyoyo.txt"' $CONF_FILE && \
    sed -i '1iacl StevenBlack dstdomain "/etc/squid/adServersListStevenBlack.txt"' $CONF_FILE && \
    sed -i '1iacl AdAway dstdomain "/etc/squid/adServersListAdAway.txt"' $CONF_FILE

# Misc conf.
RUN sed -i '1ihttp_port 3129 transparent' $CONF_FILE

# Proxy port
EXPOSE 3128 3129

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
