public class InvoicePdfController {
    public String iId {
        get; 
        set {
            iId = value;
            init();
        } 
    }
    public Boolean wBool { get; set; }
    public Boolean VATAdjustment { get; set; }
    public Boolean IsMini { get; set; }
    public Boolean UseDiscountTotal { get; set; }
   	public Boolean ForgetBundle { get; set; }
    public Boolean VATNewEULaw {get; set;}
    public Account Account { get; set; }
    public List<String> AddressParts { get; set; }
    public String primaryLanguage { get; set; }
    public String Country { get; set; }
    public String PhoneNumber { get; set; }
    public String PaymentMethod { get; set; }
    public String DiffCustomerAccount { get; set; }
    public String TaxExemptReason { get; set; }
    public String VATId { get; set; }
    public List<LineItemWrapper> LineItems { get; set; }
    public Map<Id, ProductBundle__c> BundleMap { get; set; }
    public Map<String, InvoiceLineItem__c> BundledServicePeriodMap { get; set; }
    public Invoice__c Invoice { get; set; }
    public String RelatedVATInvoice { get; set; }
    public List<InvoiceLineItem__c> RelatedVATILIs { get; set; }
    public Decimal DiscountTotal { get; set; }
    public Decimal NonDiscountTotal { get; set; }
    public Decimal VATChgAmtNeg { get; set; }
    public Decimal VATTaxAmtNeg { get; set; }
    public Decimal VATChgAmtPos { get; set; }
    public Decimal VATTaxAmtPos { get; set; }
    
    
    public void init() {
        VATAdjustment = false;
        VATChgAmtNeg = 0;
        VATTaxAmtNeg = 0;
        VATChgAmtPos = 0;
        VATTaxAmtPos = 0;
        Invoice = [
            SELECT 
                Id, Name, Account__c, AmountWithoutTax__c, TaxAmount__c, Amount__c, InvoiceDate__c, DueDate__c, VATId__c, TaxExemptReason__c, MixedTax__c, Tax_Rollup_0__c, Tax_Rollup_16__c, Tax_Rollup_19__c, Forget_Bundle__c, VAT_TaxLabel__c, Account__r.CurrencyIsoCode
            FROM Invoice__c 
            WHERE Id=:iId 
            LIMIT 1
        ];
        
        ForgetBundle = Invoice.Forget_Bundle__c;
        
        Datetime VATLawStart = date.newInstance(2021, 7, 1); // 2021.07.01 change after testing stage
        system.debug(VATLawStart);
        if (invoice.invoicedate__c >= VATLawStart){VATNewEULaw = true;}
        else {VATNewEULaw = false;}
        system.debug(VATNewEULaw);
            
        LineItems = new List<LineItemWrapper>();
        
        String VATAdjInv = null;
        Set<String> VATAdjILI = new Set<String>();
        
        // non-bundled line items
        	for (InvoiceLineItem__c ILI : [
        		SELECT Id, ChargeName__c, Quantity__c, UnitPrice__c, ChargeAmount__c, DiscountProduct__c,
                	ServiceStartDate__c, ServiceEndDate__c, ShowServicePeriod__c, TaxCategory__c, TaxAmount__c,
                	SubscriptionLineItem__r.Product__r.Name, SubscriptionLineItem__r.VAT_ref__c,
                	SubscriptionLineItem__r.Product__r.Model__c, 
                	SubscriptionLineItem__r.Product__r.Product_Name_DE__c, 
                	SubscriptionLineItem__r.Product__r.Product_Name_FR__c,
                	SubscriptionLineItem__r.Product__r.ProductCategory__r.Name,
            		SubscriptionLineItem__r.Subscription__r.Name
            	FROM InvoiceLineItem__c
            	WHERE Invoice__c = :Invoice.Id AND (SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c = null OR Invoice__r.Forget_Bundle__c = TRUE)
        	]) {
            	LineItems.add(new LineItemWrapper(ILI, ForgetBundle));
            	if (ILI.SubscriptionLineItem__r.VAT_ref__c != null) {
                	try {
                    	RelatedVATInvoice = ILI.SubscriptionLineItem__r.VAT_ref__c.split('\\|')[0];
                   	 	VATAdjILI.addAll(ILI.SubscriptionLineItem__r.VAT_ref__c.split('\\|')[1].split(';'));                    
                    	VATAdjustment = true;
                    	if (ILI.ChargeAmount__c < 0) {
                       		VATChgAmtNeg += Math.abs(ILI.ChargeAmount__c);
                        	VATTaxAmtNeg += Math.abs(ILI.TaxAmount__c);
                    	} else {
                        	VATChgAmtPos += Math.abs(ILI.ChargeAmount__c);
                        	VATTaxAmtPos += Math.abs(ILI.TaxAmount__c);
                    	}
                	} catch(exception e){}
            	}
        	}
        
        try {
            if (VATAdjustment) {
                RelatedVATILIs = [
                    SELECT Id, ServiceStartDate__c, ServiceEndDate__c, 
                    	SubscriptionLineItem__r.Product__r.Name, 
                    	SubscriptionLineItem__r.Product__r.Product_Name_DE__c, 
                    	SubscriptionLineItem__r.Product__r.Product_Name_FR__c
                    FROM InvoiceLineItem__c
                    WHERE ZuoraId__c IN :VATAdjILI
                ];
            }
        } catch(exception e) {}
                
        Decimal multiplier = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode = :Invoice.Account__r.CurrencyIsoCode LIMIT 1].ConversionRate;
		multiplier = 1;
        
