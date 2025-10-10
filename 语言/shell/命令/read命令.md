# 用法

脚本中由read命令，运行脚本后，会卡在stdin等待输入

read命令会一直读取直到遇到换行符，然后根据空格将输入分配给变量



```bash
] vim read1.sh
#!/bin/bash
read num1
read num2
read num3

: << 'EOF'
使用这个脚本]/bin/bash read1.sh后会等待输入，由于有3个read，所以要输入一个变量按一次回车共3次
EOF
```

```bash
] vim read2.sh
#!/bin/bash
read num1 num2 num3

: << 'EOF'
使用这个脚本因为只有一个read，所以一次输入所有变量，用空格分开，再按下回车
] /bin/bash read2.sh
1 2 3
read会自动赋值给num1 num2 num3
EOF
```



# 参数

-p

```bash
提示字符串
read -p "请输入数字" num
```

-s

```bash
静默模式，用户在输入时不会再屏幕上显示回显字符。用来输入敏感内容
read -sp "输入密码" passwd
```

-t

```bash
超时秒数，指定时间内没有输入任何内容，read命令失败退出非零状态码
read -s -p "请输入密码" -t 5 passwd
```

-n <字符数>

```bash
read在读取到指定字符数后自动返回，不要用户按回车
read -n 1 word
```

-r

```bash
原始模式，输入的\不会被是为转义符
read -r passwd
```



例子

```bash
while IFS= read -r line; do echo ${line:2:1}; done
```

