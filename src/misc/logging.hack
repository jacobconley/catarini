namespace catarini\log; 

//TODO: Log file?  Pretty colors?  https://misc.flogisoft.com/bash/tip_colors_and_formatting

function query(string $query) : void { 
    $log = "[SQL] $query";
    echo($log."\n"); 
    \error_log($log); 
}


function write_file(string $file) : void { 
    echo "[-] Writing to $file\n";
}

function create_dir(string $dir) : void { 
    echo "[-] Creating $dir\n";
}