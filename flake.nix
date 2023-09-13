{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
  let
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system: nixpkgs.legacyPackages.${system});
  in {
    packages = eachSystem (system:
    let
      pkgs = pkgsFor.${system};
      init = pkgs.writeText "entrypoint.sh" ''
        #!${pkgs.bash}/bin/bash
        mkdir -pm1777 /tmp
        nginx -e /dev/null -c ${nginxConf} &
        php-fpm -Fy ${phpFpmConf} -c ${phpIni} &
        wait -n
        echo $?
      '';
      phpFpmConf = pkgs.writeText "php-fpm.conf" ''
        [global]
        error_log = /dev/stdout
        log_limit = 8192
        [www]
        access.log = /dev/stdout
        access.format = "[php-fpm:access] %R - %u %t \"%m %r%Q%q\" %s %f %{mili}d %{kilo}M %C%%"
        clear_env = no
        catch_workers_output = yes
        decorate_workers_output = no
        user = nobody
        group = nobody
        listen = 127.0.0.1:9000
        pm = dynamic
        pm.max_children = 20
        pm.max_requests = 1000
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
      '';
      phpIni = pkgs.writeText "php.ini" ''
        display_errors = Off
        log_errors = On
        short_open_tag = Off
        variables_order = 'GPCS'
        request_order = 'GP'
        memory_limit = 512M
        max_execution_time = 300
        max_input_time = 300
        post_max_size = 50M
        upload_max_size = 50M
        max_input_vars = 5000
        expose_php = Off
        date.timezone = UTC
        opcache.memory_consumption = 512
        opcache.interned_strings_buffer = 64
        opcache.max_accelerated_files = 32531
        opcache.fast_shutdown = Off
      '';
      nginxConf = pkgs.writeText "nginx.conf" ''
        user nobody nobody;
        worker_processes 1;
        daemon off;
        error_log /dev/stdout info;
        pid /dev/null;
        events {
          worker_connections 1024;
        }
        http {
          access_log /dev/stdout;
          sendfile on;
          tcp_nopush on;
          tcp_nodelay on;
          keepalive_timeout 65;
          include ${pkgs.nginx}/conf/mime.types;
          default_type application/octet-stream;
          upstream php {
            server 127.0.0.0:9000;
          }
          server {
            listen 80;
            index index.php;
            client_max_body_size 50m;
            root /app/public;
            location / {
              try_files $uri $uri/ /index.php?$query_string;
            }
            location ~ \.php$ {
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass php;
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_read_timeout 600;
            }
          }
        }
      '';
      php = pkgs.php82.withExtensions ({ enabled, all }: with all; enabled ++ [
        rdkafka
      ]);
    in {
      default = pkgs.dockerTools.buildImage {
        name = "laravel-base-image";
        tag = "local";
        copyToRoot = pkgs.buildEnv {
          name = "laravel-base";
          paths = with pkgs; [
            busybox
            nginx
            php
            php.packages.composer
          ] ++ (with dockerTools; [
            binSh
            usrBinEnv
            caCertificates
            fakeNss
          ]);
          pathsToLink = [
            "/bin"
            "/usr/bin"
            "/usr/share"
            "/etc"
          ];
        };
        config = {
          Cmd = [ "${pkgs.bash}/bin/bash" init ];
          Env = [
            "PHPRC=${phpIni}"
          ];
        };
      };
    });
  };
}
