#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

php_upload_max_filesize="250M"

install_yunohost_logo() {
    install -D -m 0644 \
        "$install_dir/resources/branding/Logo_Globinours_maxi.png" \
        "/usr/share/yunohost/applogos/$app.png"
}

prepare_persistent_paths() {
    for path_to_replace in "$install_dir/data" "$install_dir/storage" "$install_dir/public/media"; do
        if [[ -e "$path_to_replace" || -L "$path_to_replace" ]]; then
            ynh_safe_rm "$path_to_replace"
        fi
    done

    ln -s "$data_dir" "$install_dir/data"
    ln -s "$data_dir/storage" "$install_dir/storage"
    ln -s "$data_dir/media" "$install_dir/public/media"

    chown -R "$app:www-data" "$install_dir"
    chown -R "$app:$app" "$data_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod -R u=rwX,g=,o= "$data_dir"

    chown "$app:www-data" "$data_dir"
    chmod 0710 "$data_dir"
    chown -R "$app:www-data" "$data_dir/media"
    chmod -R u=rwX,g=rX,o= "$data_dir/media"
}
