FROM debian:stable
LABEL maintainer="Pedro Nunes <pgh.nunes@gmail.com>"

# Update system and install squid
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y squid3 curl cron && \
    apt-get -y autoremove --purge && \
    apt-get clean

# Script to download/update ad servers list
COPY scripts/* /

# Configure squid networks
RUN sed -i '1iacl localnet src 10.0.0.0/8     # RFC1918 possible internal network' /etc/squid/squid.conf && \
    sed -i '1iacl localnet src 172.16.0.0/12  # RFC1918 possible internal network' /etc/squid/squid.conf && \
    sed -i '1iacl localnet src 192.168.0.0/16 # RFC1918 possible internal network' /etc/squid/squid.conf && \
    sed -i '1iacl localnet src fc00::/7       # RFC 4193 local private network range' /etc/squid/squid.conf && \
    sed -i '1iacl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines' /etc/squid/squid.conf && \
    sed -i "/#http_access allow localnet/c\http_access allow localnet" /etc/squid/squid.conf

# Configure squid to block ad servers
RUN sed -i '1ihttp_access deny yoyo' /etc/squid/squid.conf && \
    sed -i '1ihttp_access deny StevenBlack' /etc/squid/squid.conf && \
    sed -i '1ihttp_access deny AdAway' /etc/squid/squid.conf && \
    sed -i '1iacl yoyo dstdom_regex "/etc/squid/adServersListyoyo.txt"' /etc/squid/squid.conf && \
    sed -i '1iacl StevenBlack dstdomain "/etc/squid/adServersListStevenBlack.txt"' /etc/squid/squid.conf && \
    sed -i '1iacl AdAway dstdomain "/etc/squid/adServersListAdAway.txt"' /etc/squid/squid.conf

# Proxy port
EXPOSE 3128

# Call initd service to ensure folders, settings, etc. are set in place
# CMD ["/usr/sbin/service","squid","start", ";", "/bin/bash","/updateAdServersList.sh"]
# CMD ["/bin/bash","/updateAdServersList.sh"]

# Run Squid in the foreground
#ENTRYPOINT ["/bin/bash","/updateAdServersList.sh", "&", "/usr/sbin/squid", "-N", "-d1"]
ENTRYPOINT ["/entrypoint.sh"]