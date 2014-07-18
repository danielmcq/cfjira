component name="Jira" implements="interface.webResponder" {

	public controller.Jira function init () {
		var jiraWs = new JiraProxy();

		VARIABLES["subtaskTypes"] = jiraWs.getSubTaskTypes();
		VARIABLES["requiredTasks"] = jiraWs.getRequiredIssueTypes();

		return THIS;
	}


	public string function htmlBody ( required struct webRequest ) {
		var output = "";
		var wr = ARGUMENTS.webRequest;
		var action = "";
		var bodyTemplate = "";

		action = REReplaceNoCase( wr.getUrl().action, "[^a-z_]*", "", "all" );

		if ( Len( action ) ) {
			bodyTemplate = "view/_" & action & ".cfm";
		}

		if ( FileExists( bodyTemplate ) ) {
			bodyTemplate = "../"&bodyTemplate;
			savecontent variable="output" { include bodyTemplate; }
		}

		return output;
	}


	public string function jsonResponse ( required struct webRequest ) returnformat="JSON" {
		var output = {};

		return SerializeJSON( output );
	}


	public string function xmlResponse ( required struct webRequest ) {
		var output = "";

		return output;
	}


	private any function getTaskCount ( required numeric id ) {
		var appConfig = APPLICATION.getConfig();
		var output = 1;

		if (
				StructKeyExists( appConfig, "template" )
				&& StructKeyExists( appConfig, "templates" )
				&& StructKeyExists( appConfig.templates, appConfig.template )
				&& StructKeyExists( appConfig.templates[ appConfig.template ], "tasks" )
				&& StructKeyExists( appConfig.templates[ appConfig.template ].tasks, ARGUMENTS.id )
				&& StructKeyExists( appConfig.templates[ appConfig.template ].tasks[ ARGUMENTS.id ], "count" )
		) {
			output = appConfig.templates[ appConfig.template ].tasks[ ARGUMENTS.id ].count;
		}

		return output;
	}


	private any function getTaskSummary ( required numeric id, required numeric tCount, required string summary ) {
		var appConfig = APPLICATION.getConfig();
		var output = "";
		var template = {};

		if (
				StructKeyExists( appConfig, "template" )
				&& StructKeyExists( appConfig, "templates" )
				&& StructKeyExists( appConfig.templates, appConfig.template )
				&& StructKeyExists( appConfig.templates[ appConfig.template ], "tasks" )
				&& StructKeyExists( appConfig.templates[ appConfig.template ].tasks, ARGUMENTS.id )
		) {
			template = appConfig.templates[ appConfig.template ].tasks[ ARGUMENTS.id ];

			if ( StructKeyExists( template, "defaultSummary" ) ) {
				output = template.defaultSummary;
			}

			if (
					StructKeyExists( template, "summaries" )
					&& IsArray( template.summaries )
					&& ARGUMENTS.tCount <= ArrayLen( template.summaries )
			) {
				output = template.summaries[ ARGUMENTS.tCount ];
			}
		} else {
			output = Trim( Replace( ARGUMENTS.summary, "Task", "" ) );
		}

		return output;
	}
}