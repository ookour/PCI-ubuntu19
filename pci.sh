#!/bin/bash

echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf



#apt-get install -y aide
#aideinit -y



echo "* hard core 0" >> /etc/security/limits.conf
cp templates/sysctl-CIS.conf /etc/sysctl.conf
sysctl -e -p



cat templates/motd-CIS > /etc/motd
cat templates/motd-CIS > /etc/issue
cat templates/motd-CIS > /etc/issue.net




apt-get remove telnet



sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/g' /etc/default/grub
update-grub





echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf

sh templates/iptables-CIS.sh
cp templates/iptables-CIS.sh /etc/init.d/
chmod +x /etc/init.d/iptables-CIS.sh
ln -s /etc/init.d/iptables-CIS.sh /etc/rc2.d/S99iptables-CIS.sh

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




touch /etc/cron.allow
touch /etc/at.allow




cp templates/common-passwd-CIS /etc/pam.d/common-passwd
cp templates/pwquality-CIS.conf /etc/security/pwquality.conf
cp templates/common-auth-CIS /etc/pam.d/common-auth


cp templates/login.defs-CIS /etc/login.defs


useradd -D -f 30

usermod -g 0 root

#sed -i s/umask\ 022/umask\ 027/g /etc/init.d/rc



## 
cp templates/sshd_config-CIS /etc/ssh/sshd_config

