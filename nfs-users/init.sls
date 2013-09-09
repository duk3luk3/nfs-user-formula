#!mako|yaml
# file structure:
# 1. set up homedir and nfs exports on master
# 2. set up nfs mount on clients
# 3. for all groups:
#    - create homedir
# 3. for all users:
#    - create user

include:
  - nfs-users.nfs


## set master id var
<%
  pillar_root = pillar.get('users_nfs',{})
  is_master = grains['id'] == pillar_root.get('master', '')
  homesdir = pillar_root.get('topdir', '/srv/nfs/homes')
  userstring = ' '.join([x + '(rw)' for x in pillar_root.get('clients',[])]) %>
% if is_master:
# executing master branch
# set up nfs homedir and exports on master
nfs_homedir_top:
  file.directory:
    - name: ${homesdir}
    - user: root
    - group: root
    - mode: 0711

/etc/exports.d:
  file.directory:
    - user: root
    - group: root
    - mode: 0731

/etc/exports.d/salt.nfs-users.exports:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - contents: ${homesdir} ${userstring}
    - require:
        - file.directory: /etc/exports.d

% else:
## create device string
<%
  dev = ${ pillar_root.get('master_uri',pillar_root.get('master','')) }:${homesdir} 
%>
# executing client branch
# set up nfs mount dir
/mnt/nfs:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
  mount.mounted:
    - device: ${dev}
    - fstype: nfs
    - opts: rw,bg
    - require:
      - file: /mnt/nfs
      - pkg: nfs-common

# set up nfs mount on clients
/etc/fstab:
  file.append:
    - text: ${dev} /mnt/nfs nfs rw,bg 0 0
% endif
<%  
    groups = pillar_root.get('groups', {})
%>
# create groups and homedirs
<%
     if is_master:
       homedir_root = homesdir
     else:
       homedir_root = '/mnt/nfs'
%>
%  if is_master:
%    for name, group in groups.items():
${name}_group:
  file.directory:
    - name: ${homedir_root}/${name}
    - user: root
    - mode: 3775
    - group: ${name}
    - require:
      - group: ${name}
  group.present:
    - name: ${name}
    - gid: ${group['gid']}
%    endfor
%  endif

# create users
%  for name, user in pillar_root.get('users', {}).items():
<% 
     if user == None:
       user = {}
     main_group = user['groups'][0]
%>
${name}_user:
  user.present:
    - name: ${name}
    - home: ${homedir_root}/${main_group}
    - shell: ${user.get('shell','/bin/bash')}
    - uid: ${user['uid']}
    - gid: ${groups[main_group]['gid']}
    - groups:
%     for group in user.get('groups', []):
      - ${group}
%     endfor
%  endfor
