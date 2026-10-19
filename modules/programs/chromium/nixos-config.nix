{ config, lib, ... }:

let
  inherit (lib) mkIf optional;

  cfg = config.soxincfg.programs.chromium;
in
{
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # BitWarden
        "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
        "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
        "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
        "neebplgakaahbhdphmkckjjcegoiijjo" # Keepa
        "ognfafcpbkogffpmmdglhbjboeojlefj" # Keybase
        "pneldbfhblmldbhmkolclpkijgnjcmng" # PR Monitor
        "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
        "pogpjdbfdfnmlegpbhdmlebognmbamko" # Refined GitLab
        "jgpmhnmjbhgkhpbgelalfpplebgfjmbf" # Smile Always
        "jldhpllghnbhlbpcmnajkpdmadaolakh" # Todoist
        "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User-Agent Switcher for Chrome
        "fpnmgdkabkmnadcjpehmlllkndpkmiak" # Wayback Machine
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ]
      ++ optional cfg.surfingkeys.enable "gfbliohnnapiefjpjlpjnehglfpaknnc";

      extraOpts = {
        BasicAuthOverHttpEnabled = false;
      };
    };
  };
}
