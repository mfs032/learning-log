#!/bin/bash

# ��ȡ�������ѧ���ʽ
read expression

# ʹ�� awk ������ʽ
result=$(awk "BEGIN{printf \"%.4f\n\", $expression}")

# ������
echo $result