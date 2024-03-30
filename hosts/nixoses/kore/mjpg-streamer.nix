{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.mjpg-streamer ];

  services.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so -d /dev/v4l/by-id/usb-046d_HD_Pro_Webcam_C920_CA58666F-video-index0 -n -r 1920x1080 -timeout 15";
    outputPlugin = "output_http.so -p 5000";
  };

  networking.firewall.allowedTCPPorts = [ 5000 ];
}
