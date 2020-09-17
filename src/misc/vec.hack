namespace HH\Lib\Vec; 

/*
 *  These are features I'm gonna submit to HSL.
 *  It's probably a terrible idea to inject these into their namespace like this.  For now, I don't care
 */

/**
 * [UNOFFICIAL] Returns the key of the first element for which the given function returns true.
 * returns `NULL` if no such element exists.  
 */
function find_first_key<Tk, Tv>(KeyedContainer<arraykey, Tv> $container, (function(Tv) : bool) $func) : ?int {

    $i = -1;
    foreach($container as $t) { 
        $i++;
        if($func($t)) return $i; 
    }

    return NULL; 
}

/**
 * [UNOFFICIAL] Returns the key of the first element for which the given function returns true.
 * If no such element exists, an `\Exception` will be thrown.
 * Same as `find_first_key`, except non-optional. 
 */
function first_key<Tk, Tv>(KeyedContainer<arraykey, Tv> $container, (function(Tv) : bool) $func) : int {
    $i = find_first_key($container, $func);
    if($i is nonnull) return $i; 
    throw new \Exception("No such element"); 
}

/**
 * [UNOFFICIAL] Returns the first element for which the given function returns true.
 * returns `NULL` if no such element exists.  
 */
function find_first_where<Tk, Tv>(KeyedContainer<arraykey, Tv> $container, (function(Tv) : bool) $func) : ?Tv { 
    $key = find_first_key($container, $func); 
    return $key is null ? NULL : $container[$key]; 
}

/**
 * [UNOFFICIAL] Returns the first element for which the given function returns true.
 * returns `NULL` if no such element exists.  
 */
function first_where<Tk, Tv>(KeyedContainer<arraykey, Tv> $container, (function(Tv) : bool) $func) : Tv { 
    return $container[ first_key($container, $func) ]; 
}


/**
 * [UNOFFICIAL] Returns a vec equivalent to the given `$traversable` except without the elements corresponding to the given array keys.
 * This facilitates de-facto removal of elements from vecs, which is not directly allowed. 
 */
function without_keys<Tv>(Traversable<Tv> $traversable, int ...$key) : vec<Tv> { 
    $res = vec[];

    $i = -1;
    foreach($traversable as $x) { 
        $i++; 
        if(\in_array($i, $key)) continue; 
        $res[] = $x; 
    }

    return $res; 
}

/**
 * [UNOFFICIAL] Returns a vec equivalent to the given `$traversable` except without the given element(s). 
 * This facilitates de-facto removal of elements from vecs, which is not directly allowed.
 * This is equivalent to 
 */

function without<Tv>(Traversable<Tv> $traversable, Tv ...$objects) : vec<Tv> { 
    // Not sure about the usage of the PHP holdover `in_array` here - does it perform strict equality checks?  
    return filter($traversable,    $x ==> !(\in_array($x, $objects))    );
}