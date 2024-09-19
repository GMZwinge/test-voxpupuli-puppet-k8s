#
# The Puppet Bolt image:
$BoltDockerImage = 'puppet/puppet-bolt:3.27.4'
# Project names can contain only lowercase letters, numbers, and underscores, and begin with a lowercase letter.
$BoltProjectName = 'test_voxpupuli_puppet_k8s'
$DockerMountDestination = "/$BoltProjectName"
# Mount source must be an absolute path.
$DockerMountSource = $PSScriptRoot
