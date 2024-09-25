# test-voxpupuli-puppet-k8s

- .gitignore: from a Bolt project created following https://www.puppet.com/docs/bolt/latest/bolt_installing_modules.html.
- Provision 2 or more CentOS 9 machines.
- Configure `local.yaml` for your environment.
- Install modules by running this command:
  ```
  bolt module install --force
  ```
  On Windows, you can run:
  ```
  .\InstallModules.ps1
  ```
- Provision controller on desired machine by running this command:
  ```
  bolt plan run test_voxpupuli_puppet_k8s::myplan --targets <ControllerFqdn> --user <ControllerUsername> --password <ControllerPassword> --inventory inventory.yaml node_type=controller control_plane_url=https://<ControllerFqdn>:6443 etcd_servers=https://<ControllerFqdn>:2379 secret_16_char=<Secret16Char>
  ```
  On Windows, you can run:
  ```
  .\Build.ps1 -Target <ControllerFqdn> -User <ControllerUsername> -Pass <ControllerPassword> -NodeType controller -ControlPlaneUrl https://<ControllerFqdn>:6443 -EtcdServer https://<ControllerFqdn>:2379 -Secret16Char <Secret16Char>

  ```
  It should fails with this error:
  ```
  Err: /Stage[main]/K8s::Server::Resources::Bootstrap/Kubectl_apply[puppet:cluster-info:reader Role]: Could not evaluate: Execution of '/bin/kubectl --namespace kube-system --kubeconfig /root/.kube/config get Role puppet:cluster-info:reader --output json' returned 1: error: the server doesn't have a resource type "Role"
  ```
  Run the same command a second time, and it should succeed.
- On the controller machine, copy /root/.kube/config to ~/.kube/config. Eg:
  ```
  mkdir --parents $HOME/.kube
  sudo cp --interactive /srv/kubernetes/kube-controller-manager.kubeconf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
  - Check Kubernetes cluster by running this command:
    ```
    kubectl cluster-info
    ```
    It should list something like this:
    ```
    Kubernetes control plane is running at https://<ControllerFqdn>:6443
    CoreDNS is running at https://<ControllerFqdn>:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
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
- Provision worker on desired machines by running this command:
  ```
  bolt plan run test_voxpupuli_puppet_k8s::myplan --targets <WorkerFqdn> --user <WorkerUsername> --password <WorkerPassword> --inventory inventory.yaml node_type=worker control_plane_url=https://<ControllerFqdn>:6443 etcd_servers=https://<ControllerFqdn>:2379 secret_16_char=<Secret16Char>
  ```
  On Windows, you can run:
  ```
  .\Build.ps1 -Target <WorkerFqdn> -User <WorkerUsername> -Pass <WorkerPassword> -NodeType worker -ControlPlaneUrl https://<ControllerFqdn>:6443 -EtcdServer https://<ControllerFqdn>:2379 -Secret16Char <Secret16Char>
  ```
- On the same controller machine as above:
  - Check Kubernetes nodes by running this commands:
    ```
    kubectl get nodes
    ```
    It should list something like this:
    ```
    NAME             STATUS   ROLES    AGE     VERSION
    <workerFqdn>     Ready    <none>   5h29m   v1.26.1
    ```
  - List the certificate signing request from the workers:
    ```
    kubectl get csr --sort-by=.metadata.creationTimestamp
    ```
    and approve them:
    ```
    kubectl certificate approve '<csr-id>'
    ```
    TODO: is there a way to automate that step?
