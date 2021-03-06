#!/bin/sh
#
# check script. Assumes that pyang is on path and that
# all standard modules are on its internal module path.
# Also assumes that the script is run from the root of the yang master.
#
ieee_dir="standard/ieee"
to_check="draft/802 draft/802.1 draft/802.1/ABcu draft/802.1/AEdk draft/802.1/CBcv draft/802.1/CBdb draft/802.1/Qcw draft/802.1/QRev draft/802.1/Qcz draft/802.3 published/1906.1 published/802 published/802.1"

checkDir () 
{
    local dir="$ieee_dir/$1"

    echo Checking yang files in $dir
    exit_status=""
    pyang_flags="--verbose -p . -p $cwd/$ieee_dir/../ietf/RFC/ -p $cwd/$ieee_dir/published/802 -p $cwd/$ieee_dir/published/802.1"

    cd $dir

    if [ -f "./check_pyang_extra_flags" ]; then
        check_pyang_extra_flags=`cat ./check_pyang_extra_flags`
        pyang_flags="$pyang_flags $check_pyang_extra_flags"
    fi
    printf "\n"
    for f in *.yang; do
        printf "pyang $pyang_flags $f\n"
#        `pyang $pyang_flags $f`
        errors=`pyang $pyang_flags $f 2>&1 | grep "error:"`
        if [ ! -z "$errors" ]; then
        	echo Errors in $f
        	printf "\n  $errors \n"
        	exit_status="failed!"
        fi
    done
    if [ ! -z "$exit_status" ]; then
    	exit 1
    fi
    cd $cwd
}

echo Checking modules with pyang command:
cwd=`pwd`
for d in $to_check; do
    printf "\n Checking modules with pyang in $d : \n"
    checkDir $d
done
