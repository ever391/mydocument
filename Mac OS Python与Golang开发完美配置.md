# Mac OS Python与Golang开发完美配置

### No.1 安装Iterm2

```
https://www.iterm2.com/
```

### No.2 安装brew

- 打开Iterm2
- 复制下面代码，粘贴到Iterm2中执行。

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### No.3 安装oh my zsh

- 执行下方命令后，iterm2会自动变更默认风格

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### No.4 配置oh my zsh主题为：agnoster

#### 4.1 安装powerline-fonts依赖

```
git clone https://github.com/powerline/fonts.git --depth=1

cd fonts

./install.sh

cd ..

rm -rf fonts
```

#### 4.2 配置zsh主题

```
vim ~/.zshrc

# 替换原有的主题
ZSH_THEME="agnoster"
```

### 4.3 隐藏Iterm2中的user@host

```
vim ~/.zshrc
# 添加环境变量
export DEFAULT_USER="user"
```

#### 4.4 改变Iterm2主题颜色

- 打开Iterm2
- 点击工具栏上的"Profiles"->“Open Profiles"->"Edit Profile"->"Colors"->"Color Presets"

#### 4.5 恭喜你完成Iterm2整体主题设置

### No.5 VIM配置

#### 5.1 创建vim配置文件（如果有则忽略）

```
touch ~/.vimrc
```

#### 5.2 下载vim包管理器vundle

```
mkdir -p ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

#### 5.3 安装最新的vim版本

```
brew install vim --with-luajit
#加 --with-luajit 是因为自动补全插件 neocomplete 需要。(golang)
```

#### 5.4 安装cmake

```
brew install cmake
```

#### 5.5 编译YouCompleteMe

```
cd ~/.vim/bundle/YouCompleteMe
./install.sh
```

#### 5.6 vim-go依赖处理

##### 5.6.1 GOROOT目录当前用户一定要有权限

```
chown -R username $GOROOT
```

##### 5.6.2 开启终端代理

##### 5.6.3 在VIM中执行以下命令

```
:GoInstallBinaries
```

### No.6 配置终端代理

```
$ brew install polipo

$ sudo mkdir -p /etc/polipo/

$ sudo touch /etc/polipo/config

$ sudo vim /etc/polipo/config
# 将以下信息添加到config中
socksParentProxy = "localhost:1080"
socksProxyType = socks5

$ sudo vim /usr/local/opt/polipo/homebrew.mxcl.polipo.plist
# 在<string>/usr/local/opt/polipo/bin/polipo</string>位置下方增加下一行内容
<string>socksParentProxy=localhost:1080</string>

$ brew services start polipo

$ export http_proxy=http://127.0.0.1:8123;export https_proxy=$http_proxy
```

### No.7 安装ctags

```
brew install ctags
```

### No.8 Golang跳转

```
跳向指定function: "gd"
返回上一个位置: "ctrl-o"
```

### No.9 生成rsa私钥与公钥

```
$ ssh-keygen
# 后边直接回车到结束就好了
# 在~/.ssh下就生成了
```

### No.10 配置gitlab信息

```
$ cd ~/.ssh
$ touch config
$ vim config
# 将下边信息写入
IdentityFile ~/.ssh/id_rsa
Host {gitlab.xxxxx.com}
Port {2345}
User {git}
```

### No.11 VPN配置（L2TP）

```
$ sudo vim /etc/ppp/options
#复制以下内容到文本内
plugin L2TP.ppp
l2tpnoipsec

# 退出vim
:wq
```

