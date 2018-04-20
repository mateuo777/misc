#variables:

names=$@

for i in ${names[@]}
do
	echo Variable $i is: $i
	
done

echo variable 1 is: $1 and variable 3 is: $3
