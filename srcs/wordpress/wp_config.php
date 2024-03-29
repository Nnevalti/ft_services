<?php
# Config Mariadb | database

$WP_DB = getenv('WP_DB');
$WP_USER = getenv('WP_USER');
$PASSWORD = getenv('PASSWORD');
$MYSQL_IP = getenv('MYSQL_IP');

define('DB_NAME', '$WP_DB');
define('DB_USER', '$WP_USER');
define('DB_PASSWORD', '$PASSWORD');
define('DB_HOST', '$MYSQL_IP');
define('DB_CHARSET', 'utf8');
define('FS_METHOD', 'direct');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);
/* C’est tout, ne touchez pas à ce qui suit ! Bonne publication. */
/** Chemin absolu vers le dossier de WordPress. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');
/** Réglage des variables de WordPress et de ses fichiers inclus. */
require_once(ABSPATH . 'wp-settings.php');
?>
