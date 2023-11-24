public class AccountStatementController {

    public String acctId { 
        get; 
        set {
            acctId = value;
            init();
        } 
    }
    
    public Account acct { get; set; }
    public List<String> AddressParts { get; set; }
    public List<StatementItem> items { get; set; }
    public Decimal runningBalance { get; set; }
    public String primaryLanguage { get; set; }
    
    public List<Decimal> InvoiceBreakdown { get; set; }
    
    public void init() {
        this.acct = [
            SELECT 
                Id, Name, OwnerId, CustomerIdText__c, CurrencyIsoCode, PrimaryLanguage__c, 
                SF_BillTo_Contact__r.Name, BillingStreet, BillingCity, 
                BillingPostalCode, BillingCountry, BillingCountryCode,
            	SF_BillTo_Contact__r.FirstName, LegalCompanyName__c, 
                AccountManager__r.Name, AccountManager__r.Department, AccountManager__r.Phone, AccountManager__r.Email,
                Netsuite_Open_Balance__c, Combined_Balance__c, AddressBuilder__c,
                (
                    SELECT Id, EffectiveDate__c, Amount__c, Name, CreatedDate
                    FROM Payments__r 
                    WHERE Status__c = 'Processed' OR Status__c = 'Processing'
                ), (
                    SELECT Id, InvoiceDate__c, Amount__c, Name, CreatedDate
                    FROM Invoices__r
                    WHERE Amount__c != 0 AND Status__c = 'Posted'
                ), (
                    SELECT Id, RefundDate__c, Amount__c, Name, CreatedDate
                    FROM Refunds__r
                    WHERE Amount__c != 0 AND Status__c = 'Processed'
                )
            FROM Account 
            WHERE Id= :acctId
            LIMIT 1
        ];
        try {
            AddressParts = (List<String>)JSON.deserialize(acct.AddressBuilder__c, List<String>.class);
        } catch(exception e){}
        Decimal AccountBalance = acct.Combined_Balance__c;
        this.items = new List<StatementItem>();
        items.add(new StatementItem(acct.Netsuite_Open_Balance__c));
        for (Invoice__c inv : acct.Invoices__r) {
            items.add(new StatementItem(inv));
        }
        for (Payment__c pmt : acct.Payments__r) {
            items.add(new StatementItem(pmt));
        }
        for (Refund__c ref : acct.Refunds__r) {
            items.add(new StatementItem(ref));
        }
        items.sort();
        this.InvoiceBreakdown = new List<Decimal>{0, 0, 0, 0, 0};
        runningBalance = 0;
        Double DayConstant = 10.0;
        for (StatementItem item : items) {
            Date dateStamp = Date.today();
            if (item.DateStamp != null) dateStamp = item.DateStamp;
            if (item.Charge != null) {
                runningBalance += item.Charge;
                InvoiceBreakdown[Math.min(4,Math.max(0,(Math.ceil(dateStamp.daysBetween(Date.today())/DayConstant)).intValue()))] += Math.max(0,item.Charge);
            }
            if (item.Payment != null) runningBalance -= item.Payment;
            item.Balance = runningBalance;
        }
        if (items.size() > 1) items[0].DateStamp = items[1].DateStamp;
        /* Decimal offset = runningBalance - AccountBalance;
        if (offset != 0) {
            for (StatementItem item: items) {
                item.Balance -= offset;
            }
        } */
        Decimal BreakdownTotal = AccountBalance;
        for (Integer x=0; x<InvoiceBreakdown.size(); x++) {
            if (InvoiceBreakdown[x] > BreakdownTotal) {
                InvoiceBreakdown[x] = BreakdownTotal;
            }
            BreakdownTotal -= InvoiceBreakdown[x];
        }
        items[0].Charge = null;
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
        
        public StatementItem(Decimal nsob) {
            DateStamp = Date.newInstance(2017, 9, 1);
            Description = 'BEGINNING_BALANCE';
            if (nsob != 0 && nsob != null) {
                Charge = nsob;
                Balance = nsob;
            } else {
                Balance = 0;
            }
            ItemType = -1;
        }        
        
        public StatementItem(Invoice__c inv) {
            DateStamp = inv.InvoiceDate__c;
            TimeStamp = inv.CreatedDate;
            Description = 'INVOICE';
            RefNum = inv.Name;
            Charge = inv.Amount__c;
            ItemType = 0;
        }

        public StatementItem(Payment__c pmt) {
            DateStamp = Date.newInstance(pmt.EffectiveDate__c.year(), pmt.EffectiveDate__c.month(), pmt.EffectiveDate__c.day());
            TimeStamp = pmt.CreatedDate;
            Description = 'PAYMENT';
            RefNum = pmt.Name;
            Payment = pmt.Amount__c;
            ItemType = 1;
        }

        public StatementItem(Refund__c ref) {
            DateStamp = ref.RefundDate__c;
            TimeStamp = ref.CreatedDate;
            Description = 'REFUND';
            RefNum = ref.Name;
            Payment = ref.Amount__c * -1;
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
    }

}