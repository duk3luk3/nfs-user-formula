nfs-common:
  pkg.installed

{% if grains['id'] == pillar.get('nfs',{}).get('master') %}
nfs-kernel-server:
  pkg.installed
{% endif %}
