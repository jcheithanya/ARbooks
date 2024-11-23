def jiraconfig = execution.getVariable("jiraconfig");
jiraconfig.jiraSummary = "BackupAutomation".toString();

jiraconfig.jiraDescription = "request for SQL Server backup with following details:\n" +
        "* *Job ID*: ${sqlaccess.runbookJobId}\n" +
        "* *ServerName*: ${sqlaccess.argServerName}\n" +
        "* *Database*: ${sqlaccess.argDatabase}\n"

