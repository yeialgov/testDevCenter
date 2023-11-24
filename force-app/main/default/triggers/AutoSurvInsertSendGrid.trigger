trigger AutoSurvInsertSendGrid on AutomatedSurvey__c (after insert) {
    AutoSurvInsertSendGridHelper.send(json.serialize(trigger.new));
}