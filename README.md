# Install kubernetes on Ubuntu 22+

> [!TIP]
> The default cider used in this installation is 10.10.0.0/16.
> To change it, please replace 10.10.0.0/16 in the `control-plane-servers.sh` file

## Steps

1. Prepare servers

  Execute `prepare.sh` on all servers

2. Configure Control Plane Nodes (master nodes)

  Execute `control-plane-servers.sh` using `sudo ./control-plane-servers.sh`
