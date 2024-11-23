def jiraconfig = execution.getVariable("jiraconfig");

jiraconfig.jiraTransitionId = 311;
jiraconfig.jiraTransitionComment = "automatically starting via Concord";

def transitionFields = [:]

jiraconfig.jiraTransitionFields = transitionFields
