# ロリポップ！マネージドクラウド
SSH_HOST = ssh-1.mc.lolipop.jp
SSH_PORT = 10022
SSH_USER = sshuser
DB_NAME = dbname
DB_USER = dbuser
DB_PASS = dbpass
DB_HOST = mysql-1.mc.lolipop.lan
WP_USER = wpuser
WP_PASS = wppass
WP_MAIL = wpmail@example.com

PROMPT_SSH_HOST ?= $(shell bash -c 'read -p "SSH / SFTP ホスト名(${SSH_HOST}): " VAL; echo $${VAL:-${SSH_HOST}}')
PROMPT_SSH_PORT ?= $(shell bash -c 'read -p "SSH / SFTP ポート(${SSH_PORT}): " VAL; echo $${VAL:-${SSH_PORT}}')
PROMPT_SSH_USER ?= $(shell bash -c 'read -p "SSH / SFTP ユーザー名(${SSH_USER}): " VAL; echo $${VAL:-${SSH_USER}}')
PROMPT_DB_NAME  ?= $(shell bash -c 'read -p "データベース データベース名(${DB_NAME}): " VAL; echo $${VAL:-${DB_NAME}}')
PROMPT_DB_USER  ?= $(shell bash -c 'read -p "データベース ユーザー名(${DB_USER}): " VAL; echo $${VAL:-${DB_USER}}')
PROMPT_DB_PASS  ?= $(shell bash -c 'read -s -p "データベース パスワード(${DB_PASS}): " VAL; echo $${VAL:-${DB_PASS}}')
PROMPT_DB_HOST  ?= $(shell bash -c 'read -p "データベース データベースのホスト名(${DB_HOST}): " VAL; echo $${VAL:-${DB_HOST}}')
PROMPT_WP_USER  ?= $(shell bash -c 'read -p "WordPress ユーザー名(${WP_USER}): " VAL; echo $${VAL:-${WP_USER}}')
PROMPT_WP_PASS  ?= $(shell bash -c 'read -s -p "WordPress パスワード(${WP_PASS}): " VAL; echo $${VAL:-${WP_PASS}}')
PROMPT_WP_MAIL  ?= $(shell bash -c 'read -p "WordPress メールアドレス(${WP_MAIL}): " VAL; echo $${VAL:-${WP_MAIL}}')

# WordPress
WORDPRESS_VERSION = latest
WORDPRESS_TITLE = ロリポップ！マネージドクラウド スターター for WordPress

install:
	$(eval SSH_PORT=${PROMPT_SSH_PORT})
	$(eval SSH_USER=${PROMPT_SSH_USER})
	$(eval SSH_HOST=${PROMPT_SSH_HOST})
	$(eval DB_NAME=${PROMPT_DB_NAME})
	$(eval DB_USER=${PROMPT_DB_USER})
	$(eval DB_PASS=${PROMPT_DB_PASS})
	$(eval DB_HOST=${PROMPT_DB_HOST})
	$(eval WP_USER=${PROMPT_WP_USER})
	$(eval WP_PASS=${PROMPT_WP_PASS})
	$(eval WP_MAIL=${PROMPT_WP_MAIL})
	$(eval INSTALLED=$(shell ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'if [ -f /var/www/html/.lolipop-mc-starter-installed ]; then echo "already installed"; fi'))
	$(eval WORDPRESS_URL=$(shell ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "hostname | sed -e 's/^ssh-/https:\/\//' | sed -e 's/\.io\-.*$$/.io/'"))
	@if [ -n "${INSTALLED}" ]; then echo "既にロリポップ！マネージドクラウド スターターによってインストールされています" && exit 1; fi
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'mkdir -p /var/www/bin'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'wget -O /var/www/bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'chmod +x /var/www/bin/wp-cli.phar'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'mv html html.backup'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'mkdir -p /var/www/html'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} './bin/wp-cli.phar core download --path=/var/www/html --locale=ja --version=${WORDPRESS_VERSION}'
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "./bin/wp-cli.phar core config --path=/var/www/html --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass='${DB_PASS}' --dbhost=${DB_HOST}  --extra-php=\"define('WP_HOME', '${WORDPRESS_URL}');define('WP_SITEURL', '${WORDPRESS_URL}');define('WP_LANG', 'ja');\$$\"\"_SERVER['HTTPS'] = 'on';\""
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "./bin/wp-cli.phar core install --path=/var/www/html --title='${WORDPRESS_TITLE}' --admin_user=${WP_USER} --admin_password='${WP_PASS}' --admin_email=${WP_MAIL} --url=${WORDPRESS_URL}"
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'touch /var/www/html/.lolipop-mc-starter-installed'

ssh:
	$(eval SSH_PORT=${PROMPT_SSH_PORT})
	$(eval SSH_USER=${PROMPT_SSH_USER})
	$(eval SSH_HOST=${PROMPT_SSH_HOST})
	ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST}
