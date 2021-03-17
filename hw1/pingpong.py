import socket
host = '127.0.0.1'
port = 9393

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
