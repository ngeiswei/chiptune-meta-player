while :
do
    asapconv -o -.wav "$@" | aplay -
    if [[ "$?" != 0 ]]; then
	exit 1
    fi
done
