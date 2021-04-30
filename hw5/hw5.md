# HW5 - Security

### 1. Threat modeling

### 2. PoW & DoS



```
Good for you! The flag is HW5{c4ts_ar3_a_1ot_cut3r_th4n_柴魚}
```

```
What do you want to tell Sophia?
format: "Dear Sophia, `blahblahblah`. Best wishes, `yourname`."
: Dear Sophia, a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚a柴魚. Best wishes, aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!.
Good for you! The flag is HW5{柴魚柴油乾柴烈火火柴砍柴柴米油鹽醬醋茶留得青山在不怕沒柴燒}
```

```
Here is the certificate: 1554189085||292.39851583782666||2e1c8ca749380df211f83b44843052a97594b865e634b6aa8856f995e8d2938c
Good for you! The flag is HW5{y0u_shou1d_w0rk_unt1l_4.am_wi7h_m3_ev3ry_d4y!}
```

### SA 知識問答

### 弱密碼

1. Hank's Ubuntu

   * 開機時在grub選擇用recovery mode開機

   * 插入隨身碟，用`lsblk`找到它，然後`mount /dev/[???] /mnt/usb`上去

   * 把`/etc/passwd`和`/etc/shadow`複製到隨身碟，然後`umount /mnt/usb`

   * 使用John the ripper 的`unshadow`工具: 

     `~/john/run/unshadow passwd shadow > unshadow`

   * 在工作站上面用`john`配合密碼表`rockyou.txt` ([Github](https://github.com/praetorian-inc/Hob0Rules/blob/master/wordlists/rockyou.txt.gz)) 嘗試破解:

     `~/john/run/john --wordlist=rockyou.txt unshadow`

   幸好密碼在表的很前面就有了，所以一下子就得到密碼: `1qaz2wsx3edc4rfv`

   登入後桌布拿Flag: `HW5{R3al1y_Da_Y1_:P}`

   

   P.S. 如果比較喜歡hashcat, 可以用`hashcat.bin -m 1800 shadow rockyou.txt --backend-ignore-opencl`

2. Howhow's windows

   * 抓一個ubuntu的iso檔，用VM的設定把虛擬光碟放進去，開機時選擇用光碟開機，進terminal.
   * `lsblk`, 找到最大的partition然後`mkidr /mnt/win`再`mount`上去，我們就得到了Windows的檔案系統。
   * `apt-get update; apt-get install python3`
   * 把`/mnt/win/Windows/System32/config/SAM`和`/mnt/win/Windows/System32/config/SYSTEM`拿出來
   * 裝 [impacket](https://github.com/SecureAuthCorp/impacket/tree/impacket_0_9_22), 跑 `python3 setup.py`, 然後用`python3 examples/secretsdump.py SYSTEM SAM > howhow.hash`拿到 NTLM hash: `674ba145222376d43d4f0a9e3f6f315f`
   * 用隨身碟把hash拿出來
   * 用`hashcat -m 1000 howhow.hash -a 3 -1 ?l?d a?1?1?1?1?1?1?1?1 --incremental --backend-ignore-opencl`，用cuda gpu做bruteforce。

   跑一下之後得到密碼: `apple8787`

