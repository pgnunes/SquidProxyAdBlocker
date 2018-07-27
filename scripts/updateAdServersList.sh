#!/bin/bash

#####################################
# From yoyo.org
adServersListRegex="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=squid-dstdom-regex&showintro=0&startdate%5Bday%5D=01&startdate%5Bmonth%5D=01&startdate%5Byear%5D=2017&mimetype=plaintext"
adserverslistRegexfile="/etc/squid/adServersListyoyo.txt"

printf "Downloading Ad Servers list: yoyo.org... "
curl -sSL "$adServersListRegex" > $adserverslistRegexfile && printf "Done.\n\n"


#####################################
# From StevenBlack
adServersList="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
adserverslistfile="/etc/squid/adServersListStevenBlack.txt"

printf "Downloading Ad Servers list: StevenBlack... "
curl -sSL "$adServersList" > $adserverslistfile && printf "Done.\n\n"

# remove squid invalid entries
sed -i '/#/d' $adserverslistfile
sed -i '/127.0.0.1\ /d' $adserverslistfile
sed -i '/f/d' $adserverslistfile
sed -i '/255/d' $adserverslistfile
sed -i '/::1/d' $adserverslistfile

# remove 0.0.0.0
sed -e s/0.0.0.0\ //g -i $adserverslistfile
sed -i '/0.0.0.0/d' $adserverslistfile

# white lines
sed -i '/^[[:space:]]*$/d' $adserverslistfile



#####################################
# From AdAway
adServersListAdAway="https://adaway.org/hosts.txt"
adserverslistAdAwayfile="/etc/squid/adServersListAdAway.txt"

printf "Downloading Ad Servers list: AdAway... "
curl -sSL "$adServersListAdAway" > $adserverslistAdAwayfile && printf "Done.\n\n"

# remove squid invalid entries
sed -i '/#/d' $adserverslistAdAwayfile
sed -i '/::1/d' $adserverslistAdAwayfile
sed -i '/127.0.0.1\ \ localhost/d' $adserverslistAdAwayfile
sed -e s/127.0.0.1\ //g -i $adserverslistAdAwayfile

# white lines
sed -i '/^[[:space:]]*$/d' $adserverslistAdAwayfile
