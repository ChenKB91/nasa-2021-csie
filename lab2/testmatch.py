#!/usr/bin/python
n=int(input())
s=input()
ls = s.split(' ')
#print(a)
#print(s.split(' '))
if len(ls) != n:
    print('a')
    exit()
if '' in ls:
    print('b')
    exit()
if '.' in ls:
    print('c')
    exit()

print('0')
exit()
