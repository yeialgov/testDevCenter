public class QuotePdfController {
    public String qId {
        get; 
        set {
            qId = value;
            init();
        } 
    }
    public Account Account { get; set; }
    public Boolean UseDiscountTotal { get; set; }
    public Decimal DiscountTotal { get; set; }
    public Decimal NonDiscountTotal { get; set; }
    public Decimal RestartTotal { get; set; }
    public String primaryLanguage { get; set; }
    public String Country { get; set; }
    public List<LineItemWrapper> LineItems { get; set; }
    public List<String> AddressParts { get; set; }
    public List<String> AddressPartsShip { get; set; }
    public Map<Id, ProductBundle__c> BundleMap { get; set; }
    public Quote Quote { get; set; }
    public Boolean VATNewEULaw {get; set;}
    public Boolean Has_GM {get; set;}
    
    public void init() {
        Quote = [
            SELECT 
                Id, AccountId, SubTotal, Tax, TotalPrice, GrandTotal, Owner.Name, Owner.Email, Owner.Phone,
                Opportunity.Owner.Name, Opportunity.Owner.Email, Opportunity.Owner.Phone, Account.CustomerID__c,
                QuoteNumber, ExpirationDate, PaymentMethod__c, Pay_by_Instalment__c, Account.CurrencyIsoCode,
                PayPalLink__c, PDF_PaymentMethod__c, Opportunity.Owner.Profile.Name, VAT_TaxLabel__c, InvoiceDate__c	
            FROM Quote 
            WHERE Id=:qId 
            LIMIT 1
        ];
        
        
        //Defines the date when VAT changes in the Tax Lable applies 
        //for the countries outside of Germany 
        //
        Datetime VATLawStart = date.newInstance(2021, 7, 1); 
        if (quote.invoicedate__c >= VATLawStart){VATNewEULaw = true;}
        else {VATNewEULaw = false;}
        
        //Check if the Quote includes Guest Management Product checking by the Product Category
        //If yes set a boolean as true
        List<QuoteLineItem> GM_Items = [SELECT Id, Product2Id FROM QuoteLineItem
            WHERE QuoteId = :Quote.Id 
            AND Product2.ProductCategory__r.name ='7 F5 Guest Management']; 
       	if (GM_Items.size() > 0) Has_GM = true;
        
        //Wrapping QLI items that do not belong to a bundle
        LineItems = new List<LineItemWrapper>();
        for (QuoteLineItem QLI : [
            SELECT Id, Product2.Name, Product2.ProductCategory__r.Name, Product2.Model__c,
                Product2.Product_Name_DE__c, Product2.Product_Name_FR__c, 
                Quantity, UnitPrice, TotalPrice
            FROM QuoteLineItem
            WHERE QuoteId = :Quote.Id AND ProductBundle__c = null
        ]) {
            LineItems.add(new LineItemWrapper(QLI));
        }
        
        Decimal multiplier = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode = :Quote.Account.CurrencyIsoCode LIMIT 1].ConversionRate;
        
        for (AggregateResult AR : [
            SELECT 
                ProductBundle__r.Name nameEN, 
                ProductBundle__r.Name_DE__c nameDE, 
                ProductBundle__r.Name_FR__c nameFR, 
                ProductBundle__r.ProductCategory__r.Name sorter, 
                ProductBundle__c pbid,
                MAX(Quantity) qty, 
                SUM(UnitPrice) uprice, 
                SUM(TotalPrice) tprice,
                SUM(NonDiscountUnitPriceBundle__c) nduprice,
                SUM(NonDiscountPriceBundle__c) ndprice
            FROM QuoteLineItem
            WHERE QuoteId = :Quote.Id AND ProductBundle__c != null
            GROUP BY ProductBundle__r.Name, ProductBundle__r.ProductCategory__r.Name, 
                ProductBundle__r.Name_DE__c, ProductBundle__r.Name_FR__c, ProductBundle__c
        ]) {
            LineItems.add(new LineItemWrapper(AR, multiplier));
        }

        LineItems.sort();
       
        BundleMap = new Map<Id,ProductBundle__c>([
            SELECT Id, (
                SELECT Product__r.Name, Product__r.Product_Name_DE__c, Product__r.Product_Name_FR__c
                FROM Product_Bundle_Assignments__r
                ORDER BY Product__r.Model__c DESC, Product__r.ProductCategory__r.Name ASC
            )
            FROM ProductBundle__c
        ]);
        
        Account = [
            SELECT Id, Name, OwnerId, CurrencyIsoCode, PrimaryLanguage__c, AddressBuilder__c, AddressBuilder_Shipping__c, LegalCompanyName__c,
                SF_BillTo_Contact__r.Name, BillingStreet, BillingCity, 
                BillingPostalCode, BillingCountry, BillingCountryCode,
                SF_BillTo_Contact__r.FirstName,
                SF_SoldTo_Contact__r.Name, ShippingStreet, ShippingCity, 
                ShippingPostalCode, ShippingCountry, ShippingCountryCode,
                SF_SoldTo_Contact__r.FirstName
            FROM Account 
            WHERE Id = :Quote.AccountId 
            LIMIT 1
        ];
        
        Country = Account.BillingCountry;

        try {
            AddressParts = (List<String>)JSON.deserialize(Account.AddressBuilder__c, List<String>.class);
        } catch(exception e){}

        try {
            AddressPartsShip = (List<String>)JSON.deserialize(Account.AddressBuilder_Shipping__c, List<String>.class);
        } catch(exception e){}

        DiscountTotal = 0;
        NonDiscountTotal = 0;
        RestartTotal = 0;
        for (QuoteLineItem QLI : [
            SELECT 
                Id, DiscountProduct__c, TotalPrice, Product2.Type__c, Product2.Model__c
            FROM QuoteLineItem 
            WHERE QuoteId = :Quote.Id
        ]) {
            if (QLI.DiscountProduct__c) {
                DiscountTotal += QLI.TotalPrice;
            } else {
                NonDiscountTotal += QLI.TotalPrice;
            }
            if (QLI.Product2.Type__c != 'Recurring' || (QLI.Product2.Model__c != 'PerUnit' && QLI.Product2.Model__c != 'FlatFee')) RestartTotal += QLI.TotalPrice;
        }
        UseDiscountTotal = (
            Math.abs(Quote.Subtotal - DiscountTotal - NonDiscountTotal) < 0.01
            && DiscountTotal != 0
        );

        primaryLanguage = LanguageMap.get(Account.PrimaryLanguage__c);

    }

    public Static Map<String, String> LanguageMap = new Map<String, String>{'English'=>'en','German'=>'de',null=>'de','French'=>'fr'};

    public class LineItemWrapper implements Comparable {
        public QuoteLineItem QLI { get; set; }
        public AggregateResult AR { get; set; }
        public Decimal UnitPrice { get; set; }
        public Decimal TotalPrice { get; set; }
        public Decimal StrikeoutUnitPrice { get; set; }
        public Decimal StrikeoutPrice { get; set; }
        public Boolean IsBundle { get; set; }
        public String SortItemOneASC { get; set; }
        public String SortItemTwoDSC { get; set; }
        public LineItemWrapper(QuoteLineItem iQLI) {
            QLI = iQLI;
            IsBundle = false;
            SortItemOneASC = QLI.Product2.ProductCategory__r.Name;
            SortItemTwoDSC = QLI.Product2.Model__c;
        }
        public LineItemWrapper(AggregateResult iAR, Decimal multiplier) {
            AR = iAR;
            UnitPrice = (multiplier * (Decimal)AR.get('uprice')).setScale(2, System.RoundingMode.HALF_UP);
            TotalPrice = (multiplier * (Decimal)AR.get('tprice')).setScale(2, System.RoundingMode.HALF_UP);
            StrikeoutUnitPrice = (multiplier * (Decimal)AR.get('nduprice')).setScale(2, System.RoundingMode.HALF_UP);
            StrikeoutPrice = (multiplier * (Decimal)AR.get('ndprice')).setScale(2, System.RoundingMode.HALF_UP);
            if (StrikeoutUnitPrice == 0 || StrikeoutUnitPrice == UnitPrice) StrikeoutUnitPrice = null;
            if (StrikeoutPrice == 0 || StrikeoutPrice == TotalPrice) StrikeoutPrice = null;
            IsBundle = true;
            SortItemOneASC = (String)AR.get('sorter');
            SortItemTwoDSC = '0';
        }
        public Integer compareTo(Object compareTo) {
            LineItemWrapper compareToLIW = (LineItemWrapper)compareTo;
            if (SortItemOneASC == compareToLIW.SortItemOneASC) {
                if (SortItemTwoDSC > compareToLIW.SortItemTwoDSC) return -1;
                if (SortItemTwoDSC == compareToLIW.SortItemTwoDSC) return 0;
                return 1;
            }
            if (SortItemOneASC > compareToLIW.SortItemOneASC) return 1;
            return -1;
        }
    }

}