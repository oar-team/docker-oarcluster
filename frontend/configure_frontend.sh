#!/bin/bash
set -e

## Configure apache
a2enmod ident
a2enmod headers
a2enmod rewrite

# configure open api
ln -s /etc/oar/apache2/oar-restful-api-priv.conf /etc/apache2/conf.d/oar-restful-api-priv.conf
perl -pi -e "s/Deny from all/#Deny from all/" /etc/oar/apache2/oar-restful-api.conf

## Configure basic auth api
echo "ScriptAlias /oarapi-priv /usr/local/lib/cgi-bin/oarapi/oarapi.cgi
ScriptAlias /oarapi-priv-debug /usr/local/lib/cgi-bin/oarapi/oarapi.cgi

<Location /oarapi-priv>
 Options ExecCGI -MultiViews FollowSymLinks
 AuthType      basic
 AuthUserfile  /etc/oar/api-users
 AuthName      \"OAR API authentication\"
 Require valid-user
 #RequestHeader set X_REMOTE_IDENT %{REMOTE_USER}e
 RewriteEngine On
 RewriteCond %{REMOTE_USER} (.*)
 RewriteRule .* - [E=MY_REMOTE_IDENT:%1]
 RequestHeader add X-REMOTE_IDENT %{MY_REMOTE_IDENT}e
</Location>
" > /etc/oar/apache2/oar-restful-api-priv.conf
ln -sf /etc/oar/apache2/oar-restful-api-priv.conf /etc/apache2/conf.d/oar-restful-api-priv.conf

htpasswd -b -c /etc/oar/api-users docker docker
htpasswd -b /etc/oar/api-users oar docker

## Visualization tools
sed -e "s/^\(DB_BASE_LOGIN_RO.*\)oar.*/\1oar_ro/" -i /etc/oar/drawgantt.conf
sed -e "s/^\(DB_BASE_PASSWD_RO.*\)oar.*/\1oar_ro/" -i /etc/oar/drawgantt.conf
sed -e 's/^\(username\) ?\=.*/\1 = oar_ro/' -i /etc/oar/monika.conf
sed -e 's/^\(password\) ?\=.*/\1 = oar_ro/' -i /etc/oar/monika.conf

# Edit oar.conf
sed -e 's/^LOG_LEVEL\=\"2\"/LOG_LEVEL\=\"3\"/' -i /etc/oar/oar.conf
sed -e 's/^DB_HOSTNAME\=\"localhost\"/DB_HOSTNAME\=\"server\"/' -i /etc/oar/oar.conf
sed -e 's/^SERVER_HOSTNAME\=\"localhost\"/SERVER_HOSTNAME\=\"server\"/' -i /etc/oar/oar.conf
sed -e 's/^#\(TAKTUK_CMD\=\"\/usr\/bin\/taktuk \-t 30 \-s\".*\)/\1/' -i /etc/oar/oar.conf
sed -e 's/^#\(PINGCHECKER_TAKTUK_ARG_COMMAND\=\"broadcast exec timeout 5 kill 9 \[ true \]\".*\)/\1/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_TYPE\)=.*/\1="Pg"/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_PORT\)=.*/\1="5432"/' -i /etc/oar/oar.conf

sed -e 's/^#\(CPUSET_PATH\=\"\/oar\".*\)/\1/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_BASE_PASSWD\)=.*/\1="oar"/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_BASE_LOGIN\)=.*/\1="oar"/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_BASE_PASSWD_RO\)=.*/\1="oar_ro"/' -i /etc/oar/oar.conf
sed -e 's/^\(DB_BASE_LOGIN_RO\)=.*/\1="oar_ro"/' -i /etc/oar/oar.conf