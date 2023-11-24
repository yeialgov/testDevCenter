public class JointSalesEmbedExtension {

    public Account acct { get; set; }
    public Boolean renderError { get; set; }
    public String errorMsg { get; set; }
    public Boolean gotoRedirect { get; set; }

    public JointSalesEmbedExtension(ApexPages.StandardController stdController) {
        gotoRedirect = false;
        this.acct = [
            SELECT 
                Id, Name, Caller_Contact__c, Caller_Contact__r.Email, Caller_Contact__r.Phone, 
                Caller_Contact__r.MailingStreet, Caller_Contact__r.MailingCity, 
            	Caller_Contact__r.MailingPostalCode, Caller_Contact__r.MailingCountry, 
            (SELECT Id, Partner__r.Name FROM Joint_Sales1__r ORDER BY Partner__r.Name)
            FROM Account 
            WHERE Id=:((Account)stdController.getRecord()).Id 
            LIMIT 1
        ];
        if (acct.Caller_Contact__c == null) {
            renderError = true;
            errorMsg = 'This account requires a Caller Contact to refer Joint Sales.';
        } else if (acct.Caller_Contact__r.Email == null || (acct.Caller_Contact__r.Phone == null && acct.Caller_Contact__r.MobilePhone == null)) {
            renderError = true;
            errorMsg = 'Before referring Joint Sales, this Account\'s Caller Contact must have a valid Phone and Email.';
        } else {
            renderError = false;
        }
    }
    
    public void redirect() {
        gotoRedirect = true;
    }
    
}