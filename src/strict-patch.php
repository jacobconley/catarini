<?hh // partial 
namespace simian\framework;

use function \http_response_code;
use \Lib\Vec; 

// We gota make this class cos hhvm hasn't fully migrated to strict mode yet for superglobals n allat

class _partialFramework { 

	// $_SERVER stuff

	public function getRequestURI() : string { return $_SERVER['REQUEST_URI']; }
	public function getRequestMethod() : string { return $_SERVER['REQUEST_METHOD']; }

	// Param stuff

 	public function getRequire<T>(string $name) : T
 	{
 		if(isset($_GET[$name])) return $_GET[$name];
 		http_response_code(400);
 		throw new MissingParameterException($name);
 	}
 	public function get<T>(string $name) : ?T
 	{
 		if(isset($_GET[$name])) return $_GET[$name];
 		return NULL;
 	}

 	public function postRequire<T>(string $name) : T
 	{
 		if(isset($_POST[$name])) return $_POST[$name];
 		http_response_code(400);
 		throw new MissingParameterException($name);
 	}
 	public function post<T>(string $name) : ?T
 	{
 		if(isset($_POST[$name])) return $_POST[$name];
 		return NULL;
 	}

 	public function paramRequire<T>(string $name) : T
 	{
 		if(isset($_POST[$name])) return $_POST[$name];
 		if(isset($_GET[$name])) return $_GET[$name];
		http_response_code(400); 
		throw new MissingParameterException($name);
 	}
 	public function param<T>(string $name) : ?T
 	{
 		if(isset($_POST[$name])) return $_POST[$name];
 		if(isset($_GET[$name])) return $_GET[$name];
		return NULL;
 	}

 	// Locale stuff

	// Returns cookie if it's set
 	public function Locale_GetCookie() : ?string { 
 		if(isset($_COOKIE['MCT_LOCALE'])) return $_COOKIE['MCT_LOCALE'];
 		else return NULL; 
 	}

	// If there's a GET paramter locale, set the cookie and return it, else NULL 
 	public function Locale_GET_SetCookie() : ?string { 
 		if(isset($_GET['locale']))
 		{
 			$locale= $_GET['locale'];
 			\setcookie('MCT_LOCALE', $locale);
 			return $locale;
 		}
 		return NULL; 
 	}

 	// I was just too lazy to migrate this 

	// Choose best locale based on the accept-language headers
	// Defaults to first one given 
	public function ChooseLocale(vec<string> $locales) : string 
	{
		if(\count($locales) == 0) throw new \InvalidArgumentException("\$locales cannot be empty");

			// Retrieve MCT_LOCALE cookie.
			$c = NULL;
			if(isset($_COOKIE['MCT_LOCALE']))
			{
				$c = $_COOKIE['MCT_LOCALE'];
				if(\in_array($c, $locales)) { return $c; }
			}

			// Build $list, an array of language preferences.
			// Start with the Accept-Language headers so we can reuse this nice code from StackOverflow

			$list = NULL;
			if(isset($_SERVER["HTTP_ACCEPT_LANGUAGE"]))
			{
				// The below code is from @2072's answer at https://stackoverflow.com/questions/6038236/using-the-php-http-accept-language-server-variable
				$acceptedLanguages = $_SERVER["HTTP_ACCEPT_LANGUAGE"];

				// regex inspired from @GabrielAnderson on http://stackoverflow.com/questions/6038236/http-accept-language
				$lang_parse=array();
				\preg_match_all_with_matches('/([a-z]{1,8}(-[a-z]{1,8})*)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?/i', $acceptedLanguages, inout $lang_parse);
				$langs = $lang_parse[1];
				$ranks = $lang_parse[4];


				// (create an associative array 'language' => 'preference')
				$lang2pref = array();
				for($i=0; $i < \count($langs); $i++) $lang2pref[$langs[$i]] = (float) (\count($ranks[$i]) ? $ranks[$i] : 1);

				// (comparison function for uksort)
				$cmpLangs = function ($a, $b) use ($lang2pref) {
					if ($lang2pref[$a] > $lang2pref[$b])		return -1;
					elseif ($lang2pref[$a] < $lang2pref[$b])	return 1;
					elseif (\strlen($a) > \strlen($b))			return -1;
					elseif (\strlen($a) < \strlen($b))			return 1;
					else										return 0;
				};

				// sort the languages by prefered language and by the most specific region
				\uksort(inout $lang2pref, $cmpLangs);

		    	$list = $lang2pref;
			}
			else $list = array();

			// Now insert the other variables in their place
			if($c) $list = \array_merge(array( $c => 1.0 ), $list);

			// Iterate through $list and choose the locale most appropriate.
			// The first time we find one that matches exactly, set $locale to it and break.
			$locale = NULL;
			foreach($list as $preference)
			{
				foreach($locales as $mapkey)
				{
					$preference = (string) $preference;
					$mapkey = (string) $mapkey; 
					if(\strcasecmp($preference, $mapkey) == 0)			{ $locale = $mapkey; break; } // Exact match, generally preferred
					if(\HH\Lib\Str\starts_with_ci($preference, $mapkey))	{ $locale = $mapkey; break; } // Wildcard match
				}
			}

			// If we still don't know the locale, default to something
			if($locale == NULL) $locale = $locales[0];

		$locale = (string) $locale;
		\setcookie('MCT_LOCALE', $locale, \time() + (3600 * 3600));
		return($locale);
	}
}