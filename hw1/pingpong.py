import socket

host = '127.0.0.1'
port = 9393
secret = """successfully open kai's .bash_history
part 2, length = 27
te
sudo apt install vim
vimpart 3, length = 28

ls
vim .bashrc
sudo apt purpart 4, length = 28
ge libreoffice-common 
exit
part 1, length = 28
k $USER
reboot
sudo apt updapart 0, length = 27
sudo usermod -a -G wireshark"""

with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s:
  s.connect((host,port))
  print('connected')
  s.sendall(b'start fast')
  while True:
    data = s.recv(1024).decode('ascii')
    if 'hori' not in data:    
      print(data)
      break
    else:
      data=data.split('\n')
      plus = 0
      if 'secret' in data[0]:
        plus = 1
        #print('sending secret...')
        #with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s1:
        #  s1.connect((host,port+1))
        #  s1.sendall(secret.encode())
      x=int(data[0+plus].split(' ')[-1])
      y=int(data[1+plus].split(' ')[-1])
      bx=int(data[2+plus].split(' ')[-1])
      by=int(data[3+plus].split(' ')[-1])
      t=int(data[4+plus].split(' ')[-1])
      f=0
      if x<bx: s.sendall(b'Move: right');print('r');f=1
      elif x>bx: s.sendall(b'Move: left');print('l');f=1

      elif y>by: s.sendall(b'Move: up');print('u');f=1

      elif y<by: s.sendall(b'Move: down');print('d');f=1

      #if f:
      #  print('%d,%d <-> %d, %d  t=%d'%(x,y,bx,by,t))
