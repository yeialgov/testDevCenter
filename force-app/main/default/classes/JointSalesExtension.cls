public class JointSalesExtension {
    
    public list<PartnerWrapper> Partners { get; set; }
    public Set<Id> JSIds { get; set; }
    public Account acct { get; set; }
    public String comment { get; set; }

    public JointSalesExtension(ApexPages.StandardController stdController) {
		Partners = new List<PartnerWrapper>();
        JSIds = new Set<Id>();
        acct = [
            SELECT 
                Id, Name, Caller_Contact__c,
            	(SELECT Id, Partner__c, Partner__r.Name FROM Joint_Sales1__r ORDER BY Partner__r.Name)
            FROM Account 
            WHERE Id=:((Account)stdController.getRecord()).Id
            LIMIT 1
        ];
        if (acct.getSObjects('Joint_Sales1__r') != null) {
            for (sObject o : (List<sObject>)acct.getSObjects('Joint_Sales1__r')) {
                JSIds.add((Id)o.get('Partner__c'));
            }
        }
        for (Account jsAcct : [
            SELECT Id, Name 
            FROM Account 
            WHERE RecordType.Name = 'Partner' AND PartnerType__c = 'Joint Sales'
            ORDER BY Name
        ]) {
            Partners.add(new PartnerWrapper(jsAcct, JSIds));
        }
    }
    
    public class PartnerWrapper {
        public String Id { get; set; }
        public String Name { get; set; }
        public Boolean Disabled { get; set; }
        public Boolean Selected { get; set; }
        
        public PartnerWrapper(Account pAcct, set<Id> idSet) {
            Id = pAcct.Id;
            Name = pAcct.Name;
            Disabled = idSet.contains(Id);
            Selected = idSet.contains(Id);
        }
    }
    
    public PageReference jsSave() {
        CryptAES crypt = new CryptAES('AES256');
        List<Joint_Sales__c> inserts = new List<Joint_Sales__c>();
        for (PartnerWrapper pw : Partners) {
            if (pw.Selected && !pw.Disabled) inserts.add(new Joint_Sales__c(
                Partner__c = pw.Id,
                Customer__c = acct.Id,
                Contact__c = acct.Caller_Contact__c,
                Comment__c = comment,
                Created_By__c = UserInfo.getUserId()
            ));
        }
        insert inserts;
        for (Joint_Sales__c js : inserts) {
            js.Token__c = crypt.encrypt(js.Id);
        }
        update inserts;
        return new PageReference('/' + acct.Id);
    }

    public PageReference jsCancel() {
        return new PageReference('/' + acct.Id);
    }

}