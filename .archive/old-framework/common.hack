namespace simian\framework;

use RuntimeException;
use HH\Lib\{ Vec, Regex }; 

//TODO:  Document the difference in the below

/**
 * This exception represents a non-runtime error in the framework
 */
class FrameworkException extends \Exception 
{
	public function __construct(string $message, int $code=0)
	{
		parent::__construct($message, $code, NULL);
	}
}

/**
 * This exception is thrown when a parameter is required through the framework but is missing.  
 * When thrown, the HTTP response code will automatically be set to 400.
 */
class MissingParameterException extends FrameworkException 
{
	public function __construct(string $name) { 
		parent::__construct("Missing argument ".$name);
	}
}

/**
 * This exception represents a content reading error that is a result of the configuration of the framework 
 * It is thrown by the ContentDictionaryAccess class.
 */
class FrameworkContentException extends FrameworkException { 

	public function __construct(string $name, string $error, ?string $logID = NULL) { 
		parent::__construct(\sprintf("Framework Content:%s key %s",  $logID == NULL ? '' : " in $logID:", "$name $error"));
	}

	public static function DNE(string $name, ?string $logID = NULL) : FrameworkContentException{ 
		return new FrameworkContentException($name, 'does not exist', $logID);
	}

	public static function WrongType(string $name, ?string $logID = NULL) : FrameworkContentException { 
		return new FrameworkContentException($name, 'is the wrong type', $logID); 
	}
}



/**
 * This is a general-purpose exception - it should be thrown for errors which shouldn't happen but are nonetheless understood - as opposed to other uncaught exceptions
 */
class EndpointException extends \Exception
{
	public function __construct(int $code)
	{
		parent::__construct("Unspecefied exceptional condition at the endpoint", $code, NULL);
	}
}



//
// Base framework class
//



