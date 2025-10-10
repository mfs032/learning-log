#使用[ 或者test命令，老旧，兼容性好
#[ $var -eq $var2 ] && [ $var3 -eq $var4 ]
#/bin/bash
num1=10
num2=20
num3=30

if [ $num1 -gt $num2 ] && [ $num2 -gt $num3 ]; then
	echo "HELLO"
fi



#使用(())算数扩展，是由Bash等支持
#/bin/bash
num1=10
num2=20
num3=30

fi (( $num1 == $num2 && $num2 >= $num3 )); then
	echo "HELLP"
fi




