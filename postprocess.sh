postprocess ()
{ 
    red='\x1b[0;31m';
    yellow='\x1b[0;33m';
    green='\x1b[0;32m';
    teal='\x1b[0;36m';
    blue='\x1b[0;34m';
    purple='\x1b[0;35m';
    NC='\x1b[0m';
    space='-------------------------------';
   if [[ -z $1 ]]; then
    install=$(pwd | cut -d'/' -f5);
        else
        install=$1; 
    fi;
    if [[ -f /nas/content/live/$install/wp-config.php ]]; then
        wpe $install;
        db=$(grep -i db_name wp-config.php |awk -F"'" '{print $4}');
        password=$(grep DB_PASSWORD wp-config.php | cut -d"'" -f4);
        user=$(grep DB_USER wp-config.php | cut -d"'" -f4);
        prefix=$(grep -i table_prefix wp-config.php |awk -F"'" '{print $2}');
        if [[ -n $(grep -E "define\(\ ?'MULTISITE', true\ ?\);" wp-config.php) ]]; then
            otable='sitemeta';
            table='meta_value';
            row='meta_key';
        else
            otable='options';
            table='option_value';
            row='option_name';
        fi;
        cereal=$(mysql -u $user -p$password -e "use $db; SELECT ${table} FROM ${prefix}${otable} WHERE ${row} LIKE '%post_process%'" 2>/dev/null | tail -n+2);
        pprules=$(echo -e "\n\n$cereal" | sed -r 's/\#\"\;s\:([0-9]*)\:\"/\#\ \=\>\ /g' | sed -r 's/(s*)\"\;s\:([0-9]*)\:\"/\n/g' | sed -r 's/a\:([0-9]*)\:\{s\:([0-9]*)\:\"//' | sed -r 's/\"\;\}$//' | grep -v '^$';);
        ppcount=$(echo "$pprules" | wc -l);
        echo -e "\n\n${space}${space}\nI found ${yellow}$ppcount${NC} post-processing rules currently for install ${red}$(pwd | cut -d'/' -f5)${NC}.\n${space}${space}\n\n";
        echo "$pprules";
        echo -e "\n\n";
    else
        echo -e "\n\n${space}\n  No ${red}install${NC} found/name provided was invalid.\n${space}\n\n";
    fi
}

