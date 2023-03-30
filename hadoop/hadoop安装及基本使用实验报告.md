# 实验名称：

Hadoop的安装

# 实验目的

（1）掌握hadoop的完全分布式安装

（2）掌握hdfs shell的基本使用

# 实验环境

Centos7

# 四、实验内容及步骤

## 1. linux配置

**在root用户下操作**

### （1）关闭防火墙

![](media/cb60ed71e21d0d612c788bd624acf401.png)

### （2）添加IP地址和主机名之间的映射

输入命令vim /etc/hosts

在文件hosts中添加地址和映射名

![](media/05120ce129056afcfbf21073817eaaf7.png)

### （3）设置静态ip地址

vim /etc/sysconfig/network-scripts/ifcfg-ens33

![](media/1dc652855cfc7c22a7a2f4d9f256a9b3.png)

### （4）修改主机的hostname

在命令行输入 hostnamectl set-hostname [主机名]

重启

![](media/42cbf5876ab8f9f160ed35d25dbd5779.png)

查看ip地址，看有没有配置成功

![](media/a4d161685e2c5c6a379ce48e0a3f1386.png)

### （5）创建用户

\# 添加用户名

useradd 用户名

\# 设置密码

passwd 用户名

![](media/0d1f57f4baa6bdf6d743cb4ce6e0f109.png)

### （6）配置免密码登录

vim /etc/sudoers

![](media/e3c2b39db34bb1f8dc7d1dda592934ef.png)

### （7）重启 reboot

## 2. jdk安装

**在自定义用户下进行操作，这里以用户hp为例**

### （1）在/opt下新建文件夹kit、module、packages

kit放jdk

module放hadoop

packages放上传的软件包

sudo mkdir /opt/kit /opt/module /opt/packages

sudo chown hp:hp -R /opt/kit /opt/module

sudo chmod 777 -R /opt/packages

### （2）上传jdk，并查看

![](media/519fd47771bdb6e8661a3bcacc25fcaa.png)

### （3）解压到目标文件夹

![](media/8e24b16b7bbcbbc26874cdbbab9ed388.png)

### （4）重命名

![](media/f2e4403735e66cfb60ab048506483887.png)

### （5）配置环境变量

vim \~/.bash_profile

![](media/ad8cb2fb4ba519fc7cb0925a16e01815.png)

![](media/b511d7b0e2451c0decf049ca1131be27.png)

### （6）验证java安装完成

![](media/1b8b34fc73e7001b128c0edbc2b63dbc.png)

## 3. hadoop安装

### （1）上传hadoop到/opt/packages，并解压到/opt/module

![](media/f95792267cd98e04a055f1d519d6463e.png)

### （2）配置环境变量

vim \~/.bash_profile

![](media/876345292642abbde3482542a58ca1fd.png)

source \~/.bash_profile

### （3）进入/opt/hadoop/etc/hadoop目录，修改配置文件

![](media/d58441f69a492a647247c774e05a90d2.png)

主要是hadoop-env.sh、mapred-env.sh、yarn-env.sh

core-site.xml、hdfs-site.xml、mapred-site.xml、yarn-site.xml

workers

env结尾的文件，在文件中加入export JAVA_HOME=/opt/kit/jdk8

![](media/f419b2358acc40babc59a1eae5bce078.png)

#### core-site.xml

\<configuration\>

\<property\>

\<name\>fs.defaultFS\</name\>

\<value\>hdfs://hadoop101:9000\</value\>

\</property\>

\<!--指定数据存放的位置，没有这个文件夹，需要自己建--\>

\<property\>

\<name\>hadoop.tmp.dir\</name\>

\<value\>/opt/data/hadoop\</value\>

\</property\>

\<property\>

\<name\>hadoop.proxyuser.hp.hosts\</name\>

\<value\>\*\</value\>

\</property\>

\<property\>

\<name\>hadoop.proxyuser.hp.groups\</name\>

\<value\>\*\</value\>

\</property\>

\<property\>

\<name\>hadoop.proxyuser.root.hosts\</name\>

\<value\>\*\</value\>

\</property\>

\<property\>

\<name\>hadoop.proxyuser.root.groups\</name\>

\<value\>\*\</value\>

