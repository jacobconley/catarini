<?hh namespace xhp; 

use XHPRoot;
use function \{ is_string, explode, count };

/**
 * Replaces formatting specifiers in an  
 * @param $fmt XHP object containing formatted string children
 * @param $args Array of arguments corresponding to the format 
 */
function format(XHPRoot $fmt, ?XHPRoot ...$args) : XHPRoot 
{ 
	$new = Vector{};

	foreach($fmt->getChildren() as $child) 
	{
		if($child is string) 
		{
			// Split at formatting specifier
			$split = explode('%@', (string) $child);

			$len = count($split);
			$i = 0; // argument counter i 
			if($len > 1) { 
				for($j=0; $j<$len; $j++) // split counter j
				{ 
					// If not first child, append the argument then incriment i 
					if($j != 0) {
						$new->add($args[$i]);
						$i++;
					}

					// Then add the next split component
					$new->add($split[$j]);
				}
			}
			else $new->add($child); 
		}
		else $new->add($child); 
	}

	$fmt->replaceChildren($new);
	return $fmt; 
}