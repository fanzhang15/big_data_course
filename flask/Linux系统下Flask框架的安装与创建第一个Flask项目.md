<h3>一．实验名称</h3>

<h5> Linux系统下Flask框架的安装与创建第一个Flask项目</h5>

<h3>二．实验目的</h3>

<h5>（1） 在Ubuntu内安装Flask</h5>

<h5>（2） 创建并执行第一个Flask项目</h5>

<h3>三．实验环境</h3>

<h5>Ubuntu 22.04.1</h5>

<h3>四．实验内容及步骤</h3>

<h4>1. 在Ubuntu内安装Flask框架</h4>

（1） 安装与升级python的版本，Ubuntu 22.04.1随附Python 3.10.4。 我们可以通过键入以下命令来验证系统上是否安装了Python：

    python3 -V

输出应如下所示：

[img](picture\ksohtml16324\wps1.jpg) 
<img src="picture\ksohtml16324\wps1.jpg">

若没有安装则可输入以下命令进行安装

    sudo apt install python3

输出应如下所示：

![img](picture\ksohtml16324\wps2.jpg) 

输入用户密码后就会进行下载并安装，完成后可再次确定是否安装成功



（2） 安装 pip3， pip3是python3用来管理包的工具,可以用来安装、升级、卸载第三方库:

    sudo apt install python3-pip

安装完成后可以通过以下命令进行验证是否安装成功

    pip3 --version

输出应如下所示：

![img](picture\ksohtml16324\wps3.jpg) 



（3） 使用Python包管理器pip安装Flask

    pip install flask

安装完成后可以通过以下命令进行验证是否安装成功

    flask --version

输出应如下所示：

![img](picture\ksohtml16324\wps4.jpg) 



（4） 创建一个简单的hello world应用程序，该应用程序将仅打印“ Hello World！”。

    vi hello.py  

创建一个空白py文件输入

    from flask import Flask
    
    app = Flask(__name__)
    @app.route("/")
    def hello_world():
        return "Hello, World!"

按i键进入文本编辑，按esc键退出编辑，按：wq 保存文本并退出



（5） 我们将使用flask命令运行应用程序，但是在此之前，我们需要通过设置FLASK_APP环境变量来告诉Shell应用程序可以使用。

    export FLASK_APP=hello.py

    flask run

输出应如下所示：

![img](picture\ksohtml16324\wps5.jpg) 

 

接着我们就可以在网络浏览器中打开http://127.0.0.1:5000，系统将显示“ Hello World！” 信息。

![img](picture\ksohtml16324\wps6.jpg) 

要停止开发服务器类型，请在终端中按CTRL-C。完成工作后，通过键入deactivate禁用环境，我们将返回到常规shell。

 

 

 