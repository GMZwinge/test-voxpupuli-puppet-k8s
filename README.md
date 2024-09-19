# test-voxpupuli-puppet-k8s

- .gitignore: from a Bolt project created following https://www.puppet.com/docs/bolt/latest/bolt_installing_modules.html.
- Provision CentOS 9 VMs.
- Configure `local.yaml` for your environment.
- Install modules by running this command:
  ```
  bolt module install --force
  ```
  On Windows, you can run:
  ```
  .\InstallModules.ps1
  ```
- On one of the VM, provision controller by running this command:
  ```
  bolt plan run test_voxpupuli_puppet_k8s::myplan --targets <VmHostname> --user <VmUsername> --password <VmPassword> --inventory inventory.yaml node_type=controller
  ```
  On Windows, you can run:
  ```
  .\Build.ps1 -Target <VmHostnames> -User <VmUsername> -Pass <VmPassword> -NodeType controller

  ```
  It should fails with this error:
  ```
  Err: /Stage[main]/K8s::Server::Resources::Bootstrap/Kubectl_apply[puppet:cluster-info:reader Role]: Could not evaluate: Execution of '/bin/kubectl --namespace kube-system --kubeconfig /root/.kube/config get Role puppet:cluster-info:reader --output json' returned 1: error: the server doesn't have a resource type "Role"
  ```
  Run the same command a second time, and it should succeed.
- On one of the controller VM, copy /root/.kube/config and save it into ~/.kube/config. Eg:
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /root/.kube/config $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
  - Check Kubernetes namespaces by running this commands:
    ```
    kubectl get namespaces
    ```
    It should list something like this:
    ```
    NAME              STATUS   AGE
    default           Active   20m
    kube-node-lease   Active   20m
    kube-public       Active   20m
    kube-system       Active   20m
    ```
- On the other VMs, provision worker by running this command:
  ```
  bolt plan run test_voxpupuli_puppet_k8s::myplan --targets <VmHostname> --user <VmUsername> --password <VmPassword> --inventory inventory.yaml node_type=worker
  ```
  ```
  On Windows, you can run:
  ```
  .\Build.ps1 -Target <VmHostnames> -User <VmUsername> -Pass <VmPassword> -NodeType worker

  ```
- On the same controller VM as above:
  - Check Kubernetes nodes by running this commands:
    ```
    kubectl get nodes
    ```
    It should list something like this:
    ```
    NAME             STATUS   ROLES    AGE     VERSION
    <workerFqdn>     Ready    <none>   5h29m   v1.26.1
    ```
