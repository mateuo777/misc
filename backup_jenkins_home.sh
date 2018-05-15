cd $JENKINS_HOME

git add -- jobs/*

if [[ -d users ]]; then
    user_config_files=$(ls users/*/config.xml)

    if [[ -n $user_config_files ]]; then
        git add $user_config_files
    fi
fi

to_remove=$(git status | grep "deleted" | awk '{print $2}')

if [[ -n $to_remove ]]; then
    git rm --ignore-unmatch $to_remove
fi

git commit -m "Automated Jenkins commit for specified JENKINS_HOME content"

git push -q -u origin master
