<?hh // partial 

namespace curl
{
	class HttpFailureException extends \RuntimeException {
		public function __construct($status, $response) {
			parent::__construct("cURL failed with HTTP status $status: \n$response");
		}
	}

	function POST(string $url, ?array $parameters, ?array $curl_options = NULL) : string{ 
		$ch = \curl_init();
		\curl_setopt_array($ch, array(
			\CURLOPT_URL 				=> $url, 
			\CURLOPT_RETURNTRANSFER		=> TRUE
 		));
 		if(\count($curl_options) != 0) 	\curl_setopt_array($ch, $curl_options);

		\curl_setopt($ch, \CURLOPT_POST, 1);
 		if(\count($parameters) != 0) 	\curl_setopt($ch, \CURLOPT_POSTFIELDS, \http_build_query($parameters));

 		$response = \curl_exec($ch);
 		$status   = \curl_getinfo($ch, \CURLINFO_HTTP_CODE);
 		\curl_close($ch);

 		if(!($status >= 200 && $status < 300)) throw new HttpFailureException($status, $response);
 		else return $response; 
	}
}
