{
  services = {
    qemuGuest.enable = true;

    # Feed the kernel some entropy
    haveged.enable = true;
  };
}
