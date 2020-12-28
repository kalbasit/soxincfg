{ config, pkgs, lib, ... }:

with lib;
let
  version = "1.8.0";
  ports = {
    dns = 10053;
    health = 10054;
    metrics = 10055;
  };
  clusterIP = (
    concatStringsSep "." (
      take 3 (splitString "." config.services.kubernetes.apiserver.serviceClusterIpRange
      )
    )
  ) + ".254";
  clusterDomain = "cluster.local";
in
{
  config = {
    services.kubernetes.addonManager.bootstrapAddons = {
      coredns-cr = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRole";
        metadata = {
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/bootstrapping" = "rbac-defaults";
          };
          name = "system:coredns";
        };
        rules = [
          {
            apiGroups = [ "" ];
            resources = [ "endpoints" "services" "pods" "namespaces" ];
            verbs = [ "list" "watch" ];
          }
          {
            apiGroups = [ "" ];
            resources = [ "nodes" ];
            verbs = [ "get" ];
          }
        ];
      };

      coredns-crb = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata = {
          annotations = {
            "rbac.authorization.kubernetes.io/autoupdate" = "true";
          };
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/bootstrapping" = "rbac-defaults";
          };
          name = "system:coredns";
        };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "system:coredns";
        };
        subjects = [
          {
            kind = "ServiceAccount";
            name = "coredns";
            namespace = "kube-system";
          }
        ];
      };
    };

    services.kubernetes.addonManager.addons = {
      coredns-sa = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
          };
          name = "coredns";
          namespace = "kube-system";
        };
      };

      coredns-cm = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
          };
          name = "coredns";
          namespace = "kube-system";
        };
        data = {
          Corefile = ".:${toString ports.dns} {
            errors
            log
            health :${toString ports.health}
            kubernetes ${clusterDomain} in-addr.arpa ip6.arpa {
              pods insecure
              fallthrough in-addr.arpa ip6.arpa
              ttl 30
            }
            prometheus :${toString ports.metrics}
            forward . 172.28.7.254
            cache 30
            loop
            reload
            loadbalance
          }";
        };
      };

      coredns-deploy = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/name" = "CoreDNS";
          };
          name = "coredns";
          namespace = "kube-system";
        };
        spec = {
          replicas = 3;
          selector = {
            matchLabels = { k8s-app = "kube-dns"; };
          };
          strategy = {
            rollingUpdate = { maxUnavailable = 1; };
            type = "RollingUpdate";
          };
          template = {
            metadata = {
              labels = {
                k8s-app = "kube-dns";
              };
            };
            spec = {
              containers = [
                {
                  args = [ "-conf" "/etc/coredns/Corefile" ];
                  image = "coredns/coredns:${version}";
                  imagePullPolicy = "Always";
                  livenessProbe = {
                    failureThreshold = 5;
                    httpGet = {
                      path = "/health";
                      port = ports.health;
                      scheme = "HTTP";
                    };
                    initialDelaySeconds = 60;
                    successThreshold = 1;
                    timeoutSeconds = 5;
                  };
                  name = "coredns";
                  ports = [
                    {
                      containerPort = ports.dns;
                      name = "dns";
                      protocol = "UDP";
                    }
                    {
                      containerPort = ports.dns;
                      name = "dns-tcp";
                      protocol = "TCP";
                    }
                    {
                      containerPort = ports.metrics;
                      name = "metrics";
                      protocol = "TCP";
                    }
                  ];
                  resources = {
                    limits = {
                      memory = "170Mi";
                    };
                    requests = {
                      cpu = "100m";
                      memory = "70Mi";
                    };
                  };
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    capabilities = {
                      drop = [ "all" ];
                    };
                    readOnlyRootFilesystem = true;
                  };
                  volumeMounts = [
                    {
                      mountPath = "/etc/coredns";
                      name = "config-volume";
                      readOnly = true;
                    }
                  ];
                }
              ];
              dnsPolicy = "Default";
              nodeSelector = {
                "beta.kubernetes.io/os" = "linux";
              };
              serviceAccountName = "coredns";
              tolerations = [
                {
                  effect = "NoSchedule";
                  key = "node-role.kubernetes.io/master";
                }
                {
                  key = "CriticalAddonsOnly";
                  operator = "Exists";
                }
              ];
              volumes = [
                {
                  configMap = {
                    items = [
                      {
                        key = "Corefile";
                        path = "Corefile";
                      }
                    ];
                    name = "coredns";
                  };
                  name = "config-volume";
                }
              ];
            };
          };
        };
      };

      coredns-svc = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          annotations = {
            "prometheus.io/port" = toString ports.metrics;
            "prometheus.io/scrape" = "true";
          };
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            k8s-app = "kube-dns";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/name" = "CoreDNS";
          };
          name = "kube-dns";
          namespace = "kube-system";
        };
        spec = {
          clusterIP = clusterIP;
          ports = [
            {
              name = "dns";
              port = 53;
              targetPort = ports.dns;
              protocol = "UDP";
            }
            {
              name = "dns-tcp";
              port = 53;
              targetPort = ports.dns;
              protocol = "TCP";
            }
          ];
          selector = { k8s-app = "kube-dns"; };
        };
      };
    };

    services.kubernetes.kubelet.clusterDns = clusterIP;
  };
}
