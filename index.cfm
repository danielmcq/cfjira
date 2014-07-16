<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Jira Tools</title>

	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
	<link rel="stylesheet" media="screen" href="css/main.css">

	<!--[if lt IE 9]>
		<script src="//oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
		<script src="//oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
	<![endif]-->

	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<script src="js/main.js"></script>
</head>
<body>
<div class="container-fluid">
	<div id="environment-notice" class="alert alert-warning fade in">
		<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		<h1 class="text-center">TESTING</h1>
		<span>
			Currently pointed to
			<cfoutput><a href="http://#appConfig.datasources[ appConfig.datasource ].host#:#appConfig.datasources[ appConfig.datasource ].port#/" class="alert-link" target="_blank">
				#appConfig.datasources[ appConfig.datasource ].title#
			</a></cfoutput>
		</span>
	</div>
</div>
<cfoutput>#ARGUMENTS.body#</cfoutput>
<script>$(document).ready(jrt.init);</script>
</body>
</html>