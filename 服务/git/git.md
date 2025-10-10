# 三个工作区域

```
工作区(Working Dictory):就是电脑里看到的项目文件夹，在这里直接编辑文件
暂存区(Index):把工作区的改动(新增、修改、删除) git add到这里，准备下一次提交
版本库(Repositry)：存放所有提交历史的地方。把暂存区所有内容git commit到这里，就生成一个永久快照
```

# 初始设置和基础命令

## 1.初始配置

```shell
#设置全局用户名和邮箱，每次提交都会记录这个信息
git config --global user.name "lijunhua"
git config --global user.email "1771624779@qq.com"

#让命令行输出更易读(颜色高亮)
git config --global color.ui.auto
```

## 2.开始一个项目

```bash
#将现在二点文件夹初始化为一个新的Git仓库
git init

#从远程仓库克隆一个现有的项目，必须使用URL(或者SSH)，不能用别名
git clone <项目的URL>
```

## 3.基础工作流

```bash
#查看当前状态，哪些文件被修改了，哪些在暂存区
git status

#将工作区的改动提交到暂存区
git add <文件名>	#添加单个文件
git add .			#添加所有变化(新增、修改、不包括删除)
git add -A			#添加所有变化的文件(新建、修改、删除)

#将暂存区的内容提交到版本库
git commit -m "加一段注释"

#查看提交历史
git log
```

### 疑问

#### git add和git commit

```bash
灵活，比如同时修改a.py和b.py，但这两个修改无关，可以git add a.py然后git commit -m "修复A功能"
再git add b.py，然后git commit b.py -m "修复B功能"
```

#### 提交信息

```bash
一定要写
git commit -m "修复了用户登录时密码验证失败的逻辑错误"
```



# 中级概念

## 1.分支(Branch)

```bash
分支是独立的分支线，可以在不影响主线的情况下开发新功能，修复bug
git branch	#查看所有分支
git branch <新分支名>	#创建一个新分支
git checkout <分支名>	#切换到指定分支
git switch <分支名>	#？？
git merge <分支名>		#将指定分支合并到当前主分支
```

## 2.远程仓库(Remote)和推送(Push)

### git remote

```bash
与GitHub或者Gitee等平台协作
git remote add origin <URL>	#将本地仓库和远程仓库关联
#git remote add告诉Git要添加一个新的远程仓库关联
#origin是给这个远程仓库的别名(ailas)，默认习惯使用origin，也可以用其它名字
#<URL>远程仓库的地址，执行完这条命令，git会记录这个远程仓库的地址，并起名叫origin，之后可以用origin代指这个远程仓库，不需要每次输入地址

#查看已关联的仓库
git remote -v
#会有如下输出
#origin  https://github.com/你的用户名/OverTheWire.git (fetch)
#origin  https://github.com/你的用户名/OverTheWire.git (push)

#修改别名
git remote set-url origin <新的地址>
#删除，新增
git remote remove origin
git remote add origin <新的地址>


这个别名可以在推送代码，拉去代码的时候使用，不能再clone的时候使用
```



```bash

git push -u origin main	#第一次推送，将本地的main分支推送到远程origin
git push 	#之后的推送
git pull	#从远程拉去更新并合并到本地
```

## 3.查看差异和撤销

```bash
git diff	#查看工作区和暂存区的差异
git diff --staged	#查看暂存区和版本库的差异
git restore <文件>	#撤销工作区的修改(还未add)
git restore --staged <文件>	#将文件从暂存区撤出(已add，单位commit)
```





# 简单使用

## 初始化仓库、克隆仓库

```bash
#初始化仓库
] mkdir test
] cd test
] git init
#会再test文件夹中创建一个.git的文件夹


#将远程仓库克隆到本地
] git clone https://github.com/mfs032/test.git
#将远程仓库test克隆到本地，会有一个test文件夹，里面有一个.git文件夹
```

## 工作区、暂存区

```bash
#将文件从工作区提交到暂存区
] git add file1.txt file2.txt
#或者一次性添加所有文件
] git add .
#查看所在分支、工作区已提交和未提交文件
] git status


#从暂存区删除已添加的文件
] git restore --staged file*
#查看
] git status
```

## 本地仓库

