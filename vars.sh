#definition of variables and functions:

re1='[0-9]'
re2='[a-z]'
re3='[A-Z]'
args=$@

error() {
	printf "You are not allowed to mix the arg types, enter either only integers or strings\n"
	exit 1
}

iter() {
	for i in ${args[@]}
	do
		echo $i
	done
}

iter2() {
	for i in ${args[@]}
	do
		i=$((i+1))
		echo $i
	done
}

if [[ $@ =~ $re1 ]] && [[ $@ =~ $re2 ]] || [[ $@ =~ $re3 ]]; then
	error

elif [[ ! $@ =~ $re1 ]]; then
	printf "\nArgs are not numbers."
	printf " They are:\n\n"
        iter
	printf "\n"
else
	printf "\nArgs are all numbers and I will increment them by 1.\n"
	printf "Now our args are:\n\n"
        iter
	printf "\nAfter incrementation:\n\n"
        iter2
	printf "\n"
fi
