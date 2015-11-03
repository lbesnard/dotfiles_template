#/bin/bash
#-- Script to automate https://help.github.com/articles/why-is-git-always-asking-for-my-password
# modified from https://gist.github.com/m14t/3056747
# requires ~/.ssh/id_rsa

declare USER=lbesnard
declare GIT_REPO=$GITHUB_DIR
declare GIT_SERVER=https://github.com

get_repo_url() {
    local HTTPS_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`

    if [ -z "$HTTPS_URL" ]; then
      return 1
    fi
    echo $HTTPS_URL
}


convert_repo_https_to_ssh() {
    local HTTPS_URL=get_repo_url
    local REPO_NAME=`echo $HTTPS_URL | sed -Ene's#$GIT_SERVER/([^/]*)/(.*)#\2#p'`

    if [ -n "$REPO_NAME" ]; then
        _convert_repo_https_to_ssh $REPO_NAME
    else
       REPO_NAME=`pwd | sed  -e "s/.*\///g"`
        _convert_repo_https_to_ssh $REPO_NAME
    fi
}

_convert_repo_https_to_ssh () {
    local REPO_NAME=$1; shift
    local SSH_URL

    SSH_URL="git@github.com:$USER/$REPO_NAME.git"
    git remote set-url origin $SSH_URL
    echo "Changing repo url from HTTPS to " $SSH_URL
}

main() {
    if [ ! -z "$GIT_REPO" ]; then
        for git_dir in `find $GIT_REPO/ -maxdepth 1 -type d`; do
            cd $git_dir
            convert_repo_https_to_ssh
        done
    else
        echo 'GITHUB_DIR env is not defined'
    fi
}

main "$@"
