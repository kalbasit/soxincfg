{
  imports = [ ../common ];

  config = {
    soxin = {
      hardware = {
        fwupd.enable = true;
      };
    };
  };
}