abstract class BaseFramework
 {

 	protected string $ROOT_PATH;		public function ROOT_PATH() :  string { return $this->ROOT_PATH; }
	protected ?string $ROOT_WEB;		public function ROOT_WEB()  : ?string { return $this->ROOT_WEB; }
	protected ?string $ROOT_API;		public function ROOT_API()  : ?string { return $this->ROOT_API; }

	protected bool $isProduction;		public function isProduction() : bool { return $this->isProduction; }



	protected \DictAccess $CONFIG;

 	protected _partialFramework $partial;
	public function __construct(\DictAccess $config, string $rootpath) {
		$this->partial = new _partialFramework();

		$this->CONFIG = $config; 

		$this->ROOT_PATH	= $rootpath.'/';
		$this->ROOT_WEB 	= $config->_string('ROOT_WEB');
		$this->ROOT_API 	= $config->_string('ROOT_API');
		$this->isProduction = $config->_bool('PRODUCTION') ?? FALSE; 
	}

 	/**
 	 * Return a file path relative to the Base Path of the framework
 	 */
 	public function PATH(string $file) : string { return $this->ROOT_PATH().\ltrim($file,'/'); }
 	/**
 	 * Return a hard URL relative to the Base URL of the framework
 	 */

 	public function ApiURL(string $endpoint) : string { return $this->ROOT_API().\ltrim($endpoint,'/'); }
 	public function WebURL(string $endpoint) : string { return $this->ROOT_WEB().\ltrim($endpoint,'/'); }

 	/**
 	 * Get a GET parameter.  If not set, throw a FrameworkException.
 	 * @param $name The name of the parameter.
 	 * @throws FrameworkException if the parameter is not set.
 	 * @return See description.
 	 */
 	public function get<T>(string $name) : T
 	{
 		return $this->partial->getRequire($name); 
 	}
 	/**
 	 * Get a GET parameter.  If not set, return NULL
 	 * @param $name The name of the parameter
 	 * @return See description
 	 */
 	public function _get<T>(string $name) : ?T
 	{
 		return $this->partial->get($name); 
 	}

 	/**
 	 * Get a POST parameter.  If not set, throw a FrameworkException.
 	 * @param $name The name of the parameter.
 	 * @throws FrameworkException if the parameter is not set.
 	 * @return See description.
 	 */
 	public function post<T>(string $name) : T
 	{
 		return $this->partial->postRequire($name);
 	}
 	/**
 	 * Get a POST parameter.  If not set, return NULL.
 	 * @param $name The name of the parameter
 	 * @return See description
 	 */
 	public function _post<T>(string $name) : ?T
 	{
 		return $this->partial->post($name); 
 	}

 	public function param<T>(string $name) : T
 	{
 		return $this->partial->paramRequire($name); 
 	}
 	public function _param<T>(string $name) : ?T
 	{
 		return $this->partial->param($name); 
 	}

 	/**
 	 * Log $exception to error_log.
 	 * This method generates a request UUID and logs it, returning it thereafter to be used in rendering the web page for support purposes.
 	 * @param $exception The exception to log
 	 * @param $silent If TRUE, do not print exception metadata.
 	 * @param $message An optional message to include.
 	 * @return A UUID.
 	 */
 	public function LogExceptionWithUUID(\Exception $exception, bool $silent = FALSE, ?string $message = NULL) : string 
 	{
 		if ($exception is FrameworkException) $silent = TRUE;

		$uuid = \uniqid();
 		\error_log(\json_encode(array(
 				'request-uri'			=> $this->partial->getRequestURI(),
 				'request-uuid'			=> $uuid,
 				'script-message'		=> $message,
 				'exception-name' 		=> ($silent ? NULL : $exception->__toString()),
 				'exception-message'		=> ($silent ? NULL : $exception->getMessage()),
 				'exception-backtrace'	=> ($silent ? NULL : $exception->getTraceAsString()),
 			)));
 		return $uuid;
 	}

 	// ---
 	// Locales
 	// ---

	protected ?string $Locale;
	protected ?vec<string> $LocaleKeys;

	private bool $hasResponseLanguage = FALSE;
	public function getLocale() : ?string { return $this->Locale; }
	public function hasLocaleResponse() : bool { return $this->hasResponseLanguage; }

	//TODO: Finish this 
	protected Map<string, string> $LOCALE_NAMES_NATIVE = Map {
		'en'				=> 'English',
		'en_US'				=> 'English (US)',
		'es' 				=> 'Español',
		'it' 				=> 'Italiano',
		'sv' 				=> 'Svenska',
	};

	public function setLocaleKeys(vec<string> $LocaleKeys) : void { $this->LocaleKeys = $LocaleKeys; }



	/**
 	 * Resolve the locale of the HTTP request, in the following precedence:\
 	 * * GET parameter (Sets cookie) 
 	 * * Cookie
 	 * * Accept-Language headers
 	 * * First locale given 
 	 *
 	 * * The method then sets the HTTP Response-Language header
 	 *
 	 * @param $map A map of the form 'locale' => <value>
 	 * @return The name of the locale chosen
 	 * @throws InvalidArgumentException if $map is empty
 	 */
 	public function ChooseLocale(vec<string> $locales) : string 
 	{
 		if(\count($locales) == 0) throw new \InvalidArgumentException("\$map cannot be empty");
 		if($this->LocaleKeys == NULL) $this->LocaleKeys = $locales;

 		// Default 
 		$preference = $this->partial->Locale_GET_SetCookie() ?? $this->partial->Locale_GetCookie(); // Check for preferences in GET First, then cookie
		 																							// If preference is possible, return it, otherwise choose best alt
 		$locale =  $preference != NULL && \in_array($preference, $locales) ? $preference : $this->partial->ChooseLocale($locales); 
		 																							// ^ this function chooses based on Accept-Language headers

		if($locale is null) throw new FrameworkException("Could not determine a locale for this request");

		// Send the appropriate header 
		if(!$this->hasResponseLanguage){ \header("Response-Language: $locale"); $this->hasResponseLanguage = TRUE; }

		return $locale; 
 	}


	private function findLocales(string $dir) : vec<string> { 
		$scan = \scandir($dir);
		if($scan === FALSE) throw new FrameworkException("Failed to scan for locales in $dir");

		return Vec\filter_nulls(Vec\map($scan, function(string $file) : ?string{

			$x = Regex\first_match($file, re"/^(([^\.][a-z]*)(_([A-Z]+))?)\.toml$/");
			if($x) return $x[1];
			else return NULL; 

		}));
	}

	public function ReadLocaleInDir(string $path) : \DictAccess { 
		$locale = $this->ChooseLocale($this->findLocales("$path"));
		return \toml\parseFile("$path/$locale.toml");
	}




 	//
 	// Code migrated from FrameworkConfig class
 	//

	//
	// reCAPTCHA
	//
	//TODO: Migrate this 

	
	// protected ?string $RecaptchaSiteKey;
	// protected ?string $RecaptchaSecret;
	
	// public function RecaptchaJS() : \XHPRoot
	// {
	// 	return <script src="https://www.google.com/recaptcha/api.js"></script>;
	// }
	// public function RecaptchaHTML() : \XHPRoot 
	// {
	// 	return <div class="g-recaptcha center" data-sitekey={$this->RecaptchaSiteKey}></div>;;
	// }

	/**
	 * Verify a reCAPTCHA response, specified in the standard query parameter 'captcha'.
	 * @param $response [OPTIONAL] The recaptcha response.  If left null, the method will auto-detect.
	 * @throws Exceptions from CurlPost
	 * @return TRUE if successfully verified, FALSE if not
	 */
	// public function RecaptchaVerify($response = NULL) : bool
	// {
	// 	// Fetch response, if necessary
	// 	if(empty($response))
	// 	{
	// 		if(isset($_POST['g-recaptcha'])) $response=$_POST['g-recaptcha'];
	// 		else if(isset($_GET['g-captcha'])) $response=$_GET['g-recaptcha'];
	// 		else return FALSE;
	// 	}

	// 	// POST verify
	// 	$curl = curl_init();
	// 	if($curl===FALSE) throw new Exception("Could not Instantiate CURL.");
	// 	curl_setopt_array($curl, array(
	// 		CURLOPT_RETURNTRANSFER	=> 1,
	// 		CURLOPT_URL				=> 'https://www.google.com/recaptcha/api/siteverify',
	// 		CURLOPT_USERAGENT		=> 'MiDEA, Inc.',
	// 		CURLOPT_POST			=> 1,
	// 		CURLOPT_POSTFIELDS		=> array(
	// 			'secret'	=> $this->RecaptchaSecret,
	// 			'response'	=> $response
	// 		)
	// 	));
	// 	$resp = curl_exec($curl);
	// 	if($resp===FALSE) throw new RuntimeException("CURL execution failed.");
	// 	curl_close($curl);

	// 	$resp = json_decode($resp);
	// 	if($resp===FALSE) return FALSE;
	// 	return $resp->success;

	// 	// Should we handle any other of the JSON parameters?
	// 	// https://developers.google.com/recaptcha/docs/verify
	// }

	//
	// End of config code
	//




	//
	// Migrated from API subclass
	//


	public function ExitSuccess() : noreturn {
		\http_response_code(200);
		exit(0);
	}
	public function ExitCreated() : noreturn {
		\http_response_code(201);
		exit(0);
	}

	/**
	 * Exit (successfully) with JSON data.
	 * @param $status The HTTP status with which to exit
	 * @param $data The JSON data to encode
	 */
	public function ExitWithData(int $status, ?array<string, mixed> $data = NULL, ?array<string, mixed> $pagination = NULL) : noreturn
	{
		\http_response_code($status);

		$object = array(
			'data' => $data, 
			'meta' => array(),
		);
		/* HH_FIXME[4005] */
		if($pagination) $object['meta']['pagination'] = $pagination;

		echo \json_encode($object);
		exit(0);
	}
	public function ExitWithString(int $status, ?string $data = NULL) : noreturn {
		\http_response_code($status);
		if($data != NULL) echo $data; 
		exit(0);
	}

	public function ExitWithErrors(int $status, ?array<string, mixed> $errors = NULL) : noreturn 
	{
		\http_response_code($status);
		echo \json_encode(array(
			'errors' => ($errors ? $errors : array()),
			'meta' => array(),
		));
		exit(1);
	}
	public function ExitWithException(\Exception $ex, ?string $log_message = NULL) : noreturn 
	{
		\http_response_code(500);
		$uuid = $this->LogExceptionWithUUID($ex, FALSE, $log_message);

		echo \json_encode(array(
			'errors' => array(),
			'meta' => array(
				'request_id' => $uuid,
			),
		));
		exit(0);
	}
 }