component name="http" extends="com.adobe.coldfusion.http"
		hint="Wrapper class for the built in HTTP object."
{
	VARIABLES.COOKIE_STORE=   {};
	VARIABLES.HTTP_STATUS=    {
		"OK"=  200
	};



	public any function init () {
		VARIABLES[ "helpers" ]=   {};
		VARIABLES[ "request" ]=   {
			"cookies"=       {}
			,"data"=         ""
			,"headers"=      {}
			,"queryParams"=  {}
			,"response"=     {
				"body"=      ""
				,"cookies"=  {}
				,"header"=   {}
			}
			,"url"=          ""
		};

		VARIABLES.helpers[ "XML" ] = new helper.XML();

		return SUPER.init( ArgumentCollection=ARGUMENTS );
	}


	public void function addCookie ( required struct cookie ) {
		THIS.addParam( type="cookie", name=ARGUMENTS.cookie.name, value=ARGUMENTS.cookie.value );
		VARIABLES.request.cookies[ ARGUMENTS.cookie.name ] = ARGUMENTS.cookie.value;

		return;
	}


	public void function addCookies ( required struct cookies ) {
		var key = "";

		for ( key in ARGUMENTS.cookies ) {
			addCookie( ARGUMENTS.cookies[ key ] );
		}

		return;
	}


	public void function addHeader ( required struct header ) {
		THIS.addParam( type="header", name=ARGUMENTS.header.name, value=ARGUMENTS.header.value );
		VARIABLES.request.headers[ ARGUMENTS.header.name ] = ARGUMENTS.header.value;

		return;
	}


	public void function addHeaders ( required struct headers ) {
		var key = "";

		for ( key in ARGUMENTS.headers ) {
			addHeader({ name=key, value=ARGUMENTS.headers[ key ] });
		}

		return;
	}


	public void function addQueryParam ( required struct queryParam ) {
		THIS.addParam( type="URL", name=ARGUMENTS.queryParam.name, value=ARGUMENTS.queryParam.value );
		VARIABLES.request.queryParams[ ARGUMENTS.queryParam.name ] = ARGUMENTS.queryParam.value;

		return;
	}


	public void function addQueryParams ( required struct queryParams ) {
		var key = "";

		for ( key in ARGUMENTS.queryParams ) {
			addQueryParam({ name=key, value=ARGUMENTS.queryParams[ key ] });
		}

		return;
	}


	public struct function getRequest () {
		return Duplicate( VARIABLES.request );
	}


	public struct function sendRequest () {
		var httpResponse = {};

		httpResponse = THIS.send().getPrefix( ArgumentCollection=ARGUMENTS );

		VARIABLES.request.response.header = httpResponse.ResponseHeader;

		if (
				StructKeyExists( httpResponse.ResponseHeader, "Status_code" )
				//&& httpResponse.ResponseHeader.Status_code == VARIABLES.HTTP_STATUS.OK
				&& StructKeyExists( httpResponse, "Filecontent" )
		) {
			if (
					StructKeyExists( httpResponse.ResponseHeader, "Content-Type" )
					&& FindNoCase( "application/json", httpResponse.ResponseHeader[ "Content-Type" ] )
					&& IsJSON( httpResponse.Filecontent.toString() )
			) {
				VARIABLES.request.response.body = DeserializeJson( httpResponse.Filecontent.toString() );
			} else if (
					StructKeyExists( httpResponse.ResponseHeader, "Content-Type" )
					&& FindNoCase( "xml", httpResponse.ResponseHeader[ "Content-Type" ] )
					&& IsXml( httpResponse.Filecontent.toString() )
			) {
				VARIABLES.request.response.body = VARIABLES.helpers.XML.toStruct( httpResponse.Filecontent.toString() );
			} else {
				VARIABLES.request.response.body = httpResponse.Filecontent.toString();
			}
		}

		return Duplicate(VARIABLES.request);
	}


	public struct function getResponseCookies () {
		var cookies = {};

		return cookies;
	}


	public void function setBody ( required struct data ) {
		if ( StructKeyExists( VARIABLES.request.headers, "Content-Type" ) && VARIABLES.request.headers[ "Content-Type" ] == "application/json" ) {
			THIS.addParam( type="body", value="#SerializeJson( Duplicate( ARGUMENTS.data ) )#" );
		} else {
			THIS.addParam( type="body", value=Duplicate( ARGUMENTS.data ) );
		}
		VARIABLES.request.data = ARGUMENTS.data;

		return;
	}


	private void function _parseResponseCookies () {
		return;
	}


}