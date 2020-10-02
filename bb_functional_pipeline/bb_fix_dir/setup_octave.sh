#!/bin/bash

# Script to install all pre-requisite Octave libraries

platform=$(uname -s)
yes=$1
global=$2
opt_str=":y:g"
GLOBAL=''
yes=''

pkgmgrs[0]=exit
pkgmgrs[1]=yum
pkgmgrs[2]=apt-get

findpkg[0]=exit
findpkg[1]="yum search"
findpkg[2]="apt-cache search"

chkpkg[0]=exit
chkpkg[1]="rpm -q"
chkpkg[2]="dpkg -l"
	
which_linux_pkmgr() {
	which yum > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		which apt-get > /dev/null 2>&1
		if [ $? -eq 1 ]; then
			echo "Unsupported Linux OS"
			exit 2
		else
			return 2
		fi
	else
		return 1
	fi
}

find_linux_package() {
	packname=$1
	which_linux_pkmgr
	pkgmgr=$?
 ${findpkg[${pkgmgr}]} ${packname} > /dev/null 2>&1
	return $?
}

check_linux_package() {
	packname=$1
	which_linux_pkmgr
	pkgmgr=$?
${findpkg[${pkgmgr}]} ${packname} > /dev/null 2>&1
	return $?
}

install_linux_package() {
	packname=$1
	y=$2
	which_linux_pkmgr
	pkgmgr=$?
	install_command=${pkgmgrs[${pkgmgr}]}
sudo ${install_command} install ${y} ${packname}
}
	
while getopts ${opt_str} opt
do
	case $opt in
	y)
		yes = "-y"
		;;
	g)
		GLOBAL='-global'
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		usage
		;;
	esac
done

if [ "${platform}" = "Darwin" ]; then
	if [ ! -d "/opt/local" ]; then
		echo "MacPorts not found. Please install from http://www.macports.org"
		exit 1
	fi
	which port >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "Unable to find MacPorts 'port' command, is /opt/local/bin in your PATH?"
		exit 1
	fi
	which octave >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "Installing Octave-devel \(3.6\) from MacPorts"
		port install octave-devel
	fi	

elif [ "${platform}" = "Linux" ]; then
	which octave >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		install_linux_package octave
	fi
else
	echo "Unrecognised platform"
	exit 1
fi

OC_PACKS="io statistics specfun general control signal"
OC_SPACKS="miscellaneous-1.0.11 statistics-1.1.3 control-2.2.5 signal-1.1.2"
OC_INSTALL_CMD="pkg install ${GLOBAL} -auto -forge io; pkg install ${GLOBAL} -auto -forge statistics; \
pkg install ${GLOBAL} -auto -forge specfun; pkg install ${GLOBAL} -auto -forge general; \
pkg install ${GLOBAL} -auto -forge control; pkg install ${GLOBAL} -auto -forge signal;"
# Now install some packages
OCVER=$(octave -v | head -1 | awk '{ print $4 }' | cut -d '.' -f 1,2)
if [ "${OCVER}" = "3.2" ]; then
	echo "Unsupported version of Octave - if you are using MacPorts, please uninstall octave \(sudo port uninstall octave\) and re-run this script"
	exit 2
fi

if [ "${platform}" = "Linux" ]; then
	which_linux_pkmgr
	if [ $? -eq 2 ]; then
		packlist=""
		for pack in ${OC_PACKS}; do
			packlist="${packlist} octave-${pack}"
		done
		install_linux_package ${yes} ${packlist}
		OC_INSTALL_CMD=""
	else
		check_linux_package octave-devel
		if [ $? -eq 1 ]; then
			install_linux_package ${yes} octave-devel
		fi
		if [ "${OCVER}" = "3.4" ]; then
			echo "Old version of Octave, getting add-on packages"
			mkdir /tmp/$$_octave_fix_setup
			cd /tmp/$$_octave_fix_setup
			for package in ${OC_SPACKS}; do
				wget http://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/${package}.tar.gz
				if [ $? -eq 1 ]; then
					echo "Unable to download a required package!"
					exit 2
				fi
			done
			OC_INSTALL_CMD="pkg install ${GLOBAL} -auto -forge io; \
pkg install ${GLOBAL} -auto /tmp/$$_octave_fix_setup/miscellaneous-1.0.11.tar.gz; \
pkg install ${GLOBAL} -auto /tmp/$$_octave_fix_setup/statistics-1.1.3.tar.gz; \
pkg install ${GLOBAL} -auto -forge specfun; pkg install ${GLOBAL} -auto -forge general; \
pkg install ${GLOBAL} -auto /tmp/$$_octave_fix_setup/control-2.2.5.tar.gz; \
pkg install ${GLOBAL} -auto -forge struct; pkg install ${GLOBAL} -auto -forge optim; \
pkg install ${GLOBAL} -auto /tmp/$$_octave_fix_setup/signal-1.1.2.tar.gz;"
		fi
	fi
fi
if [ ! -z "${OC_INSTALL_CMD}" ]; then
	if [ ! -z "${GLOBAL}" ]; then
		OC_CMD="sudo octave"
	else
		OC_CMD="octave"
	fi
	${OC_CMD} --eval "${OC_INSTALL_CMD}"
fi
