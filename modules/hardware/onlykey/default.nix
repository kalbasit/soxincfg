{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optionals
    types
    ;

  cfg = config.soxincfg.hardware.onlykey;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.hardware.onlykey = {
    enable = mkEnableOption "hardware.onlykey";

    ssh-support = {
      enable = mkEnableOption "Whether to enable SSH support with Onlykey.";
    };

    gnupg-support = {
      enable = mkEnableOption "Whether to enable GnuPG support with Onlykey.";

      default-key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The default key to use with your Onlykey.
        '';
      };

      decryption-key-slot = mkOption {
        type = types.either (types.ints.between 1 4) (types.ints.between 101 132);
        description = ''
          The slot to use for decryption requests.
        '';
      };

      decryption-key-public = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The public key for decryption.
        '';
      };

      decryption-key-trust = mkOption {
        type = types.enum [
          "unknown"
          1
          "never"
          2
          "marginal"
          3
          "full"
          4
          "ultimate"
          5
        ];
        default = "ultimate";
        description = ''
          The amount of trust you have in the key ownership and the care the
          owner puts into signing other keys. The available levels are
          <variablelist>
            <varlistentry>
              <term><literal>unknown</literal> or <literal>1</literal></term>
              <listitem><para>I don't know or won't say.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>never</literal> or <literal>2</literal></term>
              <listitem><para>I do NOT trust.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>marginal</literal> or <literal>3</literal></term>
              <listitem><para>I trust marginally.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>full</literal> or <literal>4</literal></term>
              <listitem><para>I trust fully.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>ultimate</literal> or <literal>5</literal></term>
              <listitem><para>I trust ultimately.</para></listitem>
            </varlistentry>
          </variablelist>
          </para><para>
          See <link xlink:href="https://www.gnupg.org/gph/en/manual/x334.html"/>
          for more.
        '';
      };

      signing-key-slot = mkOption {
        type = types.either (types.ints.between 1 4) (types.ints.between 101 132);
        description = ''
          The slot to use for signing requests.
        '';
      };

      signing-key-public = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The public key for signing.
        '';
      };

      signing-key-trust = mkOption {
        type = types.enum [
          "unknown"
          1
          "never"
          2
          "marginal"
          3
          "full"
          4
          "ultimate"
          5
        ];
        default = "ultimate";
        description = ''
          The amount of trust you have in the key ownership and the care the
          owner puts into signing other keys. The available levels are
          <variablelist>
            <varlistentry>
              <term><literal>unknown</literal> or <literal>1</literal></term>
              <listitem><para>I don't know or won't say.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>never</literal> or <literal>2</literal></term>
              <listitem><para>I do NOT trust.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>marginal</literal> or <literal>3</literal></term>
              <listitem><para>I trust marginally.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>full</literal> or <literal>4</literal></term>
              <listitem><para>I trust fully.</para></listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>ultimate</literal> or <literal>5</literal></term>
              <listitem><para>I trust ultimately.</para></listitem>
            </varlistentry>
          </variablelist>
          </para><para>
          See <link xlink:href="https://www.gnupg.org/gph/en/manual/x334.html"/>
          for more.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    soxincfg.programs.ssh = {
      enableSSHAgent = mkDefault cfg.ssh-support.enable;
    };
  };
}
