{ writeText }: writeText "php.ini" ''
  display_errors = On
  log_errors = On
  error_log = /dev/stderr
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
''