```bash
] git commit
#会将暂存区的文件状态打包成一个快照，将快照数据存到本地仓库的对象数据库
#然后当前所在分支的指针移动到新创建的Commit对象上
#然后清空暂存区
#推荐-m参数加上注释
```

## 版本控制

```bash
#本地仓库会记录历史提交，使用git log查看
] git log
#git log会展示每个提交的信息
#commit:40位的哈希值，是该提交的唯一标识符。
#Author:提交者的姓名和邮箱
#Date提交发生的时间戳
#注释

#常用选项
--oneline:将每个提交压缩到一行显示
--graph:分支合并图
--decorate:显示分支和标签指针的位置
--all:显示所有分支历史记录


#还原历史提交回滚:git revert 和 git reset
#安全的回滚，已推送到远程仓库的情况下推荐使用
#git revert不会删除任何历史提交，会创建一个新的提交，新提交会撤销历史提交的更改
] git revert a1b2c3d

#强力的回滚，未提交到远程仓库的情况下可以使用
#如果已提交到远程仓库不要使用，不然会历史冲突
#git reset永久删除本地的部分历史提交，将指针移回目标提交
#git reset有三种模式hard,mixed,hard
] git reset --hard a1b2c3d
#分支指针移动到a1b2c3d
#暂存区清空
#工作目录同步a1b2c3d版本，无法恢复
#彻底抛弃a1b2c3d之后的版本，无法修复

] git reset --mixed a1b2c3d
#分支指针移动到a1b2c3d
#暂存区清空并恢复到a1b2c3d提交时的状态
#工作目录a1b2c3d之后的所有提交的更改保留，状态为Unstaged
#将一系列提交撤销，可以以重新组织并添加并提交

] git reset --soft a1b2c3d
#分支指针移动到a1b2c3d
#暂存区保留a1b2c3d之后引入的所有更改
#工作目录不变
#用来合并多个提交，并重新编写一个提交信息
```

## 快照和分支控制

```bash
#每个分支都是基于起点，去保存每一个提交
#每个提交都是一份快照

#快照
#第一次提交会存储所有文件的完整内容
#第二次提交会使用文件内容的哈希去比对，变化了就存储新文件的内容，未变化指针就指向第一次提交的文件

#分支
#创建分支后，可以再分支上进行其他功能的开发而不会影响到主分支

#列出所有本地分支
] git branch

#创建一个新分支但不切换
] git branch <name>
#切换到已存在的分支
] git checkout <name>
#创建新分支并切换
] git checkout -b <name>

#合并分支
#首先切换到目标分支
] git checkout main
#合并其他分支到当前所在分支
] git merge feature/new-feature

#删除分支
#功能合并后，可以删除分支保持仓库简洁
#安全删除，只能删除已合并的分支
] git branch -d <name>
#强制删除，用于丢弃未合并分支的工作
] git branch -D <name>
```



## 冲突

```bash
#场景一：推送时冲突
#本地历史A->B
#其他人快一步推送，导致远程仓库由A变成C状态
#本地推送，git服务器会拒绝
解决：先git pull拉取，将历史同步到本地，然后解决可能出现的合并冲突，再推送

#场景二：拉取或者合并时冲突
#两个不同分支修改了同一个文件同一行，git合并时会冲突
解决：手动解决冲突
#查找both modified文件，手动删除不需要的内容
] git status
#例如
<<<<<<< HEAD
// 你的本地 (HEAD) 修改
function displayUsername() {
    return "User: " + currentUser;
}
=======
// 远程或另一个分支的修改
function displayUsername() {
    return "Hello, " + currentUser.name + "!";
}
>>>>>>> feature/login-update

#保留
function displayUsername() {
    return "Hello, " + currentUser.name + "!";
}
```

## 本地仓库、远程仓库

```bash
本地仓库是本地目录钟.git文件夹

#常用命令
#创建本地仓库
git init
#将暂存区内容提交到本地仓库
git commit -m "注释"
#查看本地仓库提交历史
git log
#切换分支
git checkout

#远程仓库
#克隆远程仓库到本地
git clone <URL>	#默认别名origin
#将本地提交推送到远程仓库
git push
#从远程从库拉取最新提交并自动合并
git pull
#从远程仓库下载最新提交，但不合并，更新到远程跟踪分支
git fetch
```

