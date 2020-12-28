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
    "172.28.7.11"
    "172.28.7.12"
    "172.28.7.13"
  ];

  masterHostNames = [
    "master-11.k8s.fsn.lama-corp.space"
    "master-12.k8s.fsn.lama-corp.space"
    "master-13.k8s.fsn.lama-corp.space"
  ];

  workerHosts = [
    "172.28.7.111"
    "172.28.7.112"
    "172.28.7.113"
  ];

  workerHostNames = [
    "worker-11.k8s.fsn.lama-corp.space"
    "worker-12.k8s.fsn.lama-corp.space"
    "worker-13.k8s.fsn.lama-corp.space"
  ];

  advertiseIPs = [
    "172.28.7.10"
  ];

  advertiseHostNames = [
    "master.k8s.fsn.lama-corp.space"
  ];

  domain = "k8s.fsn.lama-corp.space";

  name = {
    O = "Lama Corp.";
    OU = "k8s cluster";
    L = "fsn";
    ST = "lama-corp";
    C = "space";
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
