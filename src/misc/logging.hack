namespace catarini\log; 

//TODO: Log file?  Pretty colors?  https://misc.flogisoft.com/bash/tip_colors_and_formatting

function query(string $query) : void { 
    $log = "[SQL] $query";
    echo($log."\n"); 
    \error_log($log); 
}