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

#TODO: install/configure
# required

# optional

# const/reserved

#==============================================================================
# Option
#==============================================================================

#TODO: install/configure

declare -i argc=0

short_opts="h:v"

usage() {
	echo -e "$0 [pos args] <option>"
	echo -e "usage\n"
	echo -e "positional args:"
	echo -e "optional args    :"
	echo -e "  -h | --help    : show usage"
	echo -e "  -v | --verbose : enable verbosity messages"
	echo -e "  --version      : show version"
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
	*   ) pr_warn "Found invalid short opt in $OPT";;
	esac
	done
	shift
;;
# postional args
* )
	case "$argc" in
	"0" )
	;;
	*   ) pr_warn "Found invalid args $OPT";;
	esac
	((argc++))
	shift
;;
esac
done

# validation required variables
#TODO

#==============================================================================
# Main Procedure
#==============================================================================

#TODO
