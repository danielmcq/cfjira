component name="JiraWS" displayname="Jira Web Service"
		hint="Acts as a middle man if the Access-Control-Allow-Origin header cannot be set in Jira."
{
	// Set Application properties.
	THIS[ "Name" ]                = "JiraWS";
	THIS[ "ApplicationTimeout" ]  = CreateTimeSpan( 0, 0, 20, 0 );
	THIS[ "SessionManagement" ]   = true;
	THIS[ "SessionTimeout" ]      = CreateTimeSpan( 0, 0, 15, 0 );
	THIS[ "SetClientCookies" ]    = false;
	THIS[ "Mappings" ]            = {
		"/controller"  = ExpandPath( "./controller" )
		,"/helper"     = ExpandPath( "./helper" )
		,"/interface"  = ExpandPath( "./interface" )
		,"/lib"        = ExpandPath( "./lib" )
		,"/model"      = ExpandPath( "./model" )
	};


	// Number in seconds to timeout Application Locks
	VARIABLES.LOCK_TIMEOUT              = 5;


	public boolean function OnApplicationStart()
			hint="Runs once the first time the app runs after a timeout, the name is changed, or the ColdFusion service restarts."
	{
		lock
			scope    = "APPLICATION"
			type     = "Exclusive"
			timeout  = getLockTimeout()
		{
			// Nested struct of configuration settings
			APPLICATION[ "config" ]          = {};
			APPLICATION[ "getLockTimeout" ]  = getLockTimeout;
			// Make the getName() method accessible globally
			APPLICATION[ "getName" ]         = getName;
		}

		return true;
	}


	public void function OnSessionStart () {
		SESSION["cookies"] = {"Jira" = new helper.Cookie("SESSION")};

		return;
	}


	public void function OnRequest ( required string TargetPage )
			hint="Fires once per page request into this app."
	{
		param name="URL.format"  default="html";
		param name="URL.mode"    default="createSubTasks";

		var htmlBody      = "";
		var bodyTemplate  = "";

		// Modes can only contain letters and underscores
		URL.mode = REReplaceNoCase( URL.mode, "[^a-z_]*", "", "all" );

		if ( URL.format == "json" || _getRequestedDataType( GetHttpRequestData().headers ) == "application/json" ) {
			_jsonResponse( { "baseUrl"="jiraSvc.cfc" } );
		} else {
			if ( Len( URL.mode ) ) {
				bodyTemplate = "view/_" & URL.mode & ".cfm";
			}

			if ( FileExists( bodyTemplate ) || FileExists( ExpandPath( bodyTemplate ) ) ) {
				savecontent variable="htmlBody" { include bodyTemplate; }
			}

			_htmlResponse( htmlBody );
		}

		return;
	}


	public numeric function getLockTimeout () {
		return VARIABLES.LOCK_TIMEOUT;
	}


	public string function getName ()
			hint="Returns the name of the current app instance."
	{
		return APPLICATION.GetApplicationSettings().Name;
	}


	private void function _addResponseHeader ( required string name, required string value ) {
		// This works in Adobe ColdFusion 9, but not sure about Railo and other variants/versions.
		var pc = GetPageContext().getresponse();

		pc.setHeader( ARGUMENTS.name, ARGUMENTS.value );

		return;
	}


	private string function _applyHtmlTemplate ( string body="", string templateName = "index.cfm" ) {
		var output = "";

		if ( FileExists( ARGUMENTS.templateName ) || FileExists( ExpandPath( ARGUMENTS.templateName ) ) ) {
			savecontent variable="output" { include ARGUMENTS.templateName; }
		}

		return output;
	}


	private void function _clearTemplateCache ( required string pass ) {
		var rtService = new cfide.adminapi.runtime();

		rtService.login( ARGUMENTS.pass );
		rtService.clearTrustedCache();

		return;
	}


	private string function _getRequestedDataType ( required struct headers ) {
		var acceptHeader  = "";
		var type          = "";

		if ( StructKeyExists( ARGUMENTS.headers, "Accept" ) ) {
			acceptHeader = ListFirst( ARGUMENTS.headers.Accept, ";" );

			type = ListFirst( acceptHeader );
		}

		return type;
	}


	private void function _jsonResponse ( required any data ) {
		_addResponseHeader( "X-App_name",    APPLICATION.getName() );
		_addResponseHeader( "X-Request_at",  DateFormat( Now(), "yyyy-mm-dd " ) & TimeFormat( Now(), "HH:mm:ss" ) );
		_addResponseHeader( "Content-Type",  "application/json" );

		WriteOutput( SerializeJson( ARGUMENTS.data ) );

		return;
	}


	private void function _htmlResponse ( string body="" ) {
		WriteOutput( _applyHtmlTemplate( ARGUMENTS.body ) );

		return;
	}


}