{ nginx
, writeText
}: writeText "nginx.conf" ''
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
    include ${nginx}/conf/mime.types;
    default_type application/octet-stream;
    upstream php {
      server 127.0.0.1:9000;
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
        include ${nginx}/conf/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_read_timeout 600;
      }
    }
  }
''