        // bundled line items
        for (AggregateResult AR : [
            SELECT 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name nameEN, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name_DE__c nameDE, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name_FR__c nameFR, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.ProductCategory__r.Name sorter, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c pbid, 
            	SubscriptionLineItem__r.Subscription__r.Name subName,
            	MIN(TaxCategory__c) taxcat,
                MAX(Quantity__c) qty, 
                SUM(CalcUnitPrice__c) uprice,
                SUM(ChargeAmount__c) tprice,
            	COUNT(Id) bundleItems,
                MIN(SubscriptionLineItem__r.Product__c) prodId, 
                MIN(SubscriptionLineItem__r.Product__r.Name) nameENsp, 
                MIN(SubscriptionLineItem__r.Product__r.Product_Name_DE__c) nameDEsp, 
                MIN(SubscriptionLineItem__r.Product__r.Product_Name_FR__c) nameFRsp
            FROM InvoiceLineItem__c
            WHERE Invoice__c = :Invoice.Id AND SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c != null AND Invoice__r.Forget_Bundle__c = FALSE
            GROUP BY 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name_DE__c, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.Name_FR__c,
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__r.ProductCategory__r.Name, 
                SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c,
            	SubscriptionLineItem__r.Subscription__r.Name
        	]) {
            LineItems.add(new LineItemWrapper(AR, multiplier));
        }
        
        LineItems.sort();
                    
        BundleMap = new Map<Id,ProductBundle__c>([
            SELECT Id, (
                SELECT Product__r.Name, Product__r.Product_Name_DE__c, Product__r.Product_Name_FR__c
                FROM Product_Bundle_Assignments__r
                ORDER BY Product__r.ProductCategory__r.Name ASC, Product__r.Model__c DESC
            )
            FROM ProductBundle__c
        ]);
        
        BundledServicePeriodMap = new Map<String, InvoiceLineItem__c>();
        for (InvoiceLineItem__c bILI : [
            SELECT Id, ServiceStartDate__c, ServiceEndDate__c, 
            	SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c,
            	SubscriptionLineItem__r.Product__c
            FROM InvoiceLineItem__c 
            WHERE Invoice__c = :iId 
            	AND SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c != null 
            	AND ShowServicePeriod__c = TRUE
        ]) {
            BundledServicePeriodMap.put(
                String.valueOf(bILI.SubscriptionLineItem__r.QuoteLineItem__r.ProductBundle__c)
                + String.valueOf(bILI.SubscriptionLineItem__r.Product__c), bILI
            );
        }
        
        Account = [
            SELECT Id, Name, OwnerId, AddressBuilder__c, CurrencyIsoCode, PrimaryLanguage__c, CustomerIdText__c, 
                SF_BillTo_Contact__r.Name, BillingStreet, BillingCity, 
                BillingPostalCode, BillingCountry, BillingCountryCode,
                SF_BillTo_Contact__r.Addressee__c, SF_BillTo_Contact__r.Attention__c, SF_BillTo_Contact__r.FirstName,
                LegalCompanyName__c, VATNumber__c, Tax_Exempt_Reason__c, DefaultPaymentMethod__r.Type__c, Target_Product__c
            FROM Account 
            WHERE Id = :Invoice.Account__c 
            LIMIT 1
        ];
        
        IsMini = Account.Target_Product__c == 'MINI';
        
        Country = Account.BillingCountry;
        
        PaymentMethod = Account.DefaultPaymentMethod__r.Type__c;
        try{if (PaymentMethod == null) {
            PaymentMethod = [
                SELECT Id, PaymentMethod__c 
                FROM Quote 
                WHERE AccountId=:Account.Id AND Status = 'Accepted'
                ORDER BY CreatedDate DESC
            ][0].PaymentMethod__c;
        }}catch(exception e){}

