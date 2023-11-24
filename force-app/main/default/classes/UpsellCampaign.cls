public class UpsellCampaign {
    
    public static PageReference init() {
        
        String cmId = ApexPages.currentPage().getParameters().get('cmId');
        String cId = ApexPages.currentPage().getParameters().get('coId');
        String url = 'http://orderbird.com/de/bestaetigung-anfrage';
        try {
            CampaignMember cm = [SELECT Id, Upselling_email_interest__c, Contact.Account.PrimaryLanguage__c FROM CampaignMember WHERE Id=:cmId AND ContactId=:cId LIMIT 1];
            cm.Upselling_email_interest__c = true;
            update cm;
            if (cm.Contact.Account.PrimaryLanguage__c == 'English') url = 'https://www.orderbird.com/en/request-confirmation';
            if (cm.Contact.Account.PrimaryLanguage__c == 'French') url = 'https://www.orderbird.com/fr/confirmation-demande';
        } catch(exception e){}
        return new PageReference(url);
    }
    
}