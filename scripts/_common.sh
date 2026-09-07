#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

php_upload_max_filesize="250M"

install_yunohost_logo() {
    local logo="$install_dir/resources/branding/Logo_Globinours_maxi.png"

    install -D -m 0644 \
        "$logo" \
        "/usr/share/yunohost/applogos/$app.png"
    yunohost user permission update "$app.main" --logo "$logo"
}

migrate_legacy_data() {
    local legacy_data="$install_dir/data"
    local legacy_storage="$install_dir/storage"
    local legacy_media="$install_dir/public/media"

    if [[ -d "$legacy_data" && ! -L "$legacy_data" ]]; then
        ynh_print_info "Migrating the legacy data directory to $data_dir..."
        cp -a "$legacy_data/." "$data_dir/"

        if [[ -f "$legacy_data/refuge.sqlite" ]]; then
            local migrated_database="$data_dir/refuge.sqlite.migrating"
            sqlite3 "$legacy_data/refuge.sqlite" ".backup '$migrated_database'"

            local integrity_check
            integrity_check="$(sqlite3 "$migrated_database" "PRAGMA integrity_check;")"
            if [[ "$integrity_check" != "ok" ]]; then
                rm -f "$migrated_database"
                ynh_die --message="The migrated Globinours database failed its integrity check. The legacy data was left untouched."
            fi

            mv -f "$migrated_database" "$data_dir/refuge.sqlite"
            rm -f "$data_dir/refuge.sqlite-wal" "$data_dir/refuge.sqlite-shm"
        fi
    fi

    if [[ -d "$legacy_storage" && ! -L "$legacy_storage" ]]; then
        ynh_print_info "Migrating the legacy storage directory to $data_dir/storage..."
        cp -a "$legacy_storage/." "$data_dir/storage/"
    fi

    if [[ -d "$legacy_media" && ! -L "$legacy_media" ]]; then
        ynh_print_info "Migrating the legacy public media directory to $data_dir/media..."
        cp -a "$legacy_media/." "$data_dir/media/"
    fi
}

prepare_persistent_paths() {
    for path_to_replace in "$install_dir/data" "$install_dir/storage" "$install_dir/public/media"; do
        if [[ -d "$path_to_replace" && ! -L "$path_to_replace" ]]; then
            ynh_die --message="Refusing to replace the physical data directory $path_to_replace before it is migrated."
        fi
        if [[ -e "$path_to_replace" || -L "$path_to_replace" ]]; then
            ynh_safe_rm "$path_to_replace"
        fi
    done

    ln -s "$data_dir" "$install_dir/data"
    ln -s "$data_dir/storage" "$install_dir/storage"
    ln -s "$data_dir/media" "$install_dir/public/media"

    repair_and_verify_permissions
}

repair_and_verify_permissions() {
    ynh_print_info "Checking Globinours persistent-data permissions..."

    chown -R "$app:www-data" "$install_dir"
    chown -R "$app:$app" "$data_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod -R u=rwX,g=,o= "$data_dir"

    chown "$app:www-data" "$data_dir"
    chmod 0710 "$data_dir"
    chown -R "$app:www-data" "$data_dir/media"
    chmod -R u=rwX,g=rX,o= "$data_dir/media"

    if ! ynh_exec_as_app test -r "$data_dir" || ! ynh_exec_as_app test -w "$data_dir"; then
        ynh_die --message="The Globinours system user cannot read and write its persistent data directory."
    fi
    if ! runuser -u www-data -- test -x "$data_dir" || ! runuser -u www-data -- test -r "$data_dir/media"; then
        ynh_die --message="Nginx cannot access the Globinours public media directory."
    fi
    if [[ -f "$data_dir/refuge.sqlite" ]]; then
        local integrity_check
        integrity_check="$(ynh_exec_as_app sqlite3 "$data_dir/refuge.sqlite" "PRAGMA quick_check;")"
        if [[ "$integrity_check" != "ok" ]]; then
            ynh_die --message="The Globinours database failed its integrity check."
        fi
    fi
}

inventory_persistent_data() {
    local inventory_file="$1"

    : > "$inventory_file"
    if [[ -f "$data_dir/refuge.sqlite" ]]; then
        printf '%s\n' "refuge.sqlite" >> "$inventory_file"
    fi
    for persistent_subdir in association grants medical-documents private-media media; do
        if [[ -d "$data_dir/$persistent_subdir" ]]; then
            find "$data_dir/$persistent_subdir" -type f -printf '%P\n' |
                sed "s#^#$persistent_subdir/#" >> "$inventory_file"
        fi
    done
    sort -u -o "$inventory_file" "$inventory_file"
}

verify_persistent_inventory() {
    local inventory_file="$1"
    local missing_file

    while IFS= read -r persistent_file; do
        [[ -z "$persistent_file" ]] && continue
        if [[ ! -f "$data_dir/$persistent_file" ]]; then
            missing_file="$persistent_file"
            ynh_die --message="Persistent data disappeared during the operation: $missing_file"
        fi
    done < "$inventory_file"
}
