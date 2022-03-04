semanage fcontext -a -t httpd_sys_content_t "//etc/httpd/conf.d/(/.*)?"
semanage fcontext -a -t httpd_log_t "//etc/httpd/conf.d/(/.*)?"
semanage fcontext -a -t httpd_cache_t "//etc/httpd/conf.d/(/.*)?"