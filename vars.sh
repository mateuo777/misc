#variables:

re='^[0-9]'
args=$@

if [[ ! $@ =~ $re ]]; then
        echo Args are not numbers
	echo They are:

	for i in ${args[@]}
	do
		echo $i
	done
else
	echo Args are all numbers 
	echo and I will increment them
        echo Now our args are:

        for i in ${args[@]}
	do 
		echo $i
        done

        echo After incrementation:

	for i in ${args[@]}
	do
		i=$((i+1))
		echo $i
	done
fi
