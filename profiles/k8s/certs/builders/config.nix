{
  key = {
    algo = "rsa";
    size = 2048;
  };

  localHosts = [
    "localhost"
    "127.0.0.1"
    "::1"
  ];

  masterHosts = [
    "192.168.50.6"
    "192.168.50.7"
    "192.168.50.8"
  ];

  masterHostNames = [
    "k8s-master-1.sn0.nasreddine.com"
    "k8s-master-2.sn0.nasreddine.com"
    "k8s-master-3.sn0.nasreddine.com"
  ];

  workerHosts = [
    "192.168.50.9"
    "192.168.50.10"
    "192.168.50.11"
  ];

  workerHostNames = [
    "k8s-worker-1.sn0.nasreddine.com"
    "k8s-worker-2.sn0.nasreddine.com"
    "k8s-worker-3.sn0.nasreddine.com"
  ];

  advertiseIPs = [
    "172.28.7.10"
  ];

  advertiseHostNames = [
    "master.k8s.nasreddine.com"
  ];

  domain = "k8s.nasreddine.com";

  name = {
    O = "Nasreddine.";
    OU = "k8s home cluster";
    L = "Bay Area";
    ST = "CA";
    C = "US";
  };

  caConfigServerClient = builtins.toJSON {
    signing = {
      default = {
        usages = [
          "signing"
          "key encipherment"
          "server auth"
          "client auth"
        ];
        expiry = "876000h";
      };
    };
  };
  caConfigServer = builtins.toJSON {
    signing = {
      default = {
        usages = [
          "signing"
          "key encipherment"
          "server auth"
        ];
        expiry = "876000h";
      };
    };
  };
  caConfigClient = builtins.toJSON {
    signing = {
      default = {
        usages = [
          "signing"
          "key encipherment"
          "client auth"
        ];
        expiry = "876000h";
      };
    };
  };
}
