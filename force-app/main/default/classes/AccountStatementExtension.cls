public class AccountStatementExtension {

    /*public Account acct { get; set; }
    public User userDetails { get; set; }
    public List<StatementItem> items { get; set; }
    public Decimal runningBalance { get; set; }
    public String primaryLanguage { get; set; }
    
    public List<Decimal> InvoiceBreakdown { get; set; }
    
    public AccountStatementExtension(ApexPages.StandardController stdController) {
        this.acct = [
            SELECT 
                Id, Name, Account_Balance__c, CurrencyIsoCode, PrimaryLanguage__c,
            	SF_BillTo_Contact__r.Name, SF_BillTo_Contact__r.MailingStreet, SF_BillTo_Contact__r.MailingCity, 
                SF_BillTo_Contact__r.MailingPostalCode, SF_BillTo_Contact__r.MailingCountry, SF_BillTo_Contact__r.MailingCountryCode,
                (
                    SELECT Id, Zuora__Effective_Date__c, Zuora__Amount__c, Zuora__ReferenceId__c, CreatedDate
                    FROM Zuora__Payments__r 
                    WHERE Zuora__Status__c = 'Processed' OR Zuora__Status__c = 'Processing'
                ), (
                    SELECT Id, Zuora__InvoiceDate__c, Zuora__TotalAmount__c, Zuora__ZuoraId__c, CreatedDate
                    FROM Zuora__Invoices__r
                    WHERE Zuora__TotalAmount__c != 0
                ), (
                    SELECT Id, Zuora__Refund_Date__c, Zuora__Amount__c, Zuora__ReferenceId__c, CreatedDate
                    FROM Zuora__Refunds__r
                    WHERE Zuora__Amount__c != 0
                ), (
                    SELECT Id, Zuora__Currency__c 
                    FROM Zuora__R00N40000001kyLcEAI__r
                )
            FROM Account 
            WHERE Id=:((Account)stdController.getRecord()).Id 
            LIMIT 1
        ];
        Decimal AccountBalance = 0;
        if (acct.Account_Balance__c != null) AccountBalance = acct.Account_Balance__c;
        this.userDetails = [SELECT Id, Name, Department, Phone, Email FROM User WHERE Id = :UserInfo.getUserId()];
        this.items = new List<StatementItem>();
        items.add(new StatementItem());
        for (Zuora__ZInvoice__c inv : acct.Zuora__Invoices__r) {
            items.add(new StatementItem(inv));
        }
        for (Zuora__Payment__c pmt : acct.Zuora__Payments__r) {
            items.add(new StatementItem(pmt));
        }
        for (Zuora__Refund__c ref : acct.Zuora__Refunds__r) {
            items.add(new StatementItem(ref));
        }
        items.sort();
        this.InvoiceBreakdown = new List<Decimal>{0, 0, 0, 0, 0};
        runningBalance = 0;
        Double DayConstant = 30.0;
        for (StatementItem item : items) {
            Date dateStamp = Date.today();
            if (item.DateStamp != null) dateStamp = item.DateStamp;
            if (item.Charge != null) {
                runningBalance += item.Charge;
                InvoiceBreakdown[Math.min(4,Math.max(0,(Math.ceil(dateStamp.daysBetween(Date.today())/DayConstant)).intValue()))] += item.Charge;
            }
            if (item.Payment != null) runningBalance -= item.Payment;
            item.Balance = runningBalance;
        }
        if (items.size() > 1) items[0].DateStamp = items[1].DateStamp;
        Decimal offset = runningBalance - AccountBalance;
        if (offset != 0) {
            for (StatementItem item: items) {
                item.Balance -= offset;
            }
        }
        Decimal BreakdownTotal = AccountBalance;
        for (Integer x=0; x<InvoiceBreakdown.size(); x++) {
            if (InvoiceBreakdown[x] > BreakdownTotal) {
                InvoiceBreakdown[x] = BreakdownTotal;
            }
            BreakdownTotal -= InvoiceBreakdown[x];
        }
        primaryLanguage = LanguageMap.get(acct.PrimaryLanguage__c);
    }
    
    public Static Map<String, String> LanguageMap = new Map<String, String>{'English'=>'en','German'=>'de','Spanish'=>'es','French'=>'fr'};
    
    public class StatementItem implements Comparable{
        public Date DateStamp { get; set; }
        public DateTime TimeStamp { get; set; }
        public String Description { get; set; }
        public String RefNum { get; set; }
        public Decimal Charge { get; set; }
        public Decimal Payment { get; set; }
        public Decimal Balance { get; set; }
        public Integer ItemType { get; set; }
        
        public StatementItem() {
            DateStamp = Date.newInstance(2017, 9, 1);
            Description = 'BEGINNING_BALANCE';
            Balance = 0;
            ItemType = -1;
        }        
        
        public StatementItem(Zuora__ZInvoice__c inv) {
            DateStamp = inv.Zuora__InvoiceDate__c;
            TimeStamp = inv.CreatedDate;
            Description = 'INVOICE';
            RefNum = inv.Zuora__ZuoraId__c;
            Charge = inv.Zuora__TotalAmount__c;
            ItemType = 0;
        }

        public StatementItem(Zuora__Payment__c pmt) {
            DateStamp = pmt.Zuora__Effective_Date__c;
            TimeStamp = pmt.CreatedDate;
            Description = 'PAYMENT';
            RefNum = pmt.Zuora__ReferenceId__c;
            Payment = pmt.Zuora__Amount__c;
            ItemType = 1;
        }

        public StatementItem(Zuora__Refund__c ref) {
            DateStamp = ref.Zuora__Refund_Date__c;
            TimeStamp = ref.CreatedDate;
            Description = 'REFUND';
            RefNum = ref.Zuora__ReferenceId__c;
            Payment = ref.Zuora__Amount__c * -1;
            ItemType = 2;
        }

        public Integer compareTo(Object compareTo) {
            StatementItem CompareItem = (StatementItem)compareTo;
            if (DateStamp > CompareItem.DateStamp) {
                return 1;
            } else if (DateStamp < CompareItem.DateStamp) {
                return -1;
            } else {
                if (ItemType > CompareItem.ItemType) {
                    return 1;
                } else {
                    return -1;
                }                
            }
        }
    }*/

}