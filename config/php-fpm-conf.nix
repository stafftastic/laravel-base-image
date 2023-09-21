{ writeText }: writeText "php-fpm.conf" ''
  [global]
  error_log = /dev/stderr
  log_limit = 8192
  [www]
  access.log = /dev/stderr
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
''
