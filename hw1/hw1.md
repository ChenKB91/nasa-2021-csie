# NASA HW1

Author: B09902011 陳可邦

## NA

#### 野生的密碼難道會在網路上赤裸地奔馳著？

1. We can simply filter by http and get this, since http don't do encryption:

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/httppw.png" style="zoom: 67%;" />

2. This version uses https, which encrypts requests & responses, so we can't get our password from Wireshark.

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/https.png" alt="https" style="zoom:67%;" />

#### 好玩遊戲也有暗潮洶湧的一面

1. We can use the "Conversations > Follow Stream" to inspect these conversations:

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/stream.png" alt="stream" style="zoom:67%;" />

   We can also view only data sent by our side:

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/client.png" style="zoom:67%;" />

   So basically, the game server sent us the time, the ball and the pad's location, and the client send directions when we press move.

2. If we pay attention to the conversations page, we can notice at some point there's another conversation happening on port 9394:

   ![conversations](/Volumes/Transcend/NTU/nasa-2021-csie/hw1/conversations.png)

   And when we look into it we'll discover this:

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/secret.png" style="zoom:67%;" />

   So we know the game steals our .bash_history.

3. We repeat the above steps with the pcap:

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/secret2.png" alt="secret2" style="zoom:67%;" />

   `PASSWORD=WoBuHueA_WoJiouJenDeBuHueA`

4. I wrote a quick python program to communicate with the server, since we already know the port and the format:

   ```python
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
         # Stop when recieving anything not game data
         print(data)
         break
       else:
         data=data.split('\n')
         # Make sure it don't explode when server asks for secret
         plus = 0
         if 'secret' in data[0]:
           plus = 1
           
         x=int(data[0+plus].split(' ')[-1])
         y=int(data[1+plus].split(' ')[-1])
         bx=int(data[2+plus].split(' ')[-1])
         by=int(data[3+plus].split(' ')[-1])
         t=int(data[4+plus].split(' ')[-1])
   		
         if x<bx: s.sendall(b'Move: right');print('r')
         elif x>bx: s.sendall(b'Move: left');print('l')
         elif y>by: s.sendall(b'Move: up');print('u')
         elif y<by: s.sendall(b'Move: down');print('d')
   ```

   Got the flag: `HW1{d0_y0u_knovv_wH0_KaienLin_1s?}`

   <img src="/Volumes/Transcend/NTU/nasa-2021-csie/hw1/winbypy.png" alt="winbypy" style="zoom:80%;" />

5. I'm too lazy to modify the program to play with 2 balls... Using `netstat -tulpn` we can find the server running on port 9393, then copy it. We already know the flag format, so...

   ![](/Volumes/Transcend/NTU/nasa-2021-csie/hw1/stringsgrep.png)

   I'm sorry QAQ Flag: `HW1{Dou8l3_b@ll_d0uB1e_Fun!}`

#### 這麼多的網路協定要是能全部都認識的話該有多好

1. 
2.  
3.  
4.  