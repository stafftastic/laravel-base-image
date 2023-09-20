{ lib
, pkgs
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
      busybox
      nginx
      php
      php.packages.composer
    ];
    pathsToLink = [ "/bin" ];
  };
  extraDirs = runCommand "extra-dirs" {} ''
    mkdir -pm1777 $out/tmp
    mkdir -p $out/entrypoint.d
  '';
in dockerTools.buildImage {
  name = "laravel-base-image";
  tag = "local";
  copyToRoot = buildEnv {
    name = "laravel-base";
    paths = with dockerTools; [
      bin
      extraDirs
      usrBinEnv
      caCertificates
      fakeNss
    ];
  };
  config = {
    Cmd = [ "${bash}/bin/bash" config.entrypointSh ];
    Env = [
      "PHPRC=${config.phpIni}"
    ];
  };
}
