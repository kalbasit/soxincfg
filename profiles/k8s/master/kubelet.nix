{ ... }:

{
  services.kubernetes.kubelet = {
    taints = {
      master = {
        key = "node-role.kubernetes.io/master";
        value = "true";
        effect = "NoSchedule";
      };
    };
    unschedulable = true;
  };
}