        Map<String,String> PhoneNumberMap = new Map<String,String>{
            'Germany' => '+4930208983098',
            'France' => '+33176360640',
            'Austria' => '+431361022499',
            'Switzerland' => '+41415252099',
            'United Kingdom' => '+44 20 36951896',
            'Spain' => '+34911680466',
            'United States' => '+19173000365'
        };
        
        if (PhoneNumberMap.keySet().contains(Account.BillingCountry)) {
            PhoneNumber = PhoneNumberMap.get(Account.BillingCountry);
        } else {
            PhoneNumber = '+4930208983099';
        }

        try {
            AddressParts = (List<String>)JSON.deserialize(Account.AddressBuilder__c, List<String>.class);
        } catch(exception e){}
        
        DiscountTotal = 0;
        NonDiscountTotal = 0;
        DiffCustomerAccount = null;
        for (InvoiceLineItem__c ILI : [
            SELECT 
                Id, DiscountProduct__c, ChargeAmount__c, 
                SubscriptionLineItem__r.Subscription__r.HasDifferentInvoiceOwner__c, 
                SubscriptionLineItem__r.Subscription__r.Account__r.Name, SubscriptionLineItem__r.Subscription__r.Account__r.LegalCompanyName__c
            FROM InvoiceLineItem__c 
            WHERE Invoice__c = :Invoice.Id
        ]) {
            if (ILI.DiscountProduct__c) {
                DiscountTotal += ILI.ChargeAmount__c;
            } else {
                NonDiscountTotal += ILI.ChargeAmount__c;
            }
            if (DiffCustomerAccount == null && ILI.SubscriptionLineItem__r.Subscription__r.HasDifferentInvoiceOwner__c) {
                DiffCustomerAccount = ILI.SubscriptionLineItem__r.Subscription__r.Account__r.Name + ' / ' + ILI.SubscriptionLineItem__r.Subscription__r.Account__r.LegalCompanyName__c;
            }
        }
        UseDiscountTotal = (
            Invoice.AmountWithoutTax__c == DiscountTotal + NonDiscountTotal
            && DiscountTotal != 0
        );
        
        primaryLanguage = LanguageMap.get(Account.PrimaryLanguage__c);
        
        TaxExemptReason = Invoice.TaxExemptReason__c == null ? Account.Tax_Exempt_Reason__c : Invoice.TaxExemptReason__c;
        VATId = Invoice.VATId__c == null ? Account.VATNumber__c : Invoice.VATId__c;

    }

    public Static Map<String, String> LanguageMap = new Map<String, String>{'English'=>'en','German'=>'de',null=>'de','French'=>'fr'};

    public class LineItemWrapper implements Comparable {
        public InvoiceLineItem__c ILI { get; set; }
        public AggregateResult AR { get; set; }
        public Decimal UnitPrice { get; set; }
        public Decimal TotalPrice { get; set; }
        public Boolean IsBundle { get; set; }
        public String SortItemOneASC { get; set; }
        public String SortItemTwoDSC { get; set; }
        public LineItemWrapper(InvoiceLineItem__c iILI, boolean forgetBundle) {
            ILI = iILI;
            IsBundle = false;
            if(forgetBundle){
                SortItemOneASC = '0';
                SortItemTwoDSC = ILI.SubscriptionLineItem__r.Product__r.Model__c;
            }else{
            	SortItemOneASC = ILI.SubscriptionLineItem__r.Product__r.ProductCategory__r.Name;
            	SortItemTwoDSC = ILI.SubscriptionLineItem__r.Product__r.Model__c;
            }
        }
        public LineItemWrapper(AggregateResult iAR, Decimal multiplier) {
            AR = iAR;
            IsBundle = true;
            UnitPrice = (multiplier * (Decimal)AR.get('uprice')).setScale(2, System.RoundingMode.HALF_UP);
            TotalPrice = (multiplier * (Decimal)AR.get('tprice')).setScale(2, System.RoundingMode.HALF_UP);
            SortItemOneASC = (String)AR.get('sorter');
            SortItemTwoDSC = '0';
        }
        public Integer compareTo(Object compareTo) {
            LineItemWrapper compareToLIW = (LineItemWrapper)compareTo;
            if (SortItemOneASC == compareToLIW.SortItemOneASC) {
                if (SortItemTwoDSC == compareToLIW.SortItemTwoDSC) return 0;
                if (SortItemTwoDSC > compareToLIW.SortItemTwoDSC) return -1;
                return 1;
            }
            if (SortItemOneASC > compareToLIW.SortItemOneASC) return 1;
            return -1;
        }
    }
}