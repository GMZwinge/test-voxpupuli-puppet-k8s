plan test_voxpupuli_puppet_k8s::myplan (
  TargetSpec $targets,
  Enum['controller', 'worker'] $node_type,
  String $control_plane_url,
  String $etcd_server_url,
  String $secret_16_char,
) {
  out::message('Start test_voxpupuli_puppet_k8s::myplan.')
  #
  # Add facts for this run.
  $targets_with_added_facts = add_facts(Target($targets), {
    'kubernetes' => {
      'node_type' => $node_type,
      'control_plane_url' => $control_plane_url,
      'etcd_server' => $etcd_server_url,
      'secret' => $secret_16_char,
    }
  })
  #
  # Install the puppet-agent package and gather facts
  # From https://www.puppet.com/docs/bolt/latest/applying_manifest_blocks.html#applying-manifest-blocks-from-a-puppet-plan
  # and https://www.puppet.com/docs/bolt/latest/applying_manifest_blocks.html#report-keys
  $targets_with_added_facts.apply_prep
  #
  # Apply.
  $apply_results = apply($targets_with_added_facts) {
    notify { "Start apply(${trusted['hostname']}).": }
    class { 'test_voxpupuli_puppet_k8s::my_manifest':
      node_type => $node_type,
    }
    notify { "End apply(${trusted['hostname']}).":}
  }
  # Download files that can be used for kubectl config.
  # MUST use target specific folder, because destination folder deleted at each run.
  # TODO: open an issue to offer an option to override instead of delete the whole folder,
  # or delete only the target specific subfolder.
  if $node_type == 'controller' {
    download_file('/root/.kube/config', "${targets}/config", $targets)
    download_file('/srv/kubernetes/kube-controller-manager.kubeconf', "${targets}/kube-controller-manager.kubeconf", $targets)
    download_file('/srv/kubernetes/kube-scheduler.kubeconf', "${targets}/kube-scheduler.kubeconf", $targets)
  } else {
    download_file('/srv/kubernetes/bootstrap-kubelet.kubeconf', "${targets}/bootstrap-kubelet.kubeconf", $targets)
    download_file('/srv/kubernetes/kubelet.kubeconf', "${targets}/kubelet.kubeconf", $targets)
  }
  out::message('End test_voxpupuli_puppet_k8s::myplan.')
}
