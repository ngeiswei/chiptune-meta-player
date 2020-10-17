while :
do
    asapconv -o -.wav "$@" | aplay -
done
