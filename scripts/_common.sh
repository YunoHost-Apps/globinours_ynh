#!/bin/bash
source /usr/share/yunohost/helpers

prepare_persistent_paths() {
    mkdir -p "$data_dir/association" "$data_dir/grants" "$data_dir/medical-documents" \
        "$data_dir/private-media" "$data_dir/media" "$data_dir/storage/logs" \
        "$data_dir/storage/backups" "$data_dir/storage/releases"
    rm -rf "$install_dir/data" "$install_dir/storage" "$install_dir/public/media"
    ln -s "$data_dir" "$install_dir/data"
    ln -s "$data_dir/storage" "$install_dir/storage"
    ln -s "$data_dir/media" "$install_dir/public/media"
    chown -R "$app:www-data" "$install_dir"
    chown -R "$app:$app" "$data_dir"
}
