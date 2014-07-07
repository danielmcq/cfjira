component name="Cookie" hint="Cookie Helper Class" {
	VARIABLES[ "data" ] = {};


	public Cookie function init ( string lockScope="APPLICATION" ) {
		VARIABLES["scope"] = ARGUMENTS.lockScope;

		return THIS;
	}


	public struct function getCookie ( required string name ) {
		return _getCookie( ARGUMENTS.name );
	}


	public struct function getCookies () {
		return _getCookies();
	}


	public void function saveCookies ( required struct cookies ) {
		_setCookies( _parseCookieHeader( ARGUMENTS.cookies ) );

		return;
	}


	private struct function _getCookie ( required string name ) {
		var cookie = {};

		lock
			scope=    VARIABLES.scope
			type=     "readOnly"
			timeout=  5
		{
			if ( StructKeyExists( VARIABLES.data, ARGUMENTS.name ) ) {
				cookie = Duplicate( VARIABLES.data[ ARGUMENTS.name ] );
			}
		}

		return cookie;
	}


	private struct function _getCookies () {
		var cookies = {};

		lock
			scope=    VARIABLES.scope
			type=     "readOnly"
			timeout=  5
		{
			cookies = Duplicate( VARIABLES.data );
		}

		// Return snapshot of cookies when this function is called.
		return cookies;
	}


	private void function _setCookies ( required struct cookies ) {
		var key = "";

		lock
			scope=    VARIABLES.scope
			type=     "Exclusive"
			timeout=  5
		{
			// Instead of just copying the struct, only update new cookies
			for ( key in ARGUMENTS.cookies ) {
				VARIABLES.data[ key ] = ARGUMENTS.cookies[ key ];
			}
		}

		return;
	}


	private struct function _parseCookieHeader ( required struct cookieHeader ) {
		var aCookie=   [];
		var cookie=    {};
		var cookies=   {};
		var data=      "";
		var dataKey=   "";
		var dataVal=   "";
		var i=         0;
		var key=       "";

		// Loop over the Set-Cookie header
		for ( key in ARGUMENTS.cookieHeader ) {
			// Convert to array for easy looping over properties
			aCookie = ListToArray( ARGUMENTS.cookieHeader[ key ], ";" );

			// Setup cookie cutter template
			cookie = {
				"name"=       ""
				,"Domain"=    ""
				,"Expires"=   "Session"
				,"Secure"=    false
				,"HttpOnly"=  false
				,"Max-Age"=   ""
				,"Path"=      ""
				,"Version"=   ""
				,"value"=     ""
			};

			// Loop over data in cookie
			for ( i = 1; i <= ArrayLen( aCookie ); i++ ) {
				data = aCookie[i];
				dataKey = Trim( ListFirst( data, "=" ) );
				dataVal = Trim( ListLast( data, "=" ) );

				switch ( LCase( dataKey ) ) {
					// Set non-boolean cookie properties
					case "domain":
					case "expires":
					case "max-age":
					case "path":
					case "version":
						cookie[ dataKey ] = dataVal;
						break;
					// Set boolean cookie properties
					case "httponly":
					case "secure":
						cookie[ dataKey ] = true;
						break;
					// Assuming all keys are known and the name-value pair comes first, set cookie name and value
					default:
						if ( dataKey != "" && cookie.name == "" ) {
							cookie.name = dataKey;
							cookie.value = dataVal;
						}
				}
			}

			// If we got a valid cookie, save it in struct. Struct used to make it easier to search for specific cookie
			if ( cookie.name != "" ) {
				// Get a copy of the cookie struct we built and save
				cookies[ cookie.name ] = Duplicate( cookie );
			}
		}

		return cookies;
	}
}