mkdir /pkgs
cd /pkgs

# Download latest packages needed for slackpkg
wget -nd --recursive --level=1 --accept "gnupg2-*-x86_64-*.txz, libassuan-*-x86_64-*.txz, npth-*-x86_64-*.txz, libksba-*-x86_64-*.txz" https://slackware.uk/slackware/slackware64-current/slackware64/n/

# Download latest slackpkg, slackpkg+, sbopkg, and slackrepo
wget -nd --recursive --level=1 --accept "slackpkg-*-noarch-*.txz" https://slackware.uk/slackware/slackware64-current/slackware64/ap/
wget -nd --recursive --level=1 --accept "slackpkg+-*-noarch-*.txz" https://mirrors.slackware.com/slackware/slackware64-current/extra/slackpkg+/
wget $(wget -qO- https://api.github.com/repos/sbopkg/sbopkg/releases/latest | grep '"browser_download_url":' | cut -d '"' -f 4 | grep 'sbopkg-.*-noarch-.*\.tgz')
wget $(curl -s https://api.github.com/repos/bobbintb/Slackware_Packages/contents/builds/slackrepo | grep -o '"download_url": "[^"]*slackrepo-[^"]*-noarch-[^"]*\.tgz"' | cut -d'"' -f4 | head -n 1)

# install everything and remove the installers
installpkg /pkgs/*
rm -dr /pkgs/

# configure slackpkg
CONF_FILE="/etc/slackpkg/slackpkg.conf"
sed -i "s/^DIALOG=.*/DIALOG=off/" "$CONF_FILE"
sed -i "s/^BATCH=.*/BATCH=on/" "$CONF_FILE"
sed -i "s/^DEFAULT_ANSWER=.*/DEFAULT_ANSWER=y/" "$CONF_FILE"

#sed -i '$s/.*/https:\/\/mirrors\.slackware\.com\/slackware\/slackware64-current\//' /etc/slackpkg/mirrors
echo "https://ftp.osuosl.org/pub/slackware/slackware64-current/" >> /etc/slackpkg/mirrors

# configure slackpkg+
sed -i 's/CACHEUPDATE=off/CACHEUPDATE=on/' /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-multilib-15']=http://slackware.nl/people/alien/multilib/15.0/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-multilib-current']=http://slackware.nl/people/alien/multilib/current/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-15']=https://slackware.nl/people/alien/sbrepos/15.0/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-current']=http://slackware.nl/people/alien/sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-restr-15']=https://slackware.nl/people/alien/restricted_sbrepos/15.0/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-restr-cur']=https://slackware.nl/people/alien/restricted_sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['alien-slackbuilds']=https://slackware.nl/people/alien/slackbuilds/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['conraid-cur']=https://slackers.it/repository/slackware64-current/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['conraid-extra']=https://slackers.it/repository/slackware64-current-extra/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['conraid-testing']=https://slackers.it/repository/slackware64-current-testing/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['csb-15']=https://slackware.uk/csb/15.0/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['csb-cur']=https://slackware.uk/csb/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['msb-15']=https://slackware.uk/msb/15.0/latest/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['msb-cur']=https://slackware.uk/msb/current/latest/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['ponce-current']=https://ponce.cc/slackware/slackware64-current/packages/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['salix-15']=https://download.salixos.org/x86_64/15.0/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['salix-extra-15']=https://download.salixos.org/x86_64/extra-15.0/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['slackel-cur']=http://www.slackel.gr/repo/x86_64/current/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['slackonly-15']=https://packages.slackonly.com/pub/packages/15.0-x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['slackonly-current']=https://packages.slackonly.com/pub/packages/current-x86_64/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['slint']=https://slackware.uk/slint/x86_64/slint-15.0/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['official-15+extra']=https://ftp.osuosl.org/pub/slackware/slackware64-15.0/" >> /etc/slackpkg/slackpkgplus.conf
echo "#MIRRORPLUS['bobbintb']=https://raw.githubusercontent.com/bobbintb/Slackware_Packages/refs/heads/main/builds/" >> /etc/slackpkg/slackpkgplus.conf
slackpkg update <<< y
slackpkg update gpg <<< y

# configure Sbopkg
cd /
sed -i 's/--passphrase-fd 0/--pinentry-mode loopback/' /usr/libexec/slackrepo/gen_repos_files.sh
chmod +x /usr/libexec/slackrepo/gen_repos_files.sh
sbopkg -r

# install python
slackpkg install slackware64:python3 slackware64:python-pip slackware64:pkg-config
slackpkg reinstall slackware64:zlib slackware64:elfutils slackware64:zstd slackware64:glibc slackware64:jemalloc
rm -dr /root/.gnupg/
