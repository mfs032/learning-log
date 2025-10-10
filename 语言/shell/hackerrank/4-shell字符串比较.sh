#使用[]或者test命令，老旧不推荐
#/bin/bash
[ "string1" = "string2" ]
[ "string1" != "string2" ] && [ "string3" = "string4" ]
[ -z "string1" ]	#判断字符串是否长度为0
[ -n "string1" ]	#判断字符串长度不为空
#"string"字符串可以用$str去引用



#使用[[]]的shell拓展命令
#使用==、!=比较字符串相等不等，使用> <比较字符串字典顺序大小
#使用=~检查字符串是否匹配一个正则
#变量可以使用""或者''包裹一个字符串，或者使用$引用一个变量
[[ "string1" == "string2" || $str != ""]]
[[ $str != "" ]]
[[ -z $str ]]
[[ -n $str ]]
[[ $str =~ "pattern"]]



read str ; [[ $str =~ [yY] ]] && echo "YES" || echo "NO"