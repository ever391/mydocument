# Postgresql数据库Mac配置说明

### No.1 安装postgresql

```
brew install postgresql
```

### No.2 配置DB文件存放位置

```
initdb -D /usr/local/posgres/data      # 记得有权限哦
```

### No.3 登陆数据库

```
psql postgres	# postgres是默认数据库
```

### No.4 创建用户与设置登录密码

```
CREATE ROLE username LOGIN PASSWORD '123456'   # 记得是单引号
```

### No.5 常用命令

```
\h：查看SQL命令的解释，比如\h select。
\?：查看psql命令列表。
\l：列出所有数据库。
\c [database_name]：连接其他数据库。
\d：列出当前数据库的所有表格。
\d [table_name]：列出某一张表格的结构。
\dn 查看表架构
\du：列出所有用户。
\e：打开文本编辑器。
\conninfo：列出当前数据库和连接的信息。
```

