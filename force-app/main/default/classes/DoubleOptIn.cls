public class DoubleOptIn {
    
    public static String[] AllowedLanguages = new String[]{'en', 'fr', 'de'};
    
    public static PageReference init() {
        
        String param = ApexPages.currentPage().getParameters().get('id');
        String lang = ApexPages.currentPage().getParameters().get('lang');
        if (!AllowedLanguages.contains(lang)) lang = 'de';
        try {
            CryptAES caes = new CryptAES('AES256');
            String email = 'test@test.com';
            if (!test.isRunningTest()) email = caes.decrypt(param);
            List<Lead> Leads = [SELECT Id, DoubleOptIn__c FROM Lead WHERE Email = :email LIMIT 201];
            List<Contact> Contacts = [SELECT Id, DoubleOptIn__c FROM Contact WHERE Email = :email LIMIT 201];
            if (Leads.size() < 201) {
                for (Lead l : Leads) {
                    l.DoubleOptIn__c = 'Confirmed';
                }
            }
            if (Contacts.size() < 201) {
                for (Contact c : Contacts) {
                    c.DoubleOptIn__c = 'Confirmed';
                }
            }
            update Leads;
            update Contacts;
        } catch(exception e){
            return new PageReference('https://www.orderbird.com/newsletter-de-confirmation-2');
        }
        return new PageReference('https://www.orderbird.com/newsletter-'+lang+'-confirmation-2');
    }
    
}