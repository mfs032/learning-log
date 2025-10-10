#!/bin/bash

# 读取输入的数学表达式
read expression

# 使用 awk 计算表达式
result=$(awk "BEGIN{printf \"%.4f\n\", $expression}")

# 输出结果
echo $result