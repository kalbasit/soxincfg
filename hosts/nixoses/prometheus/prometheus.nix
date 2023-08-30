{ config, ... }:

{
  config = {
    services.grafana = {
      enable = true;
      settings.server = {
        domain = "localhost";
        http_port = 2342;
        http_addr = "0.0.0.0";
      };
    };

    services.prometheus = {
      enable = true;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
          ];
          port = 9002;
        };
      };

      globalConfig = {
        scrape_interval = "500ms";
      };

      port = 9001;

      scrapeConfigs = [
        {
          job_name = "prometheus-node";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };
  };
}

