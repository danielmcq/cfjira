<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#">Jira Tools</a>
		</div>

		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<form class="navbar-form navbar-right" name="authenticateForm" id="authenticateForm" role="form">
				<div class="form-group">
					<input
						type="username"
						class="form-control input-sm"
						id="username"
						name="username"
						placeholder="Jira Username"
						autocomplete="off"
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
						autocomplete="off"
						placeholder="Jira Password"
						required
					>
				</div>
				<input type="hidden" name="isAuthenticated" id="isAuthenticated" value="false">
				<button class="btn btn-success btn-sm" id="login" type="submit">Jira Login</button>
				<button class="btn btn-success btn-sm" id="logout" type="button">Jira Logout</button>
			</form>
			<span class="navbar-right navbar-text" id="loggedInUser">
				Logged in as: <span class="name"></span>
			</span>
			<span class="navbar-text">
				Environment:
				<cfoutput><a href="http://#appConfig.datasources[ appConfig.datasource ].host#:#appConfig.datasources[ appConfig.datasource ].port#/" class="alert-link datasource-url" target="_blank">
					<span class="datasource-title">#appConfig.datasources[ appConfig.datasource ].title#</span>
				</a></cfoutput>
			</span>
		</div>

		<div class="panel panel-primary">
			<div class="panel-body">
				<form method="post" action="#" class="" name="parentIssueForm" id="parentIssueForm" role="search">
					<span class="input-group">
						<span class="input-group-btn">
							<button class="btn btn-primary btn-sm" type="button">Find Parent Issue</button>
						</span>
						<input type="search" class="form-control input-sm" id="parentKey" name="parentKey" value="" autocomplete="off" placeholder="XXX-#####">
					</span>
				</form>

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

<div class="container">
	<ul class="list-group" id="subTasks">
	<cfloop array="#subtaskTypes#" index="type">
	<cfoutput>
		<li id="taskrow_#type.id#" class="collapse list-group-item taskrow task_#type.id#<cfif ArrayFind( requiredTasks, type.id )> required</cfif>" x-jira-issue-type="#type.id#">
			<img src="#type.iconUrl#" title="#type.name#">
			<a href="##type-group-#type.id#" data-toggle="collapse" data-parent="##taskrow_#type.id#">
				#type.name#
			</a>
			<cfif ArrayFind( requiredTasks, type.id )>
			<span class="task-counts">
				<span class="badge" title="Number of tasks already created for this type">0</span>
				/ <span class="badge<cfif ArrayFind( requiredTasks, type.id )> alert-danger<cfelse> alert-success</cfif>" title="Number of required tasks for this type">#getTaskCount(type.id)#</span>
			</span>
			</cfif>
			<ul class="list-group list-collapse collapse in" id="type-group-#type.id#">
			<cfloop from="1" to="#getTaskCount(type.id)#" index="i">
				<li class="list-group-item">
					<input type="hidden" id="issueTypeVal_#type.id#_#i#" value="#type.id#">
					<div class="input-group input-group-sm">
						<span class="input-group-addon">
							<input
								type="checkbox"
								id="issueType_#type.id#"
								name="issueType_#type.id#"
								value="#type.id#_#i#"
								class="issueType_#type.id#"
							>
						</span>
						<input
							class="form-control"
							type="text"
							id="summary_#type.id#_#i#"
							name="summary_#type.id#"
							value="#getTaskSummary(type.id,i,type.name)#"
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