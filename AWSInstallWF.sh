#/bin/ksh

AWSuser=dbald
Repo=/appl

mkdir $Repo
chmod 775 $Repo
mv /home/$AWSuser/*.tar $Repo
mv /home/$AWSuser/*.cer $Repo
mv /home/$AWSuser/cron* $Repo
mv /home/$AWSuser/profile $Repo
mv /home/$AWSuser/admin_users $Repo

mv /etc/profile /etc/profile.original
\cp $Repo/profile /etc/profile
\cp $Repo/admin_users /etc/admin_users

# Create Service Groups
echo "Create Service Groups"
groupadd -g 501 jboss
groupadd -g 502 apacheadmin
groupadd -g 503 confgmgt
groupadd -g 504 appdeploy

# Create Service Account UIDs
echo "Create Service Account UIDs"
##########################################################
# Get correct UIDs
##########################################################
useradd jboss -u 501 -g jboss -G confgmgt,appdeploy
useradd apacheadmin -u 502 -g apacheadmin -G confgmgt,appdeploy
useradd confgmgt -u 503 -g confgmgt
useradd appdeploy -u 504 -g appdeploy

# Set passwords for service accounts
echo "Set passwords for service accounts"
#sed -i 's~^jboss:.*$~jboss:$1$MkpERtbn$JbRryyONqTguFhG9//tZ7/:16360:0:99999:7:::~' /etc/shadow
#sed -i 's~^apacheadmin:.*$~apacheadmin:$1$p9sKmL4e$vdYpqJv/UWZLAs0ogFEQN1:16360:0:99999:7:::~' /etc/shadow
sed -i 's~^confgmgt:.*$~confgmgt:$6$2DV6tfX6$BbTINz55hpkeYHREb7AO5i1hIylO8fdKEDdalCTHNoPeKgzGVY37DEY9npAOaOSflcItDpQE72W9k886TLCKE0:15768:0:99999:7:::~' /etc/shadow

# Set Service Accounts to not expire
echo "Set Service Accounts to not expire"
chage -I -1 -m 0 -M 99999 -E -1 jboss
chage -I -1 -m 0 -M 99999 -E -1 apacheadmin
chage -I -1 -m 0 -M 99999 -E -1 confgmgt
chage -I -1 -m 0 -M 99999 -E -1 appdeploy

# Change Ownership of Repo
chmod jboss:jboss $Repo

# Modify kernel tuning parameters
echo "Modify kernel tuning parameters"
cat >> /etc/security/limits.conf <<- ++EndInput
        jboss           soft    nproc             409664
        jboss           hard    nproc             409664
        jboss           soft    nofile            8192
        jboss           hard    nofile            8192
        apacheadmin     soft    nofile            8192
        apacheadmin     hard    nofile            8192
        apacheadmin     soft    nproc             409664
        apacheadmin     hard    nproc             409664
++EndInput

# Create Sudoers entries for EWTS Team
echo "Create Sudoers entries for EWTS Team"
cat > /etc/sudoers.d/EWTS << ++EndInput
###  JBOSS SECTION  ############################
Cmnd_Alias  EWTS=/bin/su - jboss,                               \\
                  /bin/su - apacheadmin,                        \\
                  /bin/su - tomcat,                             \\
                  /bin/su - appdeploy,                          \\
                  /bin/su - redisadm,                           \\
                  /appl/apache/bin/apachectl-1180,              \\
                  /appl/apache/bin/apachectl-1181,              \\
                  /appl/apache/bin/apachectl-1182,              \\
                  /appl/apache/bin/apachectl-1183,              \\
                  /appl/apache/bin/apachectl-1184,              \\
                  /appl/apache/bin/apachectl-1185,              \\
                  /appl/apache/bin/apachectl-1186,              \\
                  /appl/apache/bin/apachectl-1187,              \\
                  /appl/apache/bin/apachectl-1188,              \\
                  /appl/apache/bin/apachectl-1189,              \\
                  /appl/apache/bin/apachectl-1443,              \\
                  /appl/apache/bin/apachectl-1444,              \\
                  /appl/apache/bin/apachectl-1445,              \\
                  /appl/apache/bin/apachectl-1446,              \\
                  /appl/apache/bin/apachectl-1447,              \\
                  /appl/apache/bin/apachectl-1448,              \\
                  /appl/apache/bin/apachectl-1449,              \\
                  /appl/apache/bin/apachectl-1450,              \\
                  /appl/apache/bin/apachectl-1451,              \\
                  /appl/apache/bin/apachectl-1452,              \\
                  /appl/apache/bin/apachectl-80,                \\
                  /appl/apache/bin/apachectl-443,               \\
                  /appl/apache/bin/apachectl-2300-analog,       \\
                  /usr/bin/dsmj,                                \\
                  /bin/more /var/log/messages*,                 \\
                  /bin/more /etc/sudoers.d/EWTS,                \\
                  /usr/openv/netbackup/bin/bp,                  \\
                  /home/jboss/scripts/createAppInstanceWildFly_8.2, \\
                  /home/jboss/scripts/createAppInstanceStandard_ce.7.2, \\
                  /bin/rpm -ivh /home/jboss/jdk*,               \\
                  /bin/chown jboss\:jboss -R /usr/java/jdk*,    \\
                  /bin/rm -f /usr/local/jdk*,                   \\
                  /bin/ln -s /usr/java/* jdk*,                  \\
                  /usr/bin/yum clean all,                       \\
                  /usr/bin/yum erase jdk*


Cmnd_Alias JVMCMDS=/appl/software/wildfly*/bin/jboss_init*,     \\
                    /appl/software/wildfly*/bin/jb_tdump,       \\
                    /appl/software/wildfly*/bin/jb_hdump,       \\
                    /appl/software/wildfly*/bin/deploy*,        \\
                    /usr/local/jboss7.2/bin/jboss_init*,        \\
                    /usr/local/jboss7.2/bin/jb_tdump,           \\
                    /usr/local/jboss7.2/bin/jb_hdump,           \\
                    /usr/local/jboss7.2/bin/deploy*

