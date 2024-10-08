# Class: profile::k8s::worker
#
# @param role role in the cluster, server, node, none
# @param control_plane_url
#   cluster url where the server/nodes connect to.
#   this is most likely a load balanced dns with all the controllers in the backend.
#   on single head clusters this may be the dns name:port of the controller node.
# @param k8s_version version of kubernetes
# @param puppetdb_discovery whether to use puppetdb or not
# @param manage_firewall whether to manage firewall or not
# @param manage_kube_proxy whether to manage manage_kube_proxy or not, for cilium this is not needed
# @param container_manager set the cri, like cri-o or containerd
#
# lint:ignore:autoloader_layout
class profile::k8s::worker (
  # lint:endignore
  Boolean $manage_firewall                   = true,         # k8s-class default: false
  Boolean $manage_kube_proxy                 = true,         # k8s-class default: true
  Boolean $puppetdb_discovery                = lookup(k8s::puppetdb_discovery),
  K8s::Container_runtimes $container_manager = lookup(k8s::container_manager),
  Enum['node'] $role                         = 'node',       # k8s-class default: none
  Stdlib::HTTPUrl $control_plane_url         = lookup(k8s::control_plane_url),
  String[1] $k8s_version                     = lookup(k8s::k8s_version),
) {
  class { 'k8s':
    container_manager  => $container_manager,
    manage_firewall    => $manage_firewall,
    manage_kube_proxy  => $manage_kube_proxy,
    control_plane_url  => $control_plane_url,
    puppetdb_discovery => $puppetdb_discovery,
    role               => $role,
    version            => $k8s_version,
  }
}
