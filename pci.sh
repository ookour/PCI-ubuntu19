#!/bin/bash
:'
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf


debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y postfix
apt-get install -y aide
aideinit -y



echo "* hard core 0" >> /etc/security/limits.conf
cp templates/sysctl-CIS.conf /etc/sysctl.conf
sysctl -e -p

sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.route.flush=1


sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.route.flush=1

sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
sysctl -w net.ipv6.route.flush=1



chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

cat templates/motd-CIS > /etc/motd
cat templates/motd-CIS > /etc/issue
cat templates/motd-CIS > /etc/issue.net




apt-get remove -y telnet



sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/g' /etc/default/grub
update-grub





echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf

#sh templates/iptables-CIS.sh
#cp templates/iptables-CIS.sh /etc/init.d/
#chmod +x /etc/init.d/iptables-CIS.sh
#ln -s /etc/init.d/iptables-CIS.sh /etc/rc2.d/S99iptables-CIS.sh

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j DROP

iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

apt-get install -y auditd

cp templates/auditd-CIS.conf /etc/audit/auditd.conf

systemctl enable auditd


sed -i 's/GRUB_CMDLINE_LINUX="ipv6.disable=1"/GRUB_CMDLINE_LINUX="ipv6.disable=1\ audit=1"/g' /etc/default/grub



cp templates/audit-CIS.rules /etc/audit/audit.rules

find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \
"-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \
-k privileged" } ' >> /etc/audit/audit.rules

echo " " >> /etc/audit/audit.rules
echo "#End of Audit Rules" >> /etc/audit/audit.rules
echo "-e 2" >>/etc/audit/audit.rules

cp /etc/audit/audit.rules /etc/audit/rules.d/audit.rules

chmod -R g-wx,o-rwx /var/log/*


rm /etc/cron.deny
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow


chown root:root /etc/crontab
chmod og-rwx /etc/crontab

chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly


chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly


chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

cp templates/common-passwd-CIS /etc/pam.d/common-passwd
cp templates/pwquality-CIS.conf /etc/security/pwquality.conf
cp templates/common-auth-CIS /etc/pam.d/common-auth


cp templates/login.defs-CIS /etc/login.defs


useradd -D -f 30

usermod -g 0 root

#sed -i s/umask\ 022/umask\ 027/g /etc/init.d/rc



## 
cp templates/sshd_config-CIS /etc/ssh/sshd_config


chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config


echo "password requisite pam_pwquality.so retry=3" >> /etc/pam.d/common-password
echo "password required pam_pwhistory.so remember=5" >> /etc/pam.d/common-password

echo "umask 027" >> /etc/bash.bashrc
echo "umask 027" >> /etc/profile'
mount -o remount,noexec /dev/shm
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg
sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/g' /etc/postfix/main.cf
apt-get remove telnet