Cmnd_Alias JSSCMDS=/appl/apache/bin/apachectl-1180,     \\
                  /appl/apache/bin/apachectl-1181,      \\
                  /appl/apache/bin/apachectl-1182,      \\
                  /appl/apache/bin/apachectl-1183,      \\
                  /appl/apache/bin/apachectl-1184,      \\
                  /appl/apache/bin/apachectl-1185,      \\
                  /appl/apache/bin/apachectl-1186,      \\
                  /appl/apache/bin/apachectl-1187,      \\
                  /appl/apache/bin/apachectl-1188,      \\
                  /appl/apache/bin/apachectl-1189,      \\
                  /appl/apache/bin/apachectl-1443,      \\
                  /appl/apache/bin/apachectl-1444,      \\
                  /appl/apache/bin/apachectl-1445,      \\
                  /appl/apache/bin/apachectl-1446,      \\
                  /appl/apache/bin/apachectl-1447,      \\
                  /appl/apache/bin/apachectl-1448,      \\
                  /appl/apache/bin/apachectl-1449,      \\
                  /appl/apache/bin/apachectl-1450,      \\
                  /appl/apache/bin/apachectl-1451,      \\
                  /appl/apache/bin/apachectl-1452,      \\
                  /appl/apache/bin/apachectl-80,        \\
                  /appl/apache/bin/apachectl-443,       \\
                  /appl/software/scripts/selfservice

