# ssl 使用可信机构颁发的证书
# dns pod
export DP_Id=
export DP_Key=
acme.sh --issue --dns dns_dp -d *.example.com --keylength ec-256 --debug

cat > harbor.yml <<EOF
# Configuration file of Harbor

# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: reg.example.com

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 5080

# https related config
https:
  # https port for harbor, default is 443
  port: 5443
  # The path of cert and key files for nginx
  certificate: /home/docker/nginx/ssl/fullchain.crt
  private_key: /home/docker/nginx/ssl/example.com.key
  # enable strong ssl ciphers (default: false)
  # strong_ssl_ciphers: false

# # Harbor will set ipv4 enabled only by default if this block is not configured
# # Otherwise, please uncomment this block to configure your own ip_family stacks
# ip_family:
#   # ipv6Enabled set to true if ipv6 is enabled in docker network, currently it affected the nginx related component
#   ipv6:
#     enabled: false
#   # ipv4Enabled set to true by default, currently it affected the nginx related component
#   ipv4:
#     enabled: true

# # Uncomment following will enable tls communication between all harbor components
# internal_tls:
#   # set enabled to true means internal tls is enabled
#   enabled: true
#   # put your cert and key files on dir
#   dir: /etc/harbor/tls/internal


# Uncomment external_url if you want to enable external proxy
# And when it enabled the hostname will no longer used
# external_url: https://reg.mydomain.com:8433

# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: msdnmm,.

# Harbor DB configuration
database:
  # The password for the user('postgres' by default) of Harbor DB. Change this before any production use.
  password: msdnmm,.

# The default data volume
data_volume: /home/docker/harbor/data
EOF

chmod +x ./install.sh
./install.sh
