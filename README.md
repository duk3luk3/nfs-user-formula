nfs-user-formula
================

A saltstack formula for centralised management of users with nfs homedirs.

##Some care required

This formula is not fire-and-forget. It does outrageous things like installing packages and fiddling with /etc/fstab and other stuff in /etc. Check the package requires in nfs.sls.
