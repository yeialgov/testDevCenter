trigger AutoSurveyInsert on AutomatedSurvey__c (after insert) {

    Set<Id> idSet = new Set<Id>();
    for (AutomatedSurvey__c ausu : trigger.new) {
        idSet.add(ausu.Id);
    }
    List<AutomatedSurvey__c> ASs = [
        SELECT Id, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, Contact__r.Account.PrimaryLanguage__c
        FROM AutomatedSurvey__c
        WHERE Id IN :idSet
    ];
    List<AutomatedSurvey__c> AS_De = new List<AutomatedSurvey__c>();
    List<AutomatedSurvey__c> AS_En = new List<AutomatedSurvey__c>();
    List<AutomatedSurvey__c> AS_Fr = new List<AutomatedSurvey__c>();
    for (AutomatedSurvey__c ausu : ASs) {
        if (ausu.Contact__r.Account.PrimaryLanguage__c == 'English') {
            AS_En.add(ausu);
        } else if (ausu.Contact__r.Account.PrimaryLanguage__c == 'French') {
            AS_Fr.add(ausu);
        } else {
            AS_De.add(ausu);
        }
    }
    if (AS_De.size()>0) SurveyMonkeyAPI.addRecipients('German', JSON.serialize(AS_De));
    if (AS_En.size()>0) SurveyMonkeyAPI.addRecipients('English', JSON.serialize(AS_En));
    if (AS_Fr.size()>0) SurveyMonkeyAPI.addRecipients('French', JSON.serialize(AS_Fr));

}