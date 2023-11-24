/**
 * @author martin
 */
public with sharing class QuoteAttachmentMandatory {
/*
    Map<Id, zqu__Quote__c> newMap;
    Map<Id, zqu__Quote__c> oldMap;

    public QuoteAttachmentMandatory(Map<Id, zqu__Quote__c> newMap, Map<Id, zqu__Quote__c> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public void execute() {

        List< Id > quoteIDList = new List< Id >();
        List< Id > attIDList = new List< Id >();

        for (zqu__Quote__c q : newMap.values()) {
            quoteIDList.add(q.Id);
        }

        for (Attachment a : [SELECT Id FROM Attachment WHERE ParentId IN :quoteIDList]) {
            attIDList.add(a.Id);
        }

        for (zqu__Quote__c q : newMap.values()) {

            if (q != null && !Label.Admin_Users.contains(UserInfo.getUserId().substring(0, 15))) {

                if (attIDList.isEmpty()
                        && q.Quote_is_ready__c == true
                        && q.RecordTypeId == '01258000000F8g2AAC'
                        && (oldMap == null || q.Quote_is_ready__c != oldMap.get(q.Id).Quote_is_ready__c)) {
                    q.Quote_is_ready__c.addError('Please attach the customers response to the Quote before marking it as ready!');
                }
            }
        }
    }*/
}