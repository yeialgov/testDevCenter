public class jsOptout {
    
    public String msg { get; set; }
    
    public jsOptout() {
        try {
            String param = ApexPages.currentPage().getParameters().get('id');
            CryptAES c = new CryptAES('AES256');
            String JSId = c.decrypt(param);
            Joint_Sales__c js = [SELECT Id, Customer_Opt_Out__c FROM Joint_Sales__c WHERE Id=:JSId LIMIT 1];
            if (js.Customer_Opt_Out__c) msg = 'Dein Widerspruch ist bereits bei uns eingegangen und wir werden Deine Daten nicht weitergeben.';
        } catch(exception e){
            msg = null;
        }
    }
    
    public void execute() {
        try {
            String param = ApexPages.currentPage().getParameters().get('id');
            CryptAES c = new CryptAES('AES256');
            String JSId = c.decrypt(param);
            Joint_Sales__c js = [SELECT Id, Customer_Opt_Out__c FROM Joint_Sales__c WHERE Id=:JSId LIMIT 1];
            js.Customer_Opt_Out__c = true;
            update js;
            msg = 'Vielen Dank. Ihre Einstellungen wurden gespeichert.';
        } catch(exception e){
            msg = 'Etwas ist schief gelaufen.';
        }
    }
}