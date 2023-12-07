set -e
DAY_NUM=${1:-03}
DAY=day$DAY_NUM

echo Assembling $DAY...
echo
cl65 --target sim6502 $DAY.s printdig.s htd.s

echo Running inputs...
echo
for f in inputs/$DAY_NUM/* ; do
	echo $f:
	sim65 $DAY < $f
	echo
done

set -x
rm $DAY
