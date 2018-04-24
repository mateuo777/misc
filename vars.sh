#definition of variables:

re='^[0-9]'
args=$@

if [[ ! $@ =~ $re ]]; then
	printf "\nArgs are not numbers."
	printf " They are:\n\n"

	for i in ${args[@]}
	do
		echo $i
	done
	printf "\n"
else
	printf "\nArgs are all numbers and I will increment them by 1.\n"
	printf "Now our args are:\n\n"

        for i in ${args[@]}
	do 
		echo $i
        done

	printf "\nAfter incrementation:\n\n"

	for i in ${args[@]}
	do
		i=$((i+1))
		echo $i
	done
	printf "\n"
fi
