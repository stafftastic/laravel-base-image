{ writeText
, busybox
, nginxConf
, phpFpmConf
, phpIni
}: writeText "entrypoint.sh" ''
  #!${busybox}/bin/sh
  find /entrypoint.d -type f -executable -print0 | xargs -0I{} {}
  nginx -e /dev/null -c ${nginxConf} &
  php-fpm -Fy ${phpFpmConf} -c ${phpIni} &
  wait -n
  echo $?
''
