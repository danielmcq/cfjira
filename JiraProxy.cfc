component name="JiraProxy" displayname="Jira Proxy Service" {
	if ( !StructKeyExists( VARIABLES, "initialized" ) ) {
		VARIABLES[ "initialized" ] = false;

		init();
	}



	public JiraProxy function init () {
		var initComplete = false;

		try {
			VARIABLES.APP_CONFIG = APPLICATION.getConfig();

			// Reference to the JIRA web service object.
			VARIABLES.oJira = new model.Jira();

			VARIABLES.env = getEnvironment();
			VARIABLES.template = getTemplate();

			VARIABLES.oJira.$setHost( VARIABLES.env.host );
			VARIABLES.oJira.$setPort( VARIABLES.env.port );
			VARIABLES.oJira.$setBasePath( VARIABLES.env.paths.base & VARIABLES.env.paths.main );

			initComplete = true;
		} catch ( any e ) {
			initComplete = false;
		}

		VARIABLES.initialized = initComplete;

		return THIS;
	}


	/**
	* @parentKey The parent key to assign the subtasks
	* @projectKey The key of the project that the issue should will belong to
	* @issueTypeId Issue type ID
	* @issueTypeName Issue type name
	* @summary Issue Summary
	* @description Issue Description
	*/
	remote string function createIssueSubTask (
		required string parentKey,
		required string projectKey,
		//required numeric issueTypeId,
		required string issueTypeName,
		required string summary//,
		//required string description
	)
		returnformat="JSON"
		hint="Create a new JIRA issue and return the ID for the newly created issue"
	{
		var fields = {
			"project" = {
				"key" = ARGUMENTS.projectKey
			},
			"summary" = ARGUMENTS.summary,
			"issuetype" = {
				//"id" = ARGUMENTS.issueTypeId
				"name" = ARGUMENTS.issueTypeName
			}
			//,"description" = ARGUMENTS.description
		};
		var output = "";
		var pc = GetPageContext().getResponse();

		output = VARIABLES.oJira.createChildIssue( parentIdOrKey=ARGUMENTS.parentKey, fields=fields );

		pc.setHeader( "Content-Type", "application/json" );

		return SerializeJSON( output );
	}


	public struct function getEnvironment ( string name="default" ) {
		var env = {
			"auth"= {
				"user"= "",
				"pass"= ""
			},
			"description"= "",
			"format"= "json",
			"host"= "localhost",
			"paths"= {
				"base"= "/rest",
				"main"= "/api/2/",
				"auth"= "/auth/2/"
			},
			"port"= 80,
			"title"= "",
			"type"= "rest"
		};
		var envKey = "";

		if (
			StructKeyExists( VARIABLES.APP_CONFIG, "datasource" )
			&& Len( VARIABLES.APP_CONFIG.datasource )
		) {
			envKey = VARIABLES.APP_CONFIG.datasource;
		} else {
			envKey = ARGUMENTS.name;
		}

		if ( StructKeyExists( VARIABLES.APP_CONFIG.datasources, envKey ) ) {
			env = Duplicate( VARIABLES.APP_CONFIG.datasources[ envKey ] );
		}

		return env;
	}


	remote string function getIssueByKey ( required string issuekey ) returnformat="JSON" {
		var issue = {};

		issue = VARIABLES.oJira.getIssue( ARGUMENTS.issueKey, { "fields"="summary,status,issuetype","expand"="" } );

		return SerializeJSON(issue);
	}


	public struct function getIssueTypes ( array filter = [] ) {
		var i = 0;
		var output = {};
		var response = [];

		response = VARIABLES.oJira.getIssueTypes();

		for ( i = 1; i <= ArrayLen(response); i++ ) {
			if ( !ArrayFind( ARGUMENTS.filter, response[i].id ) ) {
				output[response[i].id] = response[i];
			}
		}

		return output;
	}


	public struct function getProjects () {
		var projects = {};

		if ( StructKeyExists( VARIABLES.env, "projects" ) ) {
			projects = Duplicate( VARIABLES.env.projects );
		}

		return projects;
	}


	public array function getRequiredIssueTypes () {
		var output = [];

		if ( StructKeyExists( VARIABLES.template, "required" ) ) {
			output = VARIABLES.template.required;
		}

		return output;
	}


	public struct function getTemplate ( string name="default" ) {
		var template = {
			"required"= [],
			"typeFilter"= [],
			"tasks"= {}
		};
		var templateKey = "";

		if (
			StructKeyExists( VARIABLES.APP_CONFIG, "template" )
			&& Len( VARIABLES.APP_CONFIG.template )
		) {
			templateKey = VARIABLES.APP_CONFIG.template;
		} else {
			templateKey = ARGUMENTS.name;
		}

		if ( StructKeyExists( VARIABLES.APP_CONFIG.templates, templateKey ) ) {
			template = Duplicate( VARIABLES.APP_CONFIG.templates[ templateKey ] );
		}

		return template;
	}


	public void function setIssueType ( required string type ) {
		VARIABLES.pIssueType = ARGUMENTS.type;

		return;
	}


	public void function setVersion ( required string version ) {
		VARIABLES.pVersion = ARGUMENTS.version;

		return;
	}


	public void function setStatus ( required string status ) {
		VARIABLES.pStatus = ARGUMENTS.status;

		return;
	}


	remote string function login ( required string username, required string password ) returnformat="JSON" {
		var jiraAuth = new model.Jira();
		var output = "";
		var pc = GetPageContext().getResponse();

		jiraAuth.$setHost( VARIABLES.env.host );
		jiraAuth.$setPort( VARIABLES.env.port );
		jiraAuth.$setBasePath( VARIABLES.env.paths.base & VARIABLES.env.paths.auth );

		output = jiraAuth.login( ArgumentCollection=Arguments );

		pc.getResponse().setstatus( output.response.header["Status_Code"], output.response.header["Explanation"] );
		pc.setHeader( "Content-Type", "application/json" );

		return SerializeJSON( output );
	}


	remote string function logout () returnformat="JSON" {
		var jiraAuth = new model.Jira();
		var output = "";
		var pc = GetPageContext().getResponse();

		jiraAuth.$setHost( VARIABLES.env.host );
		jiraAuth.$setPort( VARIABLES.env.port );
		jiraAuth.$setBasePath( VARIABLES.env.paths.base & VARIABLES.env.paths.auth );

		output = jiraAuth.logout();

		pc.getResponse().setstatus( output.response.header["Status_Code"], output.response.header["Explanation"] );
		pc.setHeader( "Content-Type", "application/json" );

		return SerializeJSON( output );
	}


	remote string function getSession () returnformat="JSON" {
		var jiraAuth = new model.Jira();
		var output = "";
		var pc = GetPageContext().getResponse();

		jiraAuth.$setHost( VARIABLES.env.host );
		jiraAuth.$setPort( VARIABLES.env.port );
		jiraAuth.$setBasePath( VARIABLES.env.paths.base & VARIABLES.env.paths.auth );

		output = jiraAuth.getSession();

		pc.getResponse().setstatus( output.response.header["Status_Code"], output.response.header["Explanation"] );
		pc.setHeader( "Content-Type", "application/json" );

		return SerializeJSON( output );
	}


	public array function getSubTaskTypes ( array filter=[] ) {
		var key = "";
		var sortedTypes = [];
		var subtaskTypes = {};
		// TODO: Get rid of these hard-coded values
		var types = getIssueTypes( [24,20,27,26,5,11,37,22] );

		for ( key in types ) {
			if ( types[key].subtask ) {
				subtaskTypes[ types[key].name ] = Duplicate( types[key] );
			}
		}

		sortedTypes = StructKeyArray( subtaskTypes );
		ArraySort( sortedTypes, "text" );

		for ( key = 1; key <= ArrayLen( sortedTypes ); key++ ) {
			sortedTypes[ key ] = subtaskTypes[ sortedTypes[ key ] ];
		}

		return sortedTypes;
	}


	remote string function getSubTasksByIssue ( required numeric issueId ) returnformat="JSON" {
		var issues = VARIABLES.oJira.getChildIssues(
			ARGUMENTS.issueId,
			{
				"fields"="summary,status,issuetype",
				"expand"=""
			}
		);

		return SerializeJSON( issues );
	}


	remote string function getIssuesByComponent ( string projectIdOrKey="" ) returnformat="JSON" {
		var issues = {};
		var jql = "";
		var response = {};

		if ( Len( ARGUMENTS.projectIdOrKey ) ) {
			jql &= "project=" & ARGUMENTS.projectIdOrKey;
		}

		response = VARIABLES.oJira.search( jql=jql, fields="summary,components,status" );

		issues = response.response.body;

		return SerializeJSON( issues );
	}


	remote string function getFixVersion ( required string issueIdsOrKeys ) returnformat="JSON" {
		var issues = {};
		var jql = "";
		var response = {};

		if ( Len( ARGUMENTS.issueIdsOrKeys ) ) {
			jql &= "issue IN (" & ARGUMENTS.issueIdsOrKeys & ")";

			response = VARIABLES.oJira.search( jql=jql, fields="fixVersions" );

			issues = response.response.body;
		}

		return SerializeJSON( issues );
	}


	remote string function getIssuesByLabel ( array statusFilter=[], array projectIdsOrKeys=[], array typeFilter=[] ) returnformat="JSON" {
		var issues = {};
		var jql = [];
		var response = {};

		if ( ArrayLen( ARGUMENTS.statusFilter ) ) {
			ArrayAppend( jql, "status IN (" & ArrayToList( ARGUMENTS.statusFilter ) & ")" );
		}

		if ( ArrayLen( ARGUMENTS.projectIdsOrKeys ) ) {
			ArrayAppend( jql, "project IN (" & ArrayToList( ARGUMENTS.projectIdsOrKeys ) & ")" );
		}

		if ( ArrayLen( ARGUMENTS.typeFilter ) ) {
			ArrayAppend( jql, "type IN (" & ArrayToList( ARGUMENTS.typeFilter ) & ")" );
		}

		response = VARIABLES.oJira.search( jql=ArrayToList( jql, " AND " ), fields="labels,status,project,type" );
		issues = response.response.body;

		return SerializeJSON( issues );
	}


	remote string function getIssuesByType ( required array typeFilter ) returnformat="JSON" {
		var issues = {};
		var jql = [];
		var response = {};

		if ( ArrayLen( ARGUMENTS.typeFilter ) ) {
			ArrayAppend( jql, "type IN (" & ArrayToList( ARGUMENTS.typeFilter ) & ")" );
		}

		response = VARIABLES.oJira.search( jql=ArrayToList( jql, " AND " ), fields="status,project,type" );
		issues = response.response.body;

		return SerializeJSON( issues );
	}


	remote string function getIssueComments ( required string idOrKey ) returnformat="JSON" {
		var issue = {};

		issue = VARIABLES.oJira.getIssueComments( ARGUMENTS.idOrKey );

		return SerializeJSON(issue);
	}


	remote string function getIssueLinks ( required string idOrKey ) returnformat="JSON" {
		var issue = {};

		issue = VARIABLES.oJira.getIssueLinks( ARGUMENTS.idOrKey );

		return SerializeJSON(issue);
	}


	remote string function getIssuesByFixVersions ( required array fixVersions=[] ) returnformat="JSON" {
		var issues = {};
		var jql = [];
		var response = {};

		if ( ArrayLen( ARGUMENTS.fixVersions ) ) {
			ArrayAppend( jql, "fixVersion IN (" & ArrayToList( ARGUMENTS.fixVersions ) & ")" );
		}

		response = VARIABLES.oJira.search( jql=ArrayToList( jql, " AND " ), fields="status,project,type,fixVersions" );
		issues = response.response.body;

		return SerializeJSON( issues );
	}


	remote string function getFixVersionsByProject ( required string projectIdOrKey ) returnformat="JSON" {
		var fixVersions = [];

		fixVersions = VARIABLES.oJira.getFixVersionsByProject( ARGUMENTS.projectIdOrKey );

		return SerializeJSON( fixVersions );
	}


	remote string function getIssueLabels ( required string idOrKey ) returnformat="JSON" {
		var labels = [];

		labels = VARIABLES.oJira.getIssueLabels( ARGUMENTS.idOrKey );

		return SerializeJSON( labels );
	}


	remote string function getCustomFieldValue ( required string customFieldId, required string issueIdOrKey ) returnformat="JSON" {
		var issue = {};
		var output = "";

		issue = VARIABLES.oJira.getIssue( idOrKey=ARGUMENTS.issueIdOrKey, params={ "fields"="customfield_#ARGUMENTS.customFieldId#" } );
output = issue;

		return SerializeJSON( output );
	}
}