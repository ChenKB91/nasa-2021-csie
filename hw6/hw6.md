# NASA HW6

Author: B09902011陳可邦

## DNS & DHCP

* 設定網卡

  1. 在VMware的設定給Server一個NAT網卡，及一個接到LAN segment的網卡。

  2. 使用Ubuntu Server的iso開機，全部選預設選項安裝，設定user & password並重新啟動

  3. 等待重新啟動後登入，`sudo vim`編輯`/etc/netplan/`裡頭的檔案:

     ```yaml
     ens34:
        addresses: ["192.168.5.254/24"]  # replace the dhcp line
     ```

     然後`sudo netplan generate && sudo netplan apply`

* DHCP

  1. `sudo apt-get install isc-dhcp-server`

  2. `sudo vim /etc/dhcp/dhcpd.conf`

     ```
     option domain-name "nasa";
     default-lease-time 600;
     max-lease-time 7200;
     ddns-update-style none;
     INTERFACES="ens34";
     authoritative;
     subnet 192.168.5.0 netmask 255.255.255.0{
     	range 192.168.5.100 192.168.5.200;
     	option routers 192.168.5.254;
     	option domain-name-servers 192.168.5.254;
     }
     ```

  3. `sudo systemctl start isc-dhcp-server.service`

* DNS

  1. `sudo apt-get install bind9`

  2. 建立檔案：

     * nasa.hosts:

       ```
       ```

       

