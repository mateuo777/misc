#definition of variables and functions:

re1='[0-9]'
re2='[a-z]'
re3='[A-Z]'
re4='[^A-Z ^a-z ^0-9]'
args=$@

error() {
	printf "You are not allowed to mix the arg types, enter either only integers or strings\n"
	exit 2
}

error2() {
	printf "Please enter only integers or letters\n"
	exit 2
}

warning() {
	printf "You have to enter at least one argument\n"
	exit 1
}

iter() {
	for arg in ${args[@]}; do
		echo $arg
	done
}

iter2() {
	for arg in ${args[@]}; do
		arg=$((arg+$value))
		echo $arg
	done
}

if [[ $@ =~ $re4 ]]; then
	error2

elif [[ $@ =~ $re1 ]] && [[ $@ =~ $re2 ]]; then
	error

elif [[ $@ =~ $re1 ]] && [[ $@ =~ $re3 ]]; then
	error

elif [[ -z $@ ]]; then
	warning

elif [[ ! $@ =~ $re1 ]]; then
	printf "\nYou've entered $(echo $#) args and they are not numbers."
	printf "They are:\n\n"
        iter
	printf "\n"
else
	printf "\nYou've entered $(echo $#) args and the args are all numbers and I will increment them.\n\n"
	read -p "Enter now a value, that will be used to increment the args (from 1 to 9): " -n 1 -t 10 -e value
	printf "\nNow our args are:\n\n"
        iter
	printf "\nAfter incrementation:\n\n"
        iter2
	printf "\n"
fi
