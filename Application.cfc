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
	VARIABLES.LOCK_TIMEOUT = 5;


	public boolean function OnApplicationStart()
			hint="Runs once the first time the app runs after a timeout, the name is changed, or the ColdFusion service restarts."
	{
		lock
			scope    = "APPLICATION"
			type     = "Exclusive"
			timeout  = VARIABLES.LOCK_TIMEOUT
		{
			// Configuration related variables and methods
			APPLICATION[ "config" ]          = {};
			APPLICATION[ "getConfig" ]       = getConfig;
			APPLICATION[ "setConfig" ]       = setConfig;
			APPLICATION[ "getLockTimeout" ]  = getLockTimeout;
			// Make the getName() method accessible globally
			APPLICATION[ "getName" ]         = getName;
		}
		_loadConfig ( APPLICATION.config, "APPLICATION" );

		return true;
	}


	public void function OnSessionStart () {
		SESSION["cookies"] = {"Jira" = new helper.Cookie( lockScope="SESSION" )};

		return;
	}


	public void function OnRequest ( required string TargetPage )
			hint="Fires once per page request into this app."
	{
		param name="URL.format"        default="html";
		param name="URL.mode"          default="Jira";
		param name="URL.action"        default="createSubTasks";
		param name="URL.reloadConfig"  default="false";

		var htmlBody      = "";
		var webHandler = {};
		var webMode = "";
		var wr = {};

		// Dynamically reload the config from files.
		if ( URL.reloadConfig ) {
			_loadConfig ( APPLICATION.config, "APPLICATION" );
		}

		if ( URL.format == "json" || _getRequestedDataType( GetHttpRequestData().headers ) == "application/json" ) {
			_jsonResponse( { "baseUrl"="JiraProxy.cfc" } );
		} else {
			if ( FileExists( "controller/"&URL.mode&".cfc" ) || FileExists( ExpandPath( "controller/"&URL.mode&".cfc" ) ) ) {
				// Modes can only contain letters and underscores
				URL.mode = REReplaceNoCase( URL.mode, "[^a-z_]*", "", "all" );
				webMode = "controller."&URL.mode;
				webHandler = new "#webMode#"();

				wr = new model.webRequest();
				wr.setHeaders( Duplicate( GetHttpRequestData().headers ) );
				wr.setUrl( Duplicate( URL ) );
				wr.setForm( Duplicate( FORM ) );
				wr.setTemplate( ARGUMENTS.TargetPage );

				htmlBody = webHandler.htmlBody( wr );
			}

			_htmlResponse( htmlBody );
		}

		return;
	}


	public struct function getConfig ( string path="" ) {
		var config = {};
		var key = "";

		lock
			scope    = "APPLICATION"
			type     = "ReadOnly"
			timeout  = 5
		{
			config = Duplicate( APPLICATION.config );
		}

		if ( Len( ARGUMENTS.path ) ) {

		}

		return config;
	}


	public numeric function getLockTimeout () {
		return VARIABLES.LOCK_TIMEOUT;
	}


	public string function getName ()
			hint="Returns the name of the current app instance."
	{
		return APPLICATION.GetApplicationSettings().Name;
	}


	public void function setConfig () {
		// TODO: Code this functionality. Make sure to update the variable in
		// memory as well as write changes to the file.

		return;
	}


	private void function _addResponseHeader ( required string name, required string value ) {
		// This works in Adobe ColdFusion 9, but not sure about Railo and other variants/versions.
		var pc = GetPageContext().getresponse();

		pc.setHeader( ARGUMENTS.name, ARGUMENTS.value );

		return;
	}


	private string function _applyHtmlTemplate ( string body="", string templateName = "index.cfm" ) {
		var appConfig = getConfig();
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


	private void function _loadConfig ( required struct config, string lockScope="APPLICATION" ) {
		var FILENAME_CONFIG_DEFAULT = "settings.default.json";
		var FILENAME_CONFIG = "settings.json";
		var ERROR_DEFAULT_CONFIG_NOT_FOUND = "The default configuration file '" & FILENAME_CONFIG_DEFAULT & "' is not found or accessible in the directory of Application.cfc";
		var ERROR_GENERAL = "Error loading settings";
		var ERROR_INCORRECT_FORMAT = "Settings file cannot be parsed as JSON";
		var ERROR_TYPE = "Settings";

		var error = "";
		var fileContents = "";
		var key = "";
		var settings = {};

		try {
			// Make sure the default config exists first. This is the base of
			// the settings for the application.
			if ( FileExists( ExpandPath( FILENAME_CONFIG_DEFAULT ) ) ) {
				fileContents = FileRead( ExpandPath( FILENAME_CONFIG_DEFAULT ) );

				// Make sure the config file is properly formatted.
				if ( IsJSON( fileContents ) ) {
					settings = DeserializeJSON( fileContents );

					lock
						scope    = ARGUMENTS.lockScope
						type     = "Exclusive"
						timeout  = getLockTimeout()
					{
						StructAppend( ARGUMENTS.config, settings, true );
					}
				} else {
					error = ERROR_INCORRECT_FORMAT;
				}
			} else {
				error = ERROR_DEFAULT_CONFIG_NOT_FOUND;
			}

			if ( !Len( error ) ) {
				// Check to see if settings file doesn't exist
				if ( !FileExists( ExpandPath( FILENAME_CONFIG ) ) ) {
					FileCopy( ExpandPath( FILENAME_CONFIG_DEFAULT ), ExpandPath( FILENAME_CONFIG ) );
				} else {
					fileContents = FileRead( ExpandPath( FILENAME_CONFIG ) );

					if ( IsJSON( fileContents ) ) {
						settings = DeserializeJSON( fileContents );

						lock
							scope    = ARGUMENTS.lockScope
							type     = "Exclusive"
							timeout  = getLockTimeout()
						{
							StructAppend( ARGUMENTS.config, settings, true );
						}
					}
				}
			}
		} catch ( any e ) {
			// Do nothing for now
		}

		if ( Len( error ) ) {
			Throw( type=ERROR_TYPE, message=ERROR_GENERAL, detail=error );
		}

		return;
	}


}