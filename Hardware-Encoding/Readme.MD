To enable hardware encoding, we first have to do the installment of the Intel GPU Plugin. 

Replace <Release version> with the kubernetes version that is beiing used. In my case this was version 1.28.0 but this 1 has to be replaced with a 0 so 0.28.0

Then the gpu has to be identified in the kubernetes deployment under the resources field

# Start NFD - if your cluster doesn't have NFD installed yet
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd?ref=<RELEASE_VERSION>'

# Create NodeFeatureRules for detecting GPUs on nodes
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=<RELEASE_VERSION>'

# Create GPU plugin daemonset
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/gpu_plugin/overlays/nfd_labeled_nodes?ref=<RELEASE_VERSION>'
