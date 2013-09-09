nfs-user-formula
================

A saltstack formula for centralised management of users with nfs homedirs.

##Some care required

This formula is not fire-and-forget. It does outrageous things like installing packages and fiddling with /etc/fstab and other stuff in /etc. Check the package requires in nfs.sls.

Oh, and it requires consistent manual assignment of uid's and gid's in the pillar file. Sorry!

And to top it off, it needs mako.
