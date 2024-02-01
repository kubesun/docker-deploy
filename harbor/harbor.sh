export HARBOR_HOME="/home/harbor"

mkdir -p $HARBOR_HOME/conf
mkdir -p $HARBOR_HOME/logs
mkdir -p $HARBOR_HOME/data

cd $HARBOR_HOME

访问 https://github.com/goharbor/harbor/releases/ 查看版本并把 VERSION 变量替换为指定版本

export VERSION="v2.10.0"
wget https://github.com/goharbor/harbor/releases/download/${VERSION}/harbor-offline-installer-${VERSION}.tgz
cat $HARBOR_HOME/conf/harbor.yml.tmpl

