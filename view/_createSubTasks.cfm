<cfscript>
	private any function getTaskCount ( required numeric id ) {
		var TASK_COUNTS = {
			"29"  = 4,
			"12"  = 2
		};
		var rCount = 1;

		if ( StructKeyExists( TASK_COUNTS, Arguments.id ) ) {
			rCount = TASK_COUNTS[Arguments.id];
		}

		return rCount;
	}


	private any function getTaskSummary ( required numeric id, required numeric tCount, required string summary ) {
		var rSummary = "";

		switch ( Arguments.id ) {
			case "12":
				if ( Arguments.tCount == 1 ) {
					rSummary = "Create Test Case";
				} else if ( Arguments.tCount == 2 ) {
					rSummary = "Execute Test Case";
				}

				break;
			case "2":
			case "29":
				// Do nothing. Blank summary
				break;
			default:
				rSummary = Trim(Replace(Arguments.summary,'Task',''));
				break;
		}

		return rSummary;
	}

	jiraWs         = new jiraSvc();
	subtaskTypes   = jiraWs.getSubTaskTypes();
	requiredTasks  = jiraWs.getRequiredIssueTypes();
</cfscript>
<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="?createSubTasks">Jira Issue Subtask Creator</a>
		</div>

		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<form method="post" action="#" class="navbar-form navbar-left" name="parentIssueForm" id="parentIssueForm" role="search">
				<button class="btn btn-primary btn-sm" type="button">Find Parent Issue</button>
				<div class="form-group">
					<input type="text" class="form-control input-sm" id="parentKey" name="parentKey" value="" autocomplete="off"  placeholder="XXX-#####">
				</div>
			</form>

			<form class="navbar-form navbar-right" name="authenticateForm" id="authenticateForm" role="form">
				<span class="navbar-text" id="loggedInUser">
					Logged in as: <span class="name"></span>
				</span>
				<div class="form-group">
					<input
						type="username"
						class="form-control input-sm"
						id="username"
						name="username"
						placeholder="Jira Username"
						required
						autofocus
					>
				</div>
				<div class="form-group">
					<input
						type="password"
						class="form-control input-sm"
						type="password"
						id="pwd"
						name="password"
						placeholder="Jira Password"
						required
					>
				</div>
				<input type="hidden" name="isAuthenticated" id="isAuthenticated" value="false">
				<button class="btn btn-success btn-sm" id="login" type="submit">Jira Login</button>
				<button class="btn btn-success btn-sm" id="logout" type="button">Jira Logout</button>
			</form>
		</div>

		<div class="panel panel-primary">
			<div class="panel-heading">
				Parent Issue:
			</div>
			<div class="panel-body">
				<span id="issueStatus"></span>
				<span id="issueSummary">No Parent Issue Selected</span>
			</div>
		</div>

		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<button type="button" class="btn btn-success navbar-btn btn-sm" id="createTasksButton" >Create SubTasks</button>
			<button type="button" class="btn btn-default navbar-btn btn-sm"
					data-toggle="collapse"
					data-parent=".taskrow"
					data-target=".list-group.list-collapse"
			>
				Collapse/Expand All
			</button>
			<button type="button" class="btn btn-default navbar-btn btn-sm" id="checkAll"          >Check All</button>
			<button type="button" class="btn btn-default navbar-btn btn-sm" id="checkRequired"     >Check Required</button>
			<button type="button" class="btn btn-default navbar-btn btn-sm" id="clear"             >Reset</button>
		</div>
	</div>
</nav>

<div class="container-fluid">
	<div class="row">
		<div class="col-md-6">
			<span class="bg-danger">* missing required tasks</span>
			<span class="bg-success">* has required tasks</span>
		</div>
	</div>
	<ul class="list-group" id="subTasks">
	<cfloop collection="#subtaskTypes#" item="type">
	<cfoutput>
		<li id="taskrow_#subtaskTypes[type].id#" class="collapse list-group-item taskrow task_#subtaskTypes[type].id#<cfif ArrayFind( requiredTasks, subtaskTypes[type].id )> required list-group-item-danger</cfif>" x-jira-issue-type="#subtaskTypes[type].id#">
			<img src="#subtaskTypes[type].iconUrl#" title="#subtaskTypes[type].name#">
			<a href="##type-group-#subtaskTypes[type].id#" data-toggle="collapse" data-parent="##taskrow_#subtaskTypes[type].id#">
				#subtaskTypes[type].name#<cfif ArrayFind( requiredTasks, subtaskTypes[type].id )>*</cfif>
				<span class="badge">0</span>
			</a>
			<ul class="list-group list-collapse collapse in" id="type-group-#subtaskTypes[type].id#">
			<cfloop from="1" to="#gettaskCount(subtaskTypes[type].id)#" index="i">
				<li class="list-group-item">
					<input type="hidden" id="issueTypeVal_#subtaskTypes[type].id#_#i#" value="#subtaskTypes[type].id#">
					<div class="input-group input-group-sm<cfif ArrayFind( requiredTasks, subtaskTypes[type].id )> has-error</cfif>">
						<span class="input-group-addon">
							<input
								type="checkbox"
								id="issueType_#subtaskTypes[type].id#"
								name="issueType_#subtaskTypes[type].id#"
								value="#subtaskTypes[type].id#_#i#"
								class="issueType_#subtaskTypes[type].id#"
							>
						</span>
						<input
							class="form-control"
							type="text"
							id="summary_#subtaskTypes[type].id#_#i#"
							name="summary_#subtaskTypes[type].id#"
							value="#getTaskSummary(subtaskTypes[type].id,i,subtaskTypes[type].name)#"
							maxlength="255"
						>
					</div>
				</li>
			</cfloop>
			</ul>
		</li>
	</cfoutput>
	</cfloop>
	</ul>
</div>

<style>@import url('css/createSubTasks.css');</style>
<script src="js/createSubTasks.js"></script>