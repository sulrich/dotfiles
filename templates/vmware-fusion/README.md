# overview

the following files are useful for configuring vmware fusion to support small
network simulation environments.

make sure to add the following to the filesystem when vmware is shutdown in
order to allow interfaces to use promiscuous mode reasonably.

```
sudo touch "/Library/Preferences/VMware Fusion/promiscAuthorized"
```
