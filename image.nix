{ lib
, pkgs
, hiPrio
, nginx
, php
, busybox
, bash
, buildEnv
, runCommand
, dockerTools
, imageName ? "laravel-base-image"
, imageTag ? "local"
, extraEnv ? []
, extraPkgs ? []
, extraPhpExtensions ? ({enabled, all}: enabled)
}: let
  callPackage = lib.callPackageWith (pkgs // config);
  config = {
    entrypointSh = callPackage ./config/entrypoint-sh.nix {};
    phpFpmConf = callPackage ./config/php-fpm-conf.nix {};
    phpIni = callPackage ./config/php-ini.nix {};
    nginxConf = callPackage ./config/nginx-conf.nix {};
  };
  phpWithExtensions = php.withExtensions extraPhpExtensions;
  bin = buildEnv {
    name = "bin";
    paths = [
      (hiPrio busybox)
      bash
      nginx
      phpWithExtensions
      phpWithExtensions.packages.composer
    ] ++ extraPkgs;
    pathsToLink = [ "/bin" ];
  };
in dockerTools.buildImage {
  name = imageName;
  tag = imageTag;
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
    mkdir -p /entrypoint.d /var/cache/nginx /app
  '';
  config = {
    Cmd = [ "${bash}/bin/bash" config.entrypointSh ];
    WorkingDir = "/app";
    Env = [
      "PHPRC=${config.phpIni}"
    ] ++ extraEnv;
  };
}
