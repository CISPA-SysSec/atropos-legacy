#!/usr/bin/env bash
set -ex

# logging functions
in_log() {
        local type="$1"; shift
        printf '%s [%s] [Entrypoint]: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$type" "$*"
}

in_error() {
        in_log ERROR "$@" >&2
        exit 1
}

# Indirect expansion (ie) is not supported in bourne shell. That's why we are using this "magic" here.
ie_gv() {
        eval "echo \$$1"
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
        local var="$1"
        local fileVar="${var}_FILE"
        local def="${2:-}"

        if [ "$(ie_gv ${var})" != ""  ] && [ "$(ie_gv ${fileVar})" != "" ]; then
                in_error "Both $var and $fileVar are set (but are exclusive)"
        fi

        local val="$def"
        if [ "$(ie_gv ${var})" != "" ]; then
                val=$(ie_gv ${var})
        elif [ "$(ie_gv ${fileVar})" != "" ]; then
                val=`cat $(ie_gv ${fileVar})`
        fi

        export "$var"="$val"
        unset "$fileVar"
}


# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

# create storage volume
if [ ! -d /var/www/html/storage ] && [ -d "$BAK_STORAGE_PATH" ]; then
    mv "$BAK_STORAGE_PATH" /var/www/html/storage
elif [ -d "$BAK_STORAGE_PATH" ]; then
    # copy missing folders in storage
    IN_STORAGE_BACKUP="$(ls "$BAK_STORAGE_PATH")"
    for path in $IN_STORAGE_BACKUP; do
        if [ ! -e "/var/www/html/storage/$path" ]; then
            cp -Rp "$BAK_STORAGE_PATH/$path" "/var/www/html/storage/"
        fi
    done
fi
rm -rf "$BAK_STORAGE_PATH"

# create public volume
if [ ! -d /var/www/html/public ] && [ -d "$BAK_PUBLIC_PATH" ]; then
    mv "$BAK_PUBLIC_PATH" /var/www/html/public
elif [ ! -e /var/www/html/public/version ] || [ "$INVOICENINJA_VERSION" != "$(cat /var/www/html/public/version)" ]; then
    # version mismatch, update all
    # cp -au "$BAK_PUBLIC_PATH/"* /var/www/html/public
    echo "$INVOICENINJA_VERSION" > /var/www/html/public/version
elif [ ! -d /var/www/html/public/logo ] && [ -d "$BAK_PUBLIC_PATH/logo" ]; then
    # missing logo folder only, copy folder
    cp -a "$BAK_PUBLIC_PATH/logo" /var/www/html/public/logo
elif [ -d "$BAK_PUBLIC_PATH/logo" ]; then
    # copy missing folders in logo
    IN_LOGO_BACKUP="$(ls "$BAK_PUBLIC_PATH/logo")"
    for path in $IN_LOGO_BACKUP; do
        if [ ! -e "/var/www/html/public/logo/$path" ]; then
            cp -a "$BAK_PUBLIC_PATH/logo/$path" "/var/www/html/public/logo/"
        fi
    done
fi
rm -rf "$BAK_PUBLIC_PATH"

# Set permission for web server to create/update files (only <v4)
chown -R "$INVOICENINJA_USER":"$INVOICENINJA_USER" /var/www/html/storage /var/www/html/public /var/www/html/bootstrap

# Initialize values that might be stored in a file
file_env 'APP_KEY'
file_env 'API_SECRET'
file_env 'CLOUDFLARE_API_KEY'
file_env 'DB_USERNAME'
file_env 'DB_USERNAME1'
file_env 'DB_USERNAME2'
file_env 'DB_PASSWORD'
file_env 'DB_PASSWORD1'
file_env 'DB_PASSWORD2'
file_env 'MAIL_USERNAME'
file_env 'MAIL_PASSWORD'
file_env 'MAILGUN_SECRET'
file_env 'S3_KEY'
file_env 'S3_SECRET'

# Run Laravel stuff
if [[ "$1" == "supervisord" ]] || [[ "$1" == "php-fpm" ]]; then
    echo "Initialising Laravel..."
    . laravel-init.sh
fi

pwd
ls -la

cd html

source .env

php artisan key:generate
php artisan migrate:fresh -n --seed
php artisan optimize
# php artisan db:seed -n
# php artisan ninja:create-test-data -n
php artisan serve --host=0.0.0.0 --port=80 &

# exec /docker-php-entrypoint "$@"