+ewts-users ALL=(root) NOPASSWD: EWTS
+ewts-users ALL=(jboss) NOPASSWD: JVMCMDS
%jboss ALL=(root) NOPASSWD: EWTS
%jboss ALL=(jboss) NOPASSWD: JVMCMDS
%apacheadmin ALL=(root) NOPASSWD: EWTS
%appdeploy ALL=(jboss) NOPASSWD: /appl/software/wildfly*/bin/deploy* 
### %<fill in app ldap group here and uncomment> ALL=(jboss) NOPASSWD: JVMCMDS
### %<fill in app ldap group here and uncomment> ALL=(root) NOPASSWD: JSSCMDS

Defaults:svc-snmid !requiretty
svc-snmid  ALL=(jboss)NOPASSWD:/appl/esm/clip.sh
%nagios ALL=(jboss) NOPASSWD:/appl/software/wildfly*/bin/jboss-cli.sh,  \\
        /usr/local/jboss7.2/bin/jboss-cli.sh
###  END JBOSS SECTION  ############################
++EndInput

chmod 0440 /etc/sudoers.d/EWTS

yum install -y httpd
yum install -y libc.so.6
yum install -y libdl.so.2
yum install -y jemalloc
yum install -y libjemalloc.so.1
yum install -y libm.so.6
yum install -y libpthread.so.0
#yum install -y logrotate
yum install -y rpmlib

echo "Install ssl"
yum install -y mod_ssl.x86_64
# Expand out software tarball
echo "Expand out software tarball"
cd /appl
tar xf ${Repo}/software.tar
#tar xf ../../repo/jboss/software.tar

# Expand out jdk1.8 tarball
echo "Expand out jdk1.8 tarball"
cd /tmp
tar xf ${Repo}/jdk1.8.0.121.tar
rpm -ivh /tmp/jdk-8u121-linux-x64.rpm
\cp  -r /tmp/cacerts /usr/java/jdk1.8.0_121/jre/lib/security/
rm -f /tmp/jdk-8u121-linux-x64.rpm
rm -f /tmp/cacerts
cd /usr/java/jdk1.8.0_121/jre/lib/security/
mv local_policy.jar local_policy.jar.original
mv US_export_policy.jar US_export_policy.jar.original
mv /tmp/local_policy.jar /usr/java/jdk1.8.0_121/jre/lib/security/
mv /tmp/US_export_policy.jar /usr/java/jdk1.8.0_121/jre/lib/security/

# Set permissions/ownership on directories/files.
echo "Set permissions/ownership on directories/files"
chown -R jboss:jboss /usr/java

echo "Populate JBOSS home directory"
cd /home
tar xf ${Repo}/jbosshome.tar

echo "Populate APACHEADMIN home directory"
cd /home
tar xf ${Repo}/apacheadminhome.tar

echo "Populate APPDEPLOY home directory"
cd /home
tar xf ${Repo}/appdeployhome.tar

# Create script to copy files for ewts team.
#echo "Create script to copy files for ewts team"
#cat > /usr/local/sbin/EWTS.sudoers << ++EndInput
#    mkdir -p /home/jboss/cfg
#    cp /etc/sudoers.d/EWTS /home/jboss/cfg/sudoers.EWTS
#    chown jboss:jboss /home/jboss/cfg/sudoers.EWTS
#    chmod 400 /home/jboss/cfg/sudoers.EWTS
#++EndInput
#chmod 700 /usr/local/sbin/EWTS.sudoers

#cat >> /var/spool/cron/root <<- ++EndInput
#       1 18 * * 5 /usr/local/sbin/EWTS.sudoers
#++EndInput

# Set up Cron Jobs
echo "Set up Cron Jobs"
crontab -u apacheadmin ${Repo}/cronapacheadmin
crontab -u jboss       ${Repo}/cronjboss

#Setup Init Scripts (assumes Centos 7)
echo "Setup Init Scripts"
cp /appl/software/init/wildfly.service /usr/lib/systemd/system/
cp /appl/software/init/apache.service  /usr/lib/systemd/system/
cd /usr/lib/systemd/system
systemctl enable wildfly.service
systemctl enable apache.service