\</property\>

\<property\>

\<name\>io.compression.codecs\</name\>

\<value\>

org.apache.hadoop.io.compress.GzipCodec,

org.apache.hadoop.io.compress.DefaultCodec,

org.apache.hadoop.io.compress.BZip2Codec,

org.apache.hadoop.io.compress.SnappyCodec,

com.hadoop.compression.lzo.LzoCodec,

com.hadoop.compression.lzo.LzopCodec

\</value\>

\</property\>

\<property\>

\<name\>io.compression.codec.lzo.class\</name\>

\<value\>com.hadoop.compression.lzo.LzoCodec\</value\>

\</property\>

\</configuration\>

#### hdfs-site.xml

\<configuration\>

\<property\>

\<name\>dfs.replication\</name\>

\<value\>3\</value\>

\</property\>

\<!-- 指定Hadoop辅助名称节点主机配置 --\>

\<property\>

\<name\>dfs.namenode.secondary.http-address\</name\>

\<value\>192.168.79.103:50090\</value\>

\</property\>

\<property\>

\<name\>dfs.safemode.threshold.pct\</name\>

\<value\>0f\</value\>

\</property\>

\</configuration\>

#### mapred-site.xml

\<configuration\>

\<property\>

\<name\>mapreduce.framework.name\</name\>

\<value\>yarn\</value\>

\</property\>

\<property\>

\<name\>yarn.app.mapreduce.am.env\</name\>

\<value\>HADOOP_MAPRED_HOME=\${HADOOP_HOME}\</value\>

\</property\>

\<property\>

\<name\>mapreduce.map.env\</name\>

\<value\>HADOOP_MAPRED_HOME=\${HADOOP_HOME}\</value\>

\</property\>

\<property\>

\<name\>mapreduce.reduce.env\</name\>

\<value\>HADOOP_MAPRED_HOME=\${HADOOP_HOME}\</value\>

\</property\>

\</configuration\>

#### yarn-site.xml

\<configuration\>

\<!-- Site specific YARN configuration properties --\>

\<!-- Reducer获取数据的方式 --\>

\<property\>

\<name\>yarn.nodemanager.aux-services\</name\>

\<value\>mapreduce_shuffle\</value\>

\</property\>

\<!-- 指定YARN的ResourceManager的地址 --\>

\<property\>

\<name\>yarn.resourcemanager.hostname\</name\>

\<value\>hadoop102\</value\>

\</property\>

\<!-- 日志聚集功能使能 --\>

\<property\>

\<name\>yarn.log-aggregation-enable\</name\>

\<value\>true\</value\>

\</property\>

\<!-- 日志保留时间设置7天 --\>

\<property\>

\<name\>yarn.log-aggregation.retain-seconds\</name\>

\<value\>604800\</value\>

\</property\>

\<property\>

\<name\>yarn.scheduler.maximum-allocation-mb\</name\>

\<value\>4096\</value\>

\</property\>

\<property\>

\<name\>yarn.scheduler.minimum-allocation-mb\</name\>

\<value\>4096\</value\>

\</property\>

\<property\>

\<name\>yarn.nodemanager.vmem-pmem-ratio\</name\>

\<value\>5.0\</value\>

\</property\>

\<property\>

\<name\>mapred.child.java.opts\</name\>

\<value\>-Xmx1024m\</value\>

\</property\>

\<property\>

\<name\>yarn.nodemanager.pmem-check-enabled\</name\>

\<value\>false\</value\>

\</property\>

\<property\>

\<name\>yarn.nodemanager.vmem-check-enabled\</name\>

\<value\>false\</value\>

\</property\>

\<property\>

\<name\>yarn.log.server.url\</name\>

\<value\>http://hadoop102:19888/jobhistory/logs\</value\>

\</property\>

\</configuration\>

#### workers

hadoop101

hadoop102

hadoop103

### （4）克隆两台虚拟机，hadoop102、hadoop103

![](media/2ef0de39c89a1564c9dfc3d7a9e05494.png)

![](media/50beefc18951d25e717d38f13f72ab69.png)

![](media/986ddb3b9c196f41b52bba4a846c01f0.png)

### （5）修hadoop102和hadoop103的hostname和ip地址

