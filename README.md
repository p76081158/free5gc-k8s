# free5gc-k8s

![](https://i.imgur.com/wy0NI6X.png)

###### tags: `docs` `Kubernetes` `free5gc` `NFV`

## Introduction

Deploy free5gc v3.0.5 on kubernetes

## Environment Setup

* [Kube5GNfvo](https://github.com/p76081158/kube5gnfvo)

## Network Interface Name

* MACVLAN need host network interface name
* use same interface name make thing easier
* set promiscuous mode on

### Change interface name by MAC address

```bash
# get MAC address
$ ip link
$ sudo nano /etc/udev/rules.d/10-network.rules

# change MAC address
SUBSYSTEM=="net", ACTION=="add",
ATTR{address}=="aa:bb:cc:dd:ee:f1", NAME="eth0"
```

### Modify /etc/network/interfaces

```bash
$ sudo nano /etc/network/interfaces

# change interface on every nodes for NetworkAttachmentDefinition (macvlan)
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

# restart network
$ sudo /etc/init.d/networking restart
```

### Host node network setting

```bash
# set eth0 promiscuous mode on
$ sudo ip link set eth0 promisc on

# check flag P is there in eth0
$ netstat -i

# set ip forward
$ sudo nano /etc/sysctl.conf

# uncomment this line
net.ipv4.ip_forward=1
```

## gNB and UPF

* gNB and UPF can't be deployed on the same host
* because they both need access /dev/net/tun on the host, this will cause race condition problem

## Quickstart Installation Guide


* Add label to one worker node
    ```bash
    # mark node for gNB
    $ kubectl label nodes <name_of_your_node_for_gnb> dedicated=worker-gnb
    ```
* Clone 
    ```bash
    $ git clone https://github.com/p76081158/free5gc-k8s.git
    $ cd free5gc-k8s/deploy/
    ```
* Start free5gc
    ```bash
    $ ./free5gc-apply-all.sh
    ```
* Clear free5gc
    ```bash
    $ ./free5gc-delete-all.sh
    ```

### [hhorai/gnbsim](https://github.com/hhorai/gnbsim)

#### Bug

```bash
[gnbsim]2021/03/10 08:37:16.616418 example.go:106: read: timeout
[gnbsim]2021/03/10 08:37:16.616581 example.go:74: write: len 40, info: &{Stream:0 SSN:4 Flags:0 _:0 PPID:1006632960 Context:0 TTL:0 TSN:2068370716 CumTSN:0 AssocID:2}
[gnbsim]2021/03/10 08:37:17.617662 example.go:247: GTP-U interface name: net1
[gnbsim]2021/03/10 08:37:17.617708 example.go:248: GTP-U local addr: 192.168.72.3
[gnbsim]2021/03/10 08:37:17.617728 example.go:249: GTP-U peer addr : 192.168.72.101
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x18 pc=0x57a4d7]

goroutine 1 [running]:
github.com/vishvananda/netlink.(*Handle).LinkDel(0x939250, 0x0, 0x0, 0x0, 0x0)
	/go/pkg/mod/github.com/vishvananda/netlink@v1.1.1-0.20200603190747-5400e006d43d/link_linux.go:1408 +0x37
github.com/vishvananda/netlink.LinkDel(...)
	/go/pkg/mod/github.com/vishvananda/netlink@v1.1.1-0.20200603190747-5400e006d43d/link_linux.go:1401
main.addTunnel(0x7426e3, 0x7, 0xc000078000, 0xc000010010, 0x0)
	/go/src/gnbsim/example/example.go:279 +0x6b
main.(*testSession).setupN3Tunnel(0xc0000ac0c0, 0x17, 0x8)
	/go/src/gnbsim/example/example.go:262 +0x2c7
main.main()
	/go/src/gnbsim/example/example.go:546 +0xd3

```

* Problem : delete gtp-gnb interface before create ( gtp-gnb is not exist )

#### Solution

* Create gtp-gnb network interface in container
    ```bash
    # choose one container to enter
    $ kubectl -n free5gc exec -it free5gc-gnbsim-xxxx -c free5gc-gnbsim /bin/bash
    $ kubectl -n free5gc exec -it free5gc-gnbsim-xxxx -c tcpdump /bin/sh
    
    # enter free5gc-gnbsim container
    $ apt update
    $ apt install iproute2
    $ ip tuntap add gtp-gnb mode tun
    
    # enter tcpdump container
    $ apk update
    $ apk add iproute2
    $ ip tuntap add gtp-gnb mode tun
    ```

### UPF ip_forward & iptables

* Set system env
    ```bash
    $ sysctl -w net.ipv4.ip_forward=1
    ```
* Create rule in container ( choose 'tcpdump' container )
    ```bash
    $ kubectl -n free5gc exec -it free5gc-upf-1-xxxx -c tcpdump /bin/sh
    $ apk update
    $ apk add iptables
    $ iptables -t nat -A POSTROUTING -s 60.60.0.0/16 ! -o upfgtp -j MASQUERADE
    ```

## Test

* Enter gnbsim container
    ```bash
    $ kubectl -n free5gc exec -it free5gc-gnbsim-xxxx -c free5gc-gnbsim /bin/bash
    ```
* Copy config file ( example.json )
    ```bash
    $ cp ../config/example.json ./
    ```
* Run Test ( this will ping www.google.com )
    ```bash
    $ ./example
    ```
* Or Try ping server in kubernetes (simple-web)
    ```bash
    # open another terminal
    $ cd free5gc-k8s/deploy/simple-web/overlays/
    $ kubectl apply -k .
    
    # change url in example.json ( www.google.com --> 10.200.100.30:80 )
    $ ./example
    ```
    * UPF and simple-web must on the same node
    * Or you can setup vxlan between OpenvSwitch on each nodes - [More detail](https://www.sidorenko.io/post/2018/11/openstack-networking-open-vswitch-and-vxlan-introduction/)
    * Otherwise, deloy another server without using ovs-cni (use flannel to communication)

    
## Debug

* Run tcpdump on UPF ( check gtp tunnel )
    ```bash
    $ kubectl -n free5gc exec -it free5gc-upf-1-xxxx -c tcpdump /bin/sh
    $ tcpdump -i upfgtp -n
    ```
* wireshark monitor pod ( ksniff )
    ```bash
    $ kubectl sniff -n free5gc <pod-name>
    ```