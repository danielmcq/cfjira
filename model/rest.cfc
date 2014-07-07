component name="rest" extends="model.model" implements="interface.httpHost"
		hint="Superclass model to represent REST web services."
{
	VARIABLES.COOKIE_STORE   = {};

	VARIABLES[ "headers" ]   = {
		"Accept"         = "application/json"
		,"Content-Type"  = "application/json"
	};
	VARIABLES[ "helpers" ]   = {};



	public model.rest function init () {
		SUPER.init();

		VARIABLES[ "basePath" ]     = "/";
		VARIABLES[ "host" ]         = "";
		VARIABLES[ "password" ]     = "";
		VARIABLES[ "port" ]         = "";
		VARIABLES[ "protocol" ]     = "http";
		VARIABLES[ "username" ]     = "";
		VARIABLES.helpers[ "XML" ]  = new helper.XML();

		return THIS;
	}


	public any function delete ( struct params={}, string path="" ) {
		return _sendRequest( "DELETE", ARGUMENTS.params, ARGUMENTS.path );
	}


	public any function get ( struct params={}, string path="" ) {
		return _sendRequest( "GET", ARGUMENTS.params, ARGUMENTS.path );
	}


	public any function post ( struct data={}, string path="" ) {
		return _sendRequest( "POST", ARGUMENTS.data, ARGUMENTS.path );
	}


	public any function put ( struct data={}, string path="" ) {
		return _sendRequest( "PUT", ARGUMENTS.data, ARGUMENTS.path );
	}


	public string function $getBaseUrl () {
		var output = "";

		if ( Len( $getHost() ) ) {
			output = $getProtocol();
			output &= "://";
			output &= $getHost();
			output &= ":";
			output &= $getPort();
			output &= $getBasePath();
		}

		return output;
	}


	public string function $getBasePath () {
		var output = "/";

		if ( Left( VARIABLES.basePath, 1 ) == "/" ) {
			output = VARIABLES.basePath;
		} else {
			output &= VARIABLES.basePath;
		}

		return output;
	}


	public string function $getHost () {
		return VARIABLES.host;
	}


	public numeric function $getPort () {
		var output = "";

		if ( !Len( VARIABLES.port ) ) {
			if ( $getProtocol() == "https" ) {
				output = 443;
			} else {
				output = 80;
			}
		} else {
			output = VARIABLES.port;
		}

		return output;
	}


	public string function $getPassword () {
		return VARIABLES.password;
	}


	public struct function $getParams () {
		return {};
	}


	public string function $getProtocol () {
		return VARIABLES.protocol;
	}


	public string function $getUsername () {
		return VARIABLES.username;
	}


	public void function $setBasePath ( required string path ) {
		if ( Len( ARGUMENTS.path ) ) {
			VARIABLES.basePath = ARGUMENTS.path;
		}

		return;
	}


	public void function $setParams ( required struct params ) {
		var key = "";
		var value = "";

		for ( key in ARGUMENTS.params ) {
			value = ARGUMENTS.params[key];

			switch ( LCase(key) ) {
				case "base":
				case "basepath":
					if ( IsSimpleValue( value ) ) {
						$setBasePath( value );
					}
					break;

				case "host":
				case "hostname":
					if ( IsSimpleValue( value ) ) {
						$setHost( value );
					}
					break;

				case "pass":
				case "password":
					if ( IsSimpleValue( value ) ) {
						$setPassword( value );
					}
					break;

				case "port":
					if ( IsNumeric( value ) ) {
						$setPort( value );
					}
					break;

				case "protocol":
					if ( IsSimpleValue( value ) ) {
						$setProtocol( value );
					}
					break;

				case "user":
				case "username":
					if ( IsSimpleValue( value ) ) {
						$setUsername( value );
					}
					break;

				default:
					// Do nothing
					break;
			}
		}

		return;
	}


	public void function $setHost ( required string hostName ) {
		if ( Len( ARGUMENTS.hostName ) ) {
			VARIABLES.host = ARGUMENTS.hostName;
		}

		return;
	}


	public void function $setPassword ( required string pass ) {
		VARIABLES.password = ARGUMENTS.pass;

		return;
	}


	public void function $setPort ( required numeric portNumber ) {
		if ( ARGUMENTS.portNumber > 0 ) {
			VARIABLES.port = ARGUMENTS.portNumber;
		}

		return;
	}


	public void function $setProtocol ( required string protocol ) {
		if ( ListFind( "http,https", ARGUMENTS.protocol ) ) {
			VARIABLES.protocol = ARGUMENTS.protocol;
		}

		return;
	}


	public void function $setUsername ( required string user ) {
		VARIABLES.username = ARGUMENTS.user;

		return;
	}


	private void function _addAuthorization () {
		if (
				!StructKeyExists( VARIABLES.headers, "Authorization" )
				&& Len( $getUsername() )
				&& Len( $getPassword() )
		) {
			VARIABLES.headers[ "Authorization" ] = "Basic ";
			VARIABLES.headers.Authorization &= ToBase64(
				$getUsername()
				& ":"
				& $getPassword()
			);
		}

		return;
	}


	private void function _addCookies ( required http htService ) {
		if ( IsDefined( "VARIABLES.COOKIE_STORE.getCookies" ) ) {
			ARGUMENTS.htService.addCookies( VARIABLES.COOKIE_STORE.getCookies() );
		}

		return;
	}


	private void function _saveCookies ( required struct htResponseHeader ) {
		if ( IsDefined( "VARIABLES.COOKIE_STORE.saveCookies" ) ) {
			if ( StructKeyExists( ARGUMENTS.htResponseHeader, "Set-Cookie" ) ) {
				if ( IsStruct( ARGUMENTS.htResponseHeader[ "Set-Cookie" ] ) ) {
					VARIABLES.COOKIE_STORE.saveCookies( ARGUMENTS.htResponseHeader[ "Set-Cookie" ] );
				} else {
					VARIABLES.COOKIE_STORE.saveCookies( { 1=ARGUMENTS.htResponseHeader[ "Set-Cookie" ] } );
				}
			}
		}

		return;
	}


	private any function _sendRequest ( string method="GET", struct data=StructNew(), string path="" )
			hint="Generic private method for making REST requests. Called by functions whose name match HTTP methods."
	{
		var httpService=  new lib.http();
		var key=          "";
		var output=       {};

		_addAuthorization();

		httpService.setUrl( $getBaseUrl() & ARGUMENTS.path );
		httpService.setMethod( ARGUMENTS.method );
		httpService.addHeaders( VARIABLES.headers );
		_addCookies( httpService );

		if ( ARGUMENTS.method == "POST" || ARGUMENTS.method == "PUT" ) {
			httpService.setBody( ARGUMENTS.data );
			output = Duplicate( httpService.sendRequest() );
			_saveCookies( output.response.Header );
		} else {
			httpService.addQueryParams( ARGUMENTS.data );
			httpService.sendRequest();
			output = httpService.getRequest();
			_saveCookies( output.response.header );
		}

		// 20140626::dmcquiston - For some reason the result of an HTTP
		// POST doesn't allow setting keys in it. Still investigating
		// TODO: Invesgate why HTTP POSTs result struct doesn't allow
		// for modification
		try {
			output.url = $getBaseUrl() & ARGUMENTS.path;
			if ( StructKeyExists( output, "responseHeader" ) ) {
				output["response"] = {
					"header" = Duplicate( output.responseHeader )
				};
			}
		} catch (any e) {
			// Do noting for now. The URL is needed useful for debugging.
			//WriteDump( var="#output#", abort=true );
		}

		return output;
	}
}