component name="Jira" extends="model.rest" {
	public Jira function init () {
		SUPER.init();

		VARIABLES.COOKIE_STORE = SESSION.cookies.Jira;

		VARIABLES.helpers[ "DateTime" ] = new helper.DateTime();

		return THIS;
	}


	public struct function createChildIssue ( required string parentIdOrKey, required struct fields ) {
		var issue = {};
		var response = {};
		var data = { "fields" = ARGUMENTS.fields };

		data.fields[ "parent" ] = { "key" = ARGUMENTS.parentIdOrKey };

		response = post( path="issue", data=data );
		if ( IsStruct( response.Response.body ) ) {
			issue = response.Response.body;
		}

		return issue;
	}


	public struct function getIssue ( required string idOrKey, struct params="#{}#" ) {
		var issue = {};
		var response = {};

		if ( StructIsEmpty( ARGUMENTS.params ) ) {
			ARGUMENTS.params = {
				"fields"=   "summary,description,status,issuetype"
				,"expand"=  ""
			};
		}

		response = get( params=ARGUMENTS.params, path="issue/#ARGUMENTS.idOrKey#" );

		if ( IsStruct( response.Response.body ) ) {
			issue = response.Response.body;
		} else {
			issue = response;
		}

		return issue;
	}


	public array function getIssueTypes () {
		var output = [];
		var response = {};

		response = get( path="issuetype" );

		if ( IsArray( response.Response.body ) ) {
			output = response.Response.body;
		}

		return output;
	}


	public array function getChildIssues ( required string idOrKey, struct params="#{}#" ) {
		var issues = [];
		var response = {};

		params["jql"] = "parent=#ARGUMENTS.idOrKey#";

		response = get( params=params, path="search" );

		if ( IsStruct( response.Response.body ) && StructKeyExists( response.Response.body, "issues" ) ) {
			issues = response.Response.body.issues;
		}

		return issues;
	}


	public array function getIssueComments ( required string idOrKey ) {
		return get( path="issue/#ARGUMENTS.idOrKey#/comment" ).Response.body.comments;
	}


	public array function getWorklogs ( required string idOrKey ) {
		return get( path="issue/#ARGUMENTS.idOrKey#/worklog" ).Response.body.worklogs;
	}


	public struct function login ( required string username, required string password ) {
		var response = {};
		var data = {
			"username" = ARGUMENTS.username,
			"password" = ARGUMENTS.password
		};

		response = post( path="session", data=data );

		return response;
	}


	public struct function logout () {
		var response = {};

		response = delete( path="session" );

		return response;
	}


	public struct function getSession () {
		var response = {};

		response = get( path="session" );

		return response;
	}


	public struct function search ( numeric maxResults = 0 ) {
		var data = {
			"jql"=      _getJqlString( ArgumentCollection=ARGUMENTS )
			,"fields"=  "key"
		};
		var response = [];

		if ( ARGUMENTS.maxResults > 0 ) {
			data[ "maxResults" ] = ARGUMENTS.maxResults;
		}

		return _sendRequest( data=data, path="search" );
	}


	private string function _getJqlString ( date updateStartDate, date updateEndDate ) {
		var output = "";

		if ( IsDefined( "ARGUMENTS.updateStartDate" ) ) {
			//output &= " AND updated >= ";
			//output &= "'" & DateFormat( ARGUMENTS.updateStartDate, "yyyy-mm-dd " ) & TimeFormat( ARGUMENTS.updateStartDate, "HH:mm" ) & "'";
		}
		if ( IsDefined( "ARGUMENTS.updateEndDate" ) ) {
			//output &= " AND updated <= ";
			//output &= "'" & DateFormat( ARGUMENTS.updateEndDate, "yyyy-mm-dd " ) & TimeFormat( ARGUMENTS.updateEndDate, "HH:mm" ) & "'";
		}

		return output;
	}
}