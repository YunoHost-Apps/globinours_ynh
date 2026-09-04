#!/bin/bash
source /usr/share/yunohost/helpers

php_upload_max_filesize="250M"

install_yunohost_logo() {
    install -D -m 0644 "$YNH_APP_BASEDIR/logo.png" "/usr/share/yunohost/applogos/$app.png"
    if ! yunohost app config set "$app" _core.permission_main.permission_main_logo \
        --value="$YNH_APP_BASEDIR/logo.png" \
        --core; then
        ynh_print_warn --message="Le logo du portail YunoHost n'a pas pu être enregistré. L'installation de Globinours continue."
    fi
}

prepare_persistent_paths() {
    mkdir -p "$data_dir/association" "$data_dir/grants" "$data_dir/medical-documents" \
        "$data_dir/private-media" "$data_dir/media" "$data_dir/storage/logs" \
        "$data_dir/storage/backups" "$data_dir/storage/releases"
    ynh_safe_rm "$install_dir/data"
    ynh_safe_rm "$install_dir/storage"
    ynh_safe_rm "$install_dir/public/media"
    ln -s "$data_dir" "$install_dir/data"
    ln -s "$data_dir/storage" "$install_dir/storage"
    ln -s "$data_dir/media" "$install_dir/public/media"
    chown -R "$app:www-data" "$install_dir"
    chown -R "$app:$app" "$data_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod -R u=rwX,g=,o= "$data_dir"
    chown -R "$app:www-data" "$data_dir/media"
    chmod -R u=rwX,g=rX,o= "$data_dir/media"
}
