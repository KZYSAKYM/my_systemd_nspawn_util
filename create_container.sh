#!/usr/bin/env bash

#==============================================================================
# Utility
#==============================================================================

DIR=$(dirname $(readlink -f $0))
LOG_LEVEL=3
VERSION="0.0.1"

recho() { echo -e "\e[31m${@}\e[m" ;}

yecho() { echo -e "\e[33m${@}\e[m" ;}

gecho() { echo -e "\e[32m${@}\e[m" ;}

becho() { echo -e "\e[34m${@}\e[m" ;}

pr_err() {
	(( $LOG_LEVEL > 1 )) || return 0
	recho "[ERROR] $@"
}

pr_warn() {
	(( $LOG_LEVEL > 2 )) || return 0
	yecho "[WARNING] $@"
}

pr_info() {
	(( $LOG_LEVEL > 6 )) || return 0
	echo -e "[NOTICE] $@"
}

err_exit() { pr_err $@; exit -1; }

uerr_exit() { pr_err $@; usage; }

# to exec alias
shopt -s expand_aliases
# is_dir <dir> || error procedure
alias is_dir='test -d'
# is_file <file> || error procedure
alias is_file='test -f'
# is_exit <file/dir> || error procedure
alias is_exit='test -e'

is_set() {
	# is_set <target var> || error procedure
	ret=0
	[ "`echo $1`" ] || ret=-1
	return $ret
}

is_in() {
	# is_in <target> <list> || error procedure
	ret=-1
	for i in `echo $2`; do
		[ "$1" = "$i" ] && ret=0
	done
	return $ret
}

sp() {
	# sp <delimitor> <target>
	echo $2 | tr "$1" " "
}

#==============================================================================
# Flag/Variable
#==============================================================================

# required
DEST_DIR="/var/lib/machines"
IMAGE_NAME=""

# optional
IS_RUN=false

# const/reserved
IMAGE_NAMES="`cat <<END
ubuntu
ubuntu16
ubuntu18
END
`"
DIST_TAG=""
IMAGE_DIR=""

#==============================================================================
# Option
#==============================================================================

declare -i argc=0

short_opts="h:v:d:r:i"

usage() {
	echo -e "$0 [image] <option>"
	echo -e "install image for systemd-nspawn image\n"
	echo -e "positional args:"
	echo -e "  image          : base image for container"
	echo -e "      ubuntu     : ubuntu server 18.04"
	echo -e "      ubuntu16   : ubuntu server 16.04"
	echo -e "optional args    :"
	echo -e "  -h | --help    : show usage"
	echo -e "  -v | --verbose : enable verbosity messages"
	echo -e "  --version      : show version"
	echo -e "  -d | --dest_dir: specify destination for image installed"
	echo -e "  -r | --run     : Run initial setup for container"
	exit 1
}

while (( $# > 0 ))
do
OPT="$1"
case "$OPT" in
# long options
--* )
	case "$OPT" in
	"--help" )
		usage
	;;
	"--version")
		echo "VERSION: $VERSION"
		exit 1
	;;
	"--verbose" )
		LOG_LEVEL=7
		pr_info "Specify verbose"
	;;
	"--dest_dir" )
		is_dir "$2" || [ "`mkdir "$2" && pr_info "create $2"`" ]
		DEST_DIR="$2"
		shift
		pr_info "Specify dest dir $DEST_DIR"
	;;
	"--run" )
		IS_RUN=true
		pr_info "Specify Run mode"
	;;
	*   ) pr_warn "Found invalid long opt $OPT";;
	esac
	shift
;;
# short options
-* )
	# for continuous opts like -devhsg
	for opt in `sp ":" "$short_opts"`; do
	case "$opt" in
	"h" ) [[ $OPT =~ h ]] || continue
		usage
	;;
	"v" ) [[ $OPT =~ v ]] || continue
		LOG_LEVEL=7
		pr_info "Specify verbose"
	;;
	"d" ) [[ $OPT =~ d ]] || continue
		is_dir "$2" || [ "`mkdir "$2" && pr_info "create $2"`" ]
		DEST_DIR="$2"
		shift
		pr_info "Specify dest dir $DEST_DIR"
	;;
	"r" ) [[ $OPT =~ r ]] || continue
		IS_RUN=true
		pr_info "Specify Run mode"
	;;
	*   ) pr_warn "Found invalid short opt in $OPT";;
	esac
	done
	shift
;;
# postional args
* )
	case "$argc" in
	"0" )
		IMAGE_NAME="$OPT"
		becho "create container with image $IMAGE_NAME"
	;;
	*   ) pr_warn "Found invalid args $OPT";;
	esac
	((argc++))
	shift
;;
esac
done

# validation required variables
if is_set "$IMAGE_NAME"; then
	is_in "$IMAGE_NAME" "$IMAGE_NAMES" || \
		uerr_exit "invalid image name $IMAGE_NAME"
else
	uerr_exit "Please specify image name"
fi
is_set "$DEST_DIR" || err_exit "Invalid dest dir is specified"

#==============================================================================
# Main Procedure
#==============================================================================

case "${IMAGE_NAME}" in
"ubuntu" | "ubuntu18" )
	DIST_TAG="bionic"
;;
"ubuntu16" )
	DIST_TAG="xenial"
;;
esac
# prepare image dir
IMAGE_DIR="$DEST_DIR/$DIST_TAG"
is_dir "$IMAGE_DIR" || sudo mkdir "$IMAGE_DIR"

gecho "INSTALL IMAGE $IMAGE_NAME/$DIST_TAG"
gecho "==================================="
sudo debootstrap "$DIST_TAG" "$IMAGE_DIR"
gecho "==================================="
gecho "INSTALLED IMAGE IN $IMAGE_DIR"

if $IS_RUN; then
	gecho "RUN CONTAINER"
	gecho "==================================="
	yecho "Please set your user and password"
	yecho "  # useradd <your user> -G sudo -m"
	yecho "  # passwd <your user>"
	yecho "  # exit"
	yecho "After exit, you can use container"
	yecho "  $ sudo systemd-nspawn -b -D $DEST_DIR"
	yecho "You can detach container console with Ctrl-] ]]"
	sudo systemd-nspawn -D "$DEST_DIR"
fi
