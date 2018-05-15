#!/bin/bash
LOG="/var/log/deploy.log"
OAUTH_TOKEN="47d868106c79d9962bed7216ff3de1c85cf36ea8"
GIT_API="https://api.github.com"
GIT_API_REPO_MASTER="${GIT_API}/repos/%OWNER%/%REPO%/tarball/master"
GIT_OWNER="sungpil"
GIT_REPO="hyperlog"
WS_ROOT="/home/ubuntu/hyperlog"
log() {
        date=`date`
        echo "$date - $1" >> $LOG
}
cleanUp() {
        log "cleanUp"
        rm -rf .tmp 2>/dev/null
        mkdir -p .tmp
}
getDownUrl() {
        META_URL=`echo $GIT_API_REPO_MASTER | sed -e "s/\%OWNER\%/$GIT_OWNER/g" | sed -e "s/\%REPO\%/$GIT_REPO/g"`
        curl -I -s "Authorization: token ${OAUTH_TOKEN}" ${META_URL} > .tmp/repo.header
        STATUS=`head -1 .tmp/repo.header | awk -F" " '{print $2}'`
        if [ $STATUS -eq 302 ];
        then
                grep "Location:" .tmp/repo.header | awk -F" " '{print $2}'
        else
                echo "fail to load location : $STATUS"
                exit -1
        fi
}
downFromUrl() {
        URL=${1%$'\r'}
        mkdir -p .tmp/${GIT_REPO}
        curl -s $URL > .tmp/${GIT_REPO}.tar.gz
        tar xf .tmp/${GIT_REPO}.tar.gz -C .tmp/${GIT_REPO}
        find .tmp/${GIT_REPO} -maxdepth 1 -type d -regex ".*${GIT_OWNER}.*${GIT_REPO}.*"
}
log "Owner : ${GIT_OWNER}, Repository : ${GIT_REPO}"
cleanUp
REPO_DOWN_URL=`getDownUrl`
log "download url : $REPO_DOWN_URL"
SRC_DIR=`downFromUrl ${REPO_DOWN_URL}`
log "source path : $SRC_DIR"
log "deploy nginx config"
cp $SRC_DIR/config/nginx.conf /etc/nginx/sites-available/${GIT_REPO}.conf
rm /etc/nginx/sites-enabled/${GIT_REPO}.conf
ln -s /etc/nginx/sites-available/${GIT_REPO}.conf /etc/nginx/sites-enabled/${GIT_REPO}.conf
log "deploy sever code"
mkdir -p /var/www/${GIT_REPO} 2>/dev/null
rsync -az --delete --chown="www-data:www-data" $SRC_DIR/www/ /var/www/${GIT_REPO}/
log "restart nginx"
sudo service nginx restart
