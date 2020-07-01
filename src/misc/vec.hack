namespace HH\Lib\Vec; 

/*
 *  These are features I'm gonna submit to HSL.
 *  It's probably a terrible idea to inject these into their namespace like this.  For now, I don't care
 */

/**
 * [UNOFFICIAL] Returns the key of the first element for which the given function returns true.
 * returns `NULL` if no such element exists.  
 */
function find_first_key<Tv>(Traversable<Tv> $traversable, (function(Tv) : bool) $func) : ?int {

    $i = -1;
    foreach($traversable as $t) { 
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
function first_key<Tv>(Traversable<Tv> $traversable, (function(Tv) : bool) $func) : int {
    $i = find_first_key($traversable, $func);
    if($i is nonnull) return $i; 
    throw new \Exception("No such element"); 
}

/**
 * [UNOFFICIAL] Returns the first element for which the given function returns true.
 * returns `NULL` if no such element exists.  
 */
// function find_first<Tv>(Traversable<Tv> $traversable, (function(Tv) : bool) $func) : ?Tv { 
    
// }



/**
 * [UNOFFICIAL] Returns a vec equivalent to the given `$traversable` except without the elements corresponding to the given array keys.
 * This facilitates de-facto removal of elements from vecs, which is not directly allowed. 
 */
function without<Tv>(Traversable<Tv> $traversable, int ...$key) : vec<Tv> { 
    $res = vec[];

    $i = -1;
    foreach($traversable as $x) { 
        $i++; 
        if(\in_array($i, $key)) continue; 
        $res[] = $x; 
    }

    return $res; 
}