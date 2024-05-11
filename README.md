# Argo-for-Sac

* 新建私库，不要带argo和xray，v2ray之类的关键词，上传此项目里的index.js和package.json，自行在右边的Releases中下载bot.js,本地修改好bot.js里需要修改的变量，最好是改个文件名，.js后缀不要改，哪吒端口为{443,8443,2087,2096,2053}其中之一时开启tls，可选安装，不填哪吒变量即不启用哪吒，其他变量随意

* 然后打开任意一个公开项目，一定要公开的，点击右边的Releases，新建tag，下方将修改好的nginx.js上传,待上传完成，点击下方的publish确定上传

* 上传完成后复制链接地址 

* 然后打开新建的私库项目，打开index.js,找到第17行，替换地址，18行修改文件名
![image](https://github.com/eooce/Argo-for-Saclingo/assets/142894633/04f5a429-886e-48b8-9923-055ee73bc003)


* 链接改完后全选代码，打开https://obfuscator.io/ 混淆js代码，将混淆后的代码粘贴进index.js中，上方保存后即可去saclingo网站链接项目部署，显示successfully字样，打开网页显示hello world说明成功，过20秒即可查看节点或订阅


* 查看节点: 域名/sub
* 订阅链接：域名/sub 

最后unlink项目，再右上角设置里解绑github账户
