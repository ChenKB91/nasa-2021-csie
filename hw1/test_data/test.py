from random import choice
pos = ['aaaa','bbbb','cccc','woof','meow']
for i in range(20):
    f=open(f'test{i}','w')
    s=''
    for _ in range(5):
        s += choice(pos)+'\n'
    f.write(s)
    f.close()
