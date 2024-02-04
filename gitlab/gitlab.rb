external_url 'http://192.168.2.158'
gitlab_rails['gitlab_ssh_host'] = '192.168.2.158'
gitlab_rails['gitlab_shell_ssh_port'] = 2222 # Gitlab SSH地址

# Email
gitlab_rails['smtp_enable']  = true
gitlab_rails['smtp_address'] = "smtp.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xiconz@qq.com"
gitlab_rails['smtp_password'] = "bkdgrnopljpjdich"
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_pool'] = true
gitlab_rails['gitlab_email_from'] = 'xiconz@qq.com'
user['git_user_email'] = "xiconz@qq.com"