![](media/76720dca4b179e536bbf11cca944cb30.png)![](media/19685d9d337401b1f8cded3b34b9d54e.png)![](media/77b555a8e8b00763d17570a358d7870a.png)![](media/9d852d039ab616e080f767f6aee4e39c.png)

分别重启hadoop102和hadoop103

### （6）检查基础配置

![](media/f26833d2e55987a46dc85a72c6d3fbee.png)

### （7）配置ssh免密

在hadoop101上的hp用户下操作

#### 1） ssh-keygen -t rsa

按三次回车

![](media/8eec0df1dfddf049a04e6e2ce63e3bbb.png)

#### 2） 发送公钥到本机

ssh-copy-id hadoop101

输入一次密码

#### 3）分别ssh登陆一下所有虚拟机

![](media/ca19972b2aa6ccc083a2a263dd7398d9.png)

![](media/2640ec1d02e3a6e5bd34cad78ed48987.png)

#### 4）把/home/hp/.ssh 文件夹发送到hadoop102、hadoop103

![](media/51925e2fa65ed62b5221a3d4a10a7541.png)

#### 5）验证免密码

![](media/c6344d248f45b22458660399283a019f.png)![](media/97b89e5f61e4ce5dfd5c702fa9c77bde.png)![](media/f18b5d02eebd8045896b10e0365b4cf4.png)

### （8）初始化hadoop

在hadoop101下的hp用户下操作；如果失败初始化，查看日志，排错后，删data文件夹，重新执行命令

cd /opt/module/hadoop

hadoop namenode -format

![](media/c4fb98ebc7f8ada77d524a33ecc9ba4a.png)

（9）启动集群

在hadoop101上的hadoop_home下执行

sbin/start-dfs.sh

在hadoop102上的hadoop_home下执行

sbin/start-yarn.sh

![](media/18f1cd0f61b14b38869a660969d89f8a.png)![](media/f307fef623d63d88f2470eec68eb0687.png)

![](media/9548db0154182b2ace91578b74476591.png)

### （9）web页面查看

![](media/acc1a3200e627670fa23fbf573e0a44c.png)

![](media/45b0142b0cff7b80b371a8c0db1437e2.png)

## 4. hdfs shell的基本使用

### （1）命令大全

在hadoop_home下输入bin/hadoop fs

![](media/cc87064fe3976c50f56ab0e337f6c606.png)

### （2）上传

新建文件夹

hadoop fs -mkdir /test

![](media/9355fc1fae711db7ee8097d50fd72722.png)

查看文件夹创建成功

![](media/70744fbe1654af47f185c93cc02b9279.png)

hadoop -fs copyFromLocal [本地文件] [hdfs上的路径]

![](media/527ed103f6c17a1d9045dcefd198751c.png)

![](media/f3ad26a26231caeaa0adb477dae02ff0.png)

![](media/70744fbe1654af47f185c93cc02b9279.png)

hadoop -fs put [本地文件] [hdfs上的路径]

![](media/76c350f7dd41654ed8b1dc200a002d26.png)

### （3）下载

hadoop fs -copyToLocal [hdfs上的文件] [本地路径]

![](media/72b2a92c2c6f6c567c2230ec6b3af6bd.png)

hadoop fs -get [hdfs上的文件] [本地路径]

![](media/35cb3e9f3a76899887aef97525d561f9.png)

### （4）查看hdfs上的文件

hadoop fs -ls /

![](media/20987f1b4c0f20bc795d674644ef93f8.png)

### （5）显示文件内容

hadoop fs -cat [hdfs上的文件]

![](media/62026077c845ecf3bd6ffd3503da6d06.png)

### （6）在hdfs上拷贝文件到另一个文件夹

hadoop -cp [hdfs上的目标文件] [目标路径]

![](media/b1b203a7e4aec996e7d71d7767b51cc5.png)

### （7）在hdfs上移动文件位置

![](media/3e717a1b426c9e776026e8544b69cbda.png)

### （8）删除文件或文件夹

![](media/dba4e4eea01a7d6c131952ffe5bb3961.png)

### （9）统计文件夹的大小信息

![](media/f3aee727987cbca197e15d091badea7c.png)
