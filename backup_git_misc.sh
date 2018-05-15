#!/bin/bash

cd /home/mateuo/scripts/misc
git add *

to_remove=$(git status | grep "deleted" | awk '{print $2}')

if [[ -n $to_remove ]]; then
    git rm --ignore-unmatch $to_remove 2>/dev/null 2>&1
fi

git commit -m "Automated commit for misc powered by cron"
git push -u origin master
