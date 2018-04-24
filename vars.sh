#definition of variables:

re1='[0-9]'
re2='[a-z]'
re3='[A-Z]'
args=$@

if [[ $@ =~ $re1 ]] && [[ $@ =~ $re2 ]] || [[ $@ =~ $re3 ]]; then

	printf "You are not allowed to mix the arg types, enter either only integers or strings\n"
	exit 1

elif [[ ! $@ =~ $re1 ]]; then
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
