plan test_voxpupuli_puppet_k8s::myplan (
  TargetSpec $targets,
  Enum['controller', 'worker'] $type,
) {
  out::message('Start test_voxpupuli_puppet_k8s::myplan.')
  #
  # Install the puppet-agent package and gather facts
  # From https://www.puppet.com/docs/bolt/latest/applying_manifest_blocks.html#applying-manifest-blocks-from-a-puppet-plan
  # and https://www.puppet.com/docs/bolt/latest/applying_manifest_blocks.html#report-keys
  $targets.apply_prep
  #
  # Apply.
  $apply_results = apply($targets) {
    notify { "Start apply(${trusted['hostname']}).": }
    class { 'test_voxpupuli_puppet_k8s::my_manifest':
      type => $type,
    }
    notify { "End apply(${trusted['hostname']}).":}
  }
  out::message('End test_voxpupuli_puppet_k8s::myplan.')
}
