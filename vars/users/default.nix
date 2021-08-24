inputs@{ ... }:

{
  yl = {
    hashedPassword = "$6$MYCrQEicWSxoGrHN$wHR2sLVtd4wuSN9U0aMpR0ZdE.nWTKoXh/3em3rSB7SkNYREkPgqT8EzINsvkkl9B9uWpTVJz.ULrIuPrjtL2/";
    sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258"
    ];
    uid = 2000;

    isAdmin = true;
    isNixTrustedUser = true;

    homeFunc = { pkgs }:
      if pkgs.stdenv.hostPlatform.isLinux
      then "/yl"
      else if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/yl"
      else throw "Platform is not supported";
  };
}
