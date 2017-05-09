#!/bin/sh

# Enable the service
sysrc -f /etc/rc.conf sshd_enable="YES"
sysrc -f /etc/rc.conf crashplan_enable="YES"

cat >> /etc/ssh/sshd_config << EOF
PermitRootLogin yes
PasswordAuthentication yes
AllowTcpForwarding yes
EOF

# Save the config values
export LC_ALL=C
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
PASS=`cat /root/dbpassword`
echo "$PASS" | pw mod user root -h 0

echo "Root Password: $PASS"

# Linux Java is a tad broke, fix it
sed -i '' 's|/usr/bin/cpuset|export LD_LIBRARY_PATH="/usr/local/linux-oracle-jdk1.8.0/jre/lib/i386/jli"; /usr/bin/cpuset|g' \
	/usr/local/etc/rc.d/crashplan

service sshd keygen
service sshd start
service crashplan start
service crashplan start 2>/dev/null >/dev/null
