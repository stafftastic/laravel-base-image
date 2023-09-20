{ lib
, pkgs
, hiPrio
, nginx
, php82
, busybox
, bash
, buildEnv
, runCommand
, dockerTools
, extraPhpExtensions ? ({enabled, all}: enabled)
}: let
  callPackage = lib.callPackageWith (pkgs // config);
  config = {
    entrypointSh = callPackage ./config/entrypoint-sh.nix {};
    phpFpmConf = callPackage ./config/php-fpm-conf.nix {};
    phpIni = callPackage ./config/php-ini.nix {};
    nginxConf = callPackage ./config/nginx-conf.nix {};
  };
  php = php82.withExtensions extraPhpExtensions;
  bin = buildEnv {
    name = "bin";
    paths = [
      (hiPrio busybox)
      bash
      nginx
      php
      php.packages.composer
    ];
    pathsToLink = [ "/bin" ];
  };
in dockerTools.buildImage {
  name = "laravel-base-image";
  tag = "local";
  copyToRoot = buildEnv {
    name = "laravel-base";
    paths = with dockerTools; [
      bin
      usrBinEnv
      caCertificates
      fakeNss
    ];
  };
  runAsRoot = ''
    #!${bash}/bin/bash
    mkdir -pm1777 /tmp
    mkdir -p /entrypoint.d
  '';
  config = {
    Cmd = [ "${bash}/bin/bash" config.entrypointSh ];
    Env = [
      "PHPRC=${config.phpIni}"
    ];
  };
}
