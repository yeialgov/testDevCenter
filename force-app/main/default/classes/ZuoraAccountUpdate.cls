/**
 * @author keylight
 */
global class ZuoraAccountUpdate {
    public Account account;
    public String zuoraId;

    global ZuoraAccountUpdate(Account account, String zuoraId) {
        this.account = account;
        this.zuoraId = zuoraId;
    }

    @TestVisible
    private String toJson() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (this.account.LegalCompanyName__c != null) gen.writeStringField('LegalCompanyName__c', this.account.LegalCompanyName__c);
        if (this.account.NS_Customer_Internal_ID__c != null) gen.writeStringField('NS_Customer_Internal_ID__c', this.account.NS_Customer_Internal_ID__c);
        if (this.account.myOrderbirdEmail__c != null) gen.writeStringField('myOrderbirdEmail__c', this.account.myOrderbirdEmail__c);
        if (this.account.Exclude_Account_Name_on_Invoice__c != null) gen.writeStringField('Exclude_Account_Name_on_Invoice__c', this.account.Exclude_Account_Name_on_Invoice__c);
        if (this.account.Tax_Exempt_Reason__c != null) gen.writeStringField('Tax_Exempt_Reason__c', this.account.Tax_Exempt_Reason__c);
        if (this.account.Name != null) gen.writeStringField('name', this.account.Name);
        if (this.account.Exclude_Contact_Name_on_Invoice__c != null) gen.writeStringField('Exclude_Contact_Name_on_Invoice__c', this.account.Exclude_Contact_Name_on_Invoice__c);
        if (this.account.Dunning_Status__c != null) gen.writeStringField('Dunning_Status__c', this.account.Dunning_Status__c);
        ZuoraAccountTaxInfo taxInfo = new ZuoraAccountTaxInfo(this.account.VATNumber__c, this.account.taxExempted__c);
        gen.writeObjectField('taxInfo', taxInfo);
        gen.writeEndObject();
        return gen.getAsString();
    }

    global String send() {
        String data = this.toJson();
        String path = 'accounts/' + this.zuoraId;
        String res = ZuoraManager.callZuoraAPI(path, 'PUT', data);
        return res;
    }

    public class ZuoraAccountTaxInfo {
        public String VATId;
        public String exemptStatus;

        public ZuoraAccountTaxInfo(String vatId, Boolean taxExempt) {
            if(vatId == null) {
                this.VATId = '';
            } else {
                this.VATId = vatId;
            }
            if(taxExempt){
                this.exemptStatus = 'Yes';
            } else {
                this.exemptStatus = 'No';
            }
        }

    }
}