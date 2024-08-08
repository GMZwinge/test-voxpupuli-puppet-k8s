class test_voxpupuli_puppet_k8s::my_manifest (
  Enum['controller', 'worker'] $type,
) {
  notify { 'Start test_voxpupuli_puppet_k8s::my_manifest': }
  if $type == 'controller' {
    include profile::k8s::controller
  } else {
    include profile::k8s::worker
  }
  notify { 'End test_voxpupuli_puppet_k8s::my_manifest': }
}
