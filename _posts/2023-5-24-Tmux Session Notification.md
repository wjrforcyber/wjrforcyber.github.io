---
layout: post
title: 在Centos 7上设置Tmux命令执行结果的邮件提醒
---

> 背景：由于个人的开发环境的原因，需要在内网的服务器上大量的跑长时间才能结束的命令，导致时不时需要等待或者检查，此时如果有一个能够提醒的邮件就很有助于开发效率，在学习参考了相关的知识后成功设置了这一机制，操作流程也非常简单。

# 设置邮件系统

由于是内网涉及一定的安全性，在公共场合查看邮件提醒希望不要有敏感的IP等信息出现，我们可以使用SMTP的方式触发我们一个邮箱向另一个邮箱发送邮件。设置邮件系统比较简单，类似于我们平时在第三方平台添加账户，这篇博客记录的是用163邮箱向我的内部邮箱发送消息的流程，由于公司将内部邮箱与飞书绑定，所以在日常工作中如果Tmux中的任务执行结束，我的飞书会有邮件提醒并伴有自定义内容。

## 安装依赖
邮件系统这里要保证mailx，sendmail要安装好：

```
yum -t install mailx sendmail
```
注意，通常情况下你在内部网络有权限限制的情况下尽量不要使用sudo，会给管理员带来困扰，但是如果你是自有开发者或者拥有自己的服务器sudo在permission denied的时候加上一般可以解决问题。

## 设置rc文件[^1]
打开mailx的rc配置文件：
```
vim /etc/mail.rc
```
首先前往163邮箱设置界面选择添加第三方平台，找到SMTP相关信息。
文末直接添加：
```
set from=<USERNAME>@163.com
set smtp=smtps://smtp.163.com:465
set smtp-auth-user=<USERNAME>@163.com
set smtp-auth-password=XXXXXXXXXXXX
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb
```
## 重启sendmail服务
```
systemctl restart sendmail.service
systemctl enable sendmail.service
```

## tmux设置

### 添加函数[^3]
此时的163邮箱已经可以发送邮件了，但是我们需要得到tmux session中命令的执行结果，在```～/.bashrc```中添加：

```
#function to send email when tmux job finishes
function tmuxmail {
    if [ $? == 1 ]
      then
        tmux_session=$(tmux display-message -p "#S")
        echo -e "\nProcess running in $tmux_session failed!" | mail -v -s "FAILED!:TMUX REPORT" <USERNAME>@<DOMAINNAME>
      else
        tmux_session=$(tmux display-message -p "#S")
        echo -e "\nProcess running in $tmux_session successfully finished." | mail -v -s "SUCCESS!:TMUX REPORT" <USERNAME>@<DOMAINNAME>
    fi
}
export -f tmuxmail
```
这里需要注意的是命令的执行结果的判断，如果是你自己写的命令或者脚本要处理好执行结果的含义，不然可能导致对错逻辑反转。```tmux_session```这里得到的是执行命令的session的名称，mail的参数可以自定义添加，```-v```是verbose，会在最后显示出邮件发送的状态详细信息，```-s```是设定subject名称，最终会显示在邮件头部。

### source ～/.bashrc
这个记得添加到```～/.bash_profile```中供tmux使用[^2]。

# 使用
执行命令的时候添加```;tmuxmail```调用该函数。
例如：```./build.py -c --RelWithDebInfo -j 20; tmuxmail```
# Reference
[^1]: https://blog.mimvp.com/article/26872.html
[^2]: https://stackoverflow.com/a/28467837/19954247
[^3]: Stachelek (2021, May 7). Kevin Stachelek | PhD Candidate: Email notifications for tmux jobs. Retrieved from http://stchlk.rbind.io/posts/2021-05-07-email-notifications-for-tmux-jobs/
