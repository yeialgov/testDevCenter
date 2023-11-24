/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class PortalController {
    
    public String InvoiceId { get; set; }
    
    @AuraEnabled
    public static String getAccountInfo(String token) {
       // System.debug('getAccountInfo - token: ' + token );
        PortalWrapper pw;
        try {
            Account a = [
                SELECT Id, Name, CustomerId__c
                FROM Account
                WHERE Id = :PortalToken.decryptToken(token).AccountId
                LIMIT 1
            ];
            MyObVenue__c v = [
                SELECT Id, Contact__r.Name, MyOrderbirdId__c, Token__c, Uncertainty__c
                FROM MyObVenue__c
                WHERE MyOrderbirdId__c = :PortalToken.decryptToken(token).VenueId
                LIMIT 1
            ];
            pw = new PortalWrapper(a, v);
        } catch(exception e) {
            pw = new PortalWrapper(PortalToken.decryptToken(token));
        }
        return json.serialize(pw);
    }
    
    @AuraEnabled
    public static String getToken(String AccountId) {
        List<MyObVenue__c> venues = [SELECT Id, MyOrderbirdId__c FROM MyObVenue__c WHERE Contact__r.AccountId = :AccountId];
        if (venues.size() == 0) return null;
        return PortalToken.encryptToken( venues[0].MyOrderbirdId__c );
    }
    
    @AuraEnabled
    public static String verifyConnection(String Token, String VerificationString) {
        String NewToken = PortalToken.refreshToken(Token, true);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        if (
            venue.Account__r.CustomerId__c == VerificationString
            || [SELECT Id FROM Invoice__c WHERE Account__c = :venue.Account__c AND Name = :VerificationString].size() == 1 
            || [SELECT Id FROM Quote WHERE AccountId = :venue.Account__c AND QuoteNumber = :VerificationString].size() == 1 
        ) {
            venue.Uncertainty__c = 9;
            update venue;
            return json.serialize(new ResponseWrapper(NewToken, true));
        }
        return json.serialize(new ResponseWrapper(NewToken, false));
    }
    
    /*method to return the service license info
    **input parameter: String token
    **output parameter: Agrregate result list with serivce license info
    */
    @AuraEnabled
    public static List<AggregateResult> getLicenseInfo(String Token){
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<AggregateResult> ActServices = new  List<AggregateResult>();
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            ActServices = [
                SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp,
                EffectiveStartDate__c efStartDate, EffectiveEndDate__c efEndDate
                FROM SubscriptionLineItem__c
                WHERE Subscription__r.Account__c = :venue.Account__c AND Status_Active_Service__c > 0
                GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c,
                EffectiveStartDate__c, EffectiveEndDate__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('getLicenseInfo: ' + ActServices);
        return ActServices;
    }
    
    /*method to return the cashbook license info
    **input parameter: String token
    **output parameter: Agrregate result list with cashbook license info
    */
    @AuraEnabled
    public static List<AggregateResult> getCashBookInfo(String Token){
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<AggregateResult> ActCashbook = new  List<AggregateResult>();
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            ActCashbook = [
                SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp,
                EffectiveStartDate__c efStartDate, EffectiveEndDate__c efEndDate
                FROM SubscriptionLineItem__c
                WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%Cashbook%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = TRUE
                GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c,EffectiveStartDate__c,EffectiveEndDate__c
            ];
            system.debug('ac5t csh '+ActCashbook);
            if(ActCashbook !=null && ActCashbook.size()>0){
                System.debug('getCashBookInfo: ' + ActCashbook);
                return ActCashbook;
            }else{
                return new List <AggregateResult>();
            }          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*method to return the cashbook TSE info
    **input parameter: String token
    **output parameter: Agrregate result list with TSE license info
    */
    @AuraEnabled
    public static List<AggregateResult> getTseInfo(String Token){
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<AggregateResult> ActTse = new List<AggregateResult>();
        try{
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            ActTse = [
                SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp,
                EffectiveStartDate__c efStartDate, EffectiveEndDate__c efEndDate
                FROM SubscriptionLineItem__c
                WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%TSE%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = TRUE AND Subscription__r.Account__r.BillingCountryCode = 'DE' 
                GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c,EffectiveStartDate__c,EffectiveEndDate__c   
            ];
            if(ActTse !=null && ActTse.size()>0){
                System.debug('getTseInfo: ' + ActTse);
                return ActTse;
            }else{
                return new List <AggregateResult>();
            } 
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<AggregateResult> getGuestBookInfo(String Token){
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<AggregateResult> ActGuestBook = new List<AggregateResult>();
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            ActGuestBook = [
                SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp,
                EffectiveStartDate__c efStartDate, EffectiveEndDate__c efEndDate
                FROM SubscriptionLineItem__c
                WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%Guest Management%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = TRUE
                GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c,EffectiveStartDate__c,EffectiveEndDate__c   
            ];
            if(ActGuestBook !=null && ActGuestBook.size()>0){
                system.debug('ActGuestBook: '+ActGuestBook);
                return ActGuestBook;
            }
            else{
                return new List <AggregateResult>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getDeviceLicense(String Token){
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<deviceLicenceContainer> ActDevices = new List<deviceLicenceContainer>();
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];

            system.debug('A');

            for(SubscriptionLineItem__c currentSub : [SELECT ID, ProductGeneration__c, Quantity__c, Frequency__c, EffectiveStartDate__c, EffectiveEndDate__c, Subscription__r.Status__c, Product__c, Subscription__r.Account__c  FROM SubscriptionLineItem__c WHERE Subscription__r.Account__c = :venue.Account__c AND (Status_Active_Device__c > 0 OR Status_Active_Device__c = 0) AND Product__r.Name LIKE '%Device license%']){
                System.debug('ProductType__c: ' + currentSub.ProductGeneration__c);
                deviceLicenceContainer newDevice = new deviceLicenceContainer();
                newDevice.productGeneration = currentSub.ProductGeneration__c;
                newDevice.billingPeriod = currentSub.Frequency__c;
                newDevice.quantity = Integer.valueOf(currentSub.Quantity__c);
                newDevice.startDate = String.valueOf(currentSub.EffectiveStartDate__c);
                newDevice.endDate = String.valueOf(currentSub.EffectiveEndDate__c);
                newDevice.status = currentSub.Subscription__r.Status__c;
                newDevice.subLineItemId = currentSub.Id;
                newDevice.subLineItemAccount = currentSub.Subscription__r.Account__c;
                newDevice.subLineItemProduct = currentSub.Product__c;
                ActDevices.add(newDevice); 
            }

            system.debug('ActDevices: ' + ActDevices);
            
            if(ActDevices !=null && ActDevices.size()>0){
                system.debug('ActDevices '+ActDevices);
                System.debug('Json.serialize(ActDevices): ' + Json.serialize(ActDevices));
                return Json.serialize(ActDevices);
            }else{
                return '';
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class deviceLicenceContainer{
        public String productGeneration;
        public Integer quantity;
        public String billingPeriod;
        public String startDate;
        public String endDate;
        public String status;
        public String subLineItemId;
        public String subLineItemAccount;
        public String subLineItemProduct;
    }
    
    @AuraEnabled
    public static List<Control_Shift_Settings__mdt> getPrices(String Token, String custCat){
        String NewToken = PortalToken.refreshToken(Token);
        system.debug('cat '+custCat);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        List<Control_Shift_Settings__mdt> listPrice = new List<Control_Shift_Settings__mdt>();
        try {
            listPrice = [select Billing_Period__c,Customer_Category__c,Label,Price__c FROM Control_Shift_Settings__mdt where Customer_Category__c =:custCat];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('getPrices: ' + listPrice);
        return listPrice;
    }
    
    @AuraEnabled
    public Static String getLicenses(String Token) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        List<AggregateResult> ActSer = [
            SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Status_Active_Service__c > 0
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c
        ];
        system.debug('ActSer '+ActSer.size());
        List<AggregateResult> FutSer = [
            SELECT COUNT(Id) numLicenses, EffectiveStartDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Status_Active_Service__c = 0 AND Subscription__r.Status__c = 'Active' AND EffectiveStartDate__c = NEXT_n_DAYS:365 AND Product__r.ProductCategory__r.ProductType__c IN ('POS Service','POS Service+Device') AND (NOT Product__r.Name LIKE '%subsidy%')
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, EffectiveStartDate__c
        ];
        List<AggregateResult> ActCaB = [
            SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%Cashbook%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = TRUE
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c
        ];
        List<AggregateResult> FutCaB = [
            SELECT COUNT(Id) numLicenses, EffectiveStartDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%Cashbook%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = FALSE AND Subscription__r.Status__c = 'Active'
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, EffectiveStartDate__c
        ];
        List<AggregateResult> ActTse = [
            SELECT COUNT(Id) numLicenses, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%TSE%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = TRUE
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c
        ];
        List<AggregateResult> FutTse = [
            SELECT COUNT(Id) numLicenses, EffectiveStartDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Product__r.Name LIKE '%TSE%' AND (NOT Product__r.Name LIKE '%Discount%') AND IsCurrent__c = FALSE AND Subscription__r.Status__c = 'Active'
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, EffectiveStartDate__c
        ];
        List<AggregateResult> ActDev = [
            SELECT SUM(LicensedDevices__c) numDevices, Subscription__r.Status__c status, Subscription__r.AmendmentEffectiveDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Status_Active_Device__c > 0
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, Subscription__r.AmendmentEffectiveDate__c, Subscription__r.Status__c
        ];
        List<AggregateResult> FutDev = [
            SELECT SUM(LicensedDevices__c) numDevices, EffectiveStartDate__c effdate, Product__r.BillingPeriod__c bp, Product__r.SpecificBillingPeriod__c sbp
            FROM SubscriptionLineItem__c
            WHERE Subscription__r.Account__c = :venue.Account__c AND Status_Active_Device__c = 0 AND Subscription__r.Status__c = 'Active' AND LicensedDevices__c > 0 AND EffectiveStartDate__c = NEXT_n_DAYS:365
            GROUP BY Product__r.BillingPeriod__c, Product__r.SpecificBillingPeriod__c, EffectiveStartDate__c
        ];
        System.debug('We have gotten what we need');
        System.debug('response: ' + json.serialize(new ResponseWrapper(NewToken, new LicenseWrapper(ActSer, FutSer, ActDev, FutDev, ActCaB, FutCaB, ActTse, FutTse))));
        return json.serialize(new ResponseWrapper(NewToken, new LicenseWrapper(ActSer, FutSer, ActDev, FutDev, ActCaB, FutCaB, ActTse, FutTse)));
    }
    
    @AuraEnabled
    public Static String getInvoices(String Token) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        List<InvoiceDocWrapper> InvoiceDocs = new List<InvoiceDocWrapper>();
        List<Invoice__c> Invoices = [
            SELECT Id, Name, Amount__c, Balance__c, InvoiceDate__c, CurrencyIsoCode, HasBeenEmailed__c
            FROM Invoice__c 
            WHERE Account__c = :venue.Account__c AND Status__c = 'Posted' AND MismatchTotal__c = FALSE
            ORDER BY Name DESC
            LIMIT 200
        ];

        System.debug('getInvoices - ' + new ResponseWrapper(NewToken, Invoices));
        return json.serialize(new ResponseWrapper(NewToken, Invoices));
    }
    
    @AuraEnabled
    public Static String getTSE(String Token) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        Finanzamt__c fzamt;
        try {
            venue = [
                SELECT Id, Wizard_Complete__c, VATId__c, Login__c, Account__r.Primary_Contact__r.Email, Account__r.LegalCompanyName__c, Account__r.VenueCity__c, Account__r.VenueCountryCode__c, Account__r.VenuePostalCode__c, Account__r.VenueStreet__c, Account__r.BillingCountryCode
                FROM MyObVenue__c 
                WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null 
                LIMIT 1
            ];
            try {
                fzamt = [
                    SELECT Id, Name, Street__c, PostalCode__c, City__c, Email__c, URL__c
                    FROM Finanzamt__c
                    WHERE Id IN (SELECT Finanzamt__c FROM FinanzamtMapping__c WHERE Name = :venue.Account__r.VenuePostalCode__c)
                    LIMIT 1
                ];
            } catch(exception ee){}
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        System.debug('getTSE - ' + new ResponseWrapper(NewToken, new List<sObject>{venue, fzamt}));
        return json.serialize(new ResponseWrapper(NewToken, new List<sObject>{venue, fzamt}));
    }
    
    @AuraEnabled
    public Static String getFinanzamt(String Token, String PostalCode) {
        String NewToken = PortalToken.refreshToken(Token);
        Finanzamt__c fzamt;
        try {
            fzamt = [
                SELECT Id, Name, Street__c, PostalCode__c, City__c, Email__c, URL__c
                FROM Finanzamt__c
                WHERE Id IN (SELECT Finanzamt__c FROM FinanzamtMapping__c WHERE Name = :PostalCode)
                LIMIT 1
            ];
        } catch(exception e){}
        System.debug('getFinanzamt: ' + new ResponseWrapper(NewToken, fzamt));
        return json.serialize(new ResponseWrapper(NewToken, fzamt));
    }
    
    @AuraEnabled
    public Static String createP148Letter(String Token, String Payload, Boolean Download) {
        String NewToken = PortalToken.refreshToken(Token);
        Map<String, Object> Objects = (Map<String, Object>)JSON.deserializeUntyped(Payload);
        Map<String, Object> mapVenue = (Map<String, Object>)Objects.get('Venue');
        Map<String, Object> mapAccount = (Map<String, Object>)mapVenue.get('Account__r');
        Map<String, Object> mapPrimaryContact = (Map<String, Object>)mapAccount.get('Primary_Contact__r');
        Map<String, Object> mapFinanzamt = (Map<String, Object>)Objects.get('Finanzamt');
        
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        Quote firstTseQuote;
        try {
            venue = [
                SELECT Id, Wizard_Complete__c, Account__c, Account__r.CreatedDate, Account__r.Target_Product__c 
                FROM MyObVenue__c 
                WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null 
                LIMIT 1
            ];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        try {
            firstTseQuote = [
                SELECT Id, AcceptedDate__c FROM Quote 
                WHERE Status = 'Accepted' AND AcceptedDate__c != null AND AccountId = :venue.Account__c
                AND Id IN (SELECT QuoteId FROM QuoteLineItem WHERE Product2.Name LIKE '%TSE%')
                ORDER BY AcceptedDate__c ASC
                LIMIT 1
            ];
        } catch(exception e) {}
        DateTime FiscalizedSince = venue.Wizard_Complete__c;
        if (venue.Account__r.Target_Product__c == 'MINI' && venue.Account__r.CreatedDate != null && venue.Account__r.CreatedDate < FiscalizedSince) { FiscalizedSince = venue.Account__r.CreatedDate; }
        if (firstTseQuote != null && firstTseQuote.AcceptedDate__c < FiscalizedSince) { FiscalizedSince = firstTseQuote.AcceptedDate__c; }
        P148Letter__c l = new P148Letter__c(
            Venue__c = venue.Id,
            Email__c = (String)mapPrimaryContact.get('Email'),
            LegalCompanyName__c = (String)mapAccount.get('LegalCompanyName__c'),
            TaxNumber__c = (String)mapVenue.get('VATId__c'),
            VenueStreet__c = (String)mapAccount.get('VenueStreet__c'),
            VenueCity__c = (String)mapAccount.get('VenueCity__c'),
            VenuePostalCode__c = (String)mapAccount.get('VenuePostalCode__c'),
            FiscalizedSince__c = FiscalizedSince,
            F_Name__c = (String)mapFinanzamt.get('Name'),
            F_Street__c = (String)mapFinanzamt.get('Street__c'),
            F_PostalCode__c = (String)mapFinanzamt.get('PostalCode__c'),
            F_City__c = (String)mapFinanzamt.get('City__c'),
            F_Email__c = (String)mapFinanzamt.get('Email__c'),
            F_URL__c = (String)mapFinanzamt.get('URL__c'),
            Download__c = Download
        );
        insert l;
        return json.serialize(new ResponseWrapper(NewToken, l.Id));
    }
    
    @AuraEnabled
    public Static String getP148Key(String Token, String LetterId) {
        String NewToken = PortalToken.refreshToken(Token);
        return json.serialize(new ResponseWrapper(NewToken, PortalToken.encryptPlain(LetterId)));
    }
    
    @AuraEnabled
    public Static String createP148Email(String Token, String LetterId) {
        String NewToken = PortalToken.refreshToken(Token);
        PageReference pageRef = new PageReference('/apex/P148Letter');
        pageRef.getParameters().put('id', LetterId );
        Blob pdfBlob;
        if(!test.isRunningTest()) pdfBlob = pageRef.getContent();
        return json.serialize(new ResponseWrapper(NewToken, test.isRunningTest() ? '' : EncodingUtil.urlEncode(pdfBlob.toString().replace('<p>','<p><br/><br/>').stripHtmlTags(),'UTF-8')));
    }
    
    @AuraEnabled
    public Static String downloadP148Letter(String Token, String LetterId) {
        String NewToken = PortalToken.refreshToken(Token);
        PageReference pageRef = new PageReference('/apex/P148Letter');
        pageRef.getParameters().put('id', LetterId );
        Blob pdfBlob;
        if(!test.isRunningTest()) pdfBlob = pageRef.getContent();
        return json.serialize(new ResponseWrapper(NewToken, test.isRunningTest() ? '' : EncodingUtil.base64Encode(pdfBlob)));
    }
    
    @AuraEnabled
    public Static String getInvoice(String Token, String InvoiceId) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        Invoice__c Invoice = [
            SELECT Id, Name, Amount__c, Balance__c, InvoiceDate__c, Base64Pdf__c, CurrencyIsoCode
            FROM Invoice__c 
            WHERE Account__c = :venue.Account__c AND Status__c = 'Posted' AND MismatchTotal__c = FALSE AND Id = :InvoiceId
            LIMIT 1
        ];
        return json.serialize(new ResponseWrapper(NewToken, Invoice));
    }
    
    @AuraEnabled
    public Static String getQuotes(String Token) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        List<InvoiceDocWrapper> InvoiceDocs = new List<InvoiceDocWrapper>();
        List<Quote> Quotes = [
            SELECT Id, QuoteNumber, Customer_Friendly_Name__c, Status, ExpirationDate, CurrencyIsoCode, Subtotal
            FROM Quote 
            WHERE AccountId = :venue.Account__c AND (Status = 'Draft' OR Status = 'In Review')
            ORDER BY QuoteNumber DESC
        ];
        return json.serialize(new ResponseWrapper(NewToken, Quotes));
    }
    
    @AuraEnabled
    public Static String getQuote(String Token, String QuoteId) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            Quote Quote = [
                SELECT Id, AccountId
                FROM Quote 
                WHERE Id = :QuoteId
                LIMIT 1
            ];
            if (Quote.AccountId == venue.Account__c) {
                QuotePdfController q = new QuotePdfController();
                q.qId = Quote.Id;
                return json.serialize(new ResponseWrapper(NewToken, q));
            }
        } catch(exception e) {}
        return json.serialize(new ResponseWrapper(NewToken, false));
    }
    
    @AuraEnabled
    public Static String getInvoicePDF(String Token, String Invoice) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        String InvoiceId;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            InvoiceId = [SELECT Id FROM Invoice__c WHERE Account__c = :venue.Account__c AND Name = :Invoice AND Status__c = 'Posted' AND MismatchTotal__c = FALSE][0].Id;
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        PageReference pageRef = new PageReference('/apex/InvoiceAttachment');
        pageRef.getParameters().put('id', InvoiceId);
        return json.serialize(new ResponseWrapper(NewToken, test.isRunningTest() ? null : encodingutil.base64Encode(pageRef.getContent())));
    }
    
    @AuraEnabled
    public Static String CreateLicenseQuote(String Token, String Changes) {
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); }
        List<LicenseChange> LicenseChanges = (List<LicenseChange>)JSON.deserialize(Changes, List<LicenseChange>.class);
        Opportunity o = new Opportunity(AccountId=venue.Account__c, Name='MYorderbird Opportunity', CloseDate=Date.today().addDays(30), StageName = 'Potential');
        insert o;
        Quote q = new Quote(OpportunityId=o.Id, Name='License Quote');
        insert q;
        return q.Id;
    }
    
    @AuraEnabled
    public static boolean createWorkOrder(String token, String jsonInput, String operation){
        system.debug('json '+jsonInput+' '+operation);

        system.debug('token '+token);

        List<Work_Order__c> listWorkerOrders = new List<Work_Order__c>();
        Boolean isSuccess = false;
        try {
            Work_Order__c wo = new Work_Order__c();
            wo.Message__c = jsonInput;
            wo.Operation__c = operation;
            wo.token__c = token;
            listWorkerOrders.add(wo);
            Database.SaveResult[] srList = Database.insert(listWorkerOrders, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Work Order. Work Order ID: ' + sr.getId());
                    isSuccess = true;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        isSuccess = false;
                    }
                } 
            }          
        } catch (Exception e) {
            isSuccess = false;
            throw new AuraHandledException(e.getMessage());
        }
        return isSuccess;
    }
    
    @AuraEnabled
    public static String  createNegativeQuote(String Token, List<String> products){
        system.debug('Products are ==> ' + products);
        String NewToken = PortalToken.refreshToken(Token);
        PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(NewToken.replace('-','/').replace('_','+'))
        ).toString(), PortalToken.TokenWrapper.class);
        MyObVenue__c venue;
        try {
            venue = [SELECT Id, Account__c, Account__r.CustomerId__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
        } catch(exception e) { return json.serialize(new ResponseWrapper(NewToken, false)); 
                             }
        List<Product2> listOfProds = [Select Id, Price_EUR__c FROM Product2 WHERE Id=: products];
        List<PriceBookEntry> listOfPBEntries = [Select Id, Product2Id, Product2.Price_EUR__c FROM PriceBookEntry WHERE Product2Id =:listOfProds];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        system.debug('pbentries are ==> ' + listOfPBEntries);
        system.debug('products are == > ' + listOfProds);
        Opportunity o = new Opportunity(AccountId=venue.Account__c, Name='MYorderbird Negative Opportunity', CloseDate=Date.today().addDays(30), StageName = 'Potential', Lac_Shorthand__c='Hotline');
        insert o;
        system.debug('Opportunity is ==> ' + o);
        Quote q = new Quote(OpportunityId=o.id, Name='Negative', Pricebook2ID = pb.Id);
        try{  insert q;}
        catch(Exception ep){
            system.debug(ep.getMessage());
        }
        List<QuoteLineItem> listOfQLIs = new List<QuoteLineItem>();
        for(PriceBookEntry pbentry : listOfPBEntries){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = q.Id;
            qli.Product2Id = pbentry.Product2Id;
            qli.UnitPrice = - + pbentry.Product2.Price_EUR__c;
            qli.Quantity = 1;
            qli.PriceBookEntryId = pbentry.Id;
            listOfQLIs.add(qli);
        }
        system.debug('List OF QLIs is ' + listOfQLIs);
        insert listOfQLIs;
        
        return q.Id;
    }
    
    public class PortalWrapper {
        public Account Account;
        public MyObVenue__c Venue;
        public PortalToken.TokenWrapper TokenWrapper;
        public PortalWrapper(Account iAccount, MyObVenue__c iVenue) {
            Account = iAccount;
            Venue = iVenue;
        }
        public PortalWrapper(PortalToken.TokenWrapper tw) {
            TokenWrapper = tw;
        }
    }
    
    public class ResponseWrapper {
        public String Token;
        public String StringValue;
        public Boolean BooleanValue;
        public Boolean IsResub;
        public List<sObject> Objects;
        public sObject xObject;
        public QuotePdfController QuoteData;
        public LicenseWrapper LicenseData;
        public String RecordId;
        public ResponseWrapper(String strToken, Boolean boolBooleanValue) {
            Token = strToken;
            BooleanValue = boolBooleanValue;
        }
        public ResponseWrapper(String strToken, List<sObject> lstObjects) {
            Token = strToken;
            Objects = lstObjects;
        }
        public ResponseWrapper(String strToken, sObject inpObject) {
            Token = strToken;
            xObject = inpObject;
        }
        public ResponseWrapper(String strToken, String strValue) {
            Token = strToken;
            StringValue = strValue;
        }
        public ResponseWrapper(String strToken, LicenseWrapper lw) {
            Token = strToken;
            LicenseData = lw;
        }
        public ResponseWrapper(String strToken, QuotePdfController qpc) {
            Token = strToken;
            QuoteData = qpc;
        }
        public ResponseWrapper(String strToken, String rId, Boolean status, Boolean reSub ) {
            Token = strToken;
            RecordId = rId;
            BooleanValue = status;
            IsResub = reSub;
        }
    }
    
    public class LicenseWrapper {
        public LicenseCount Service;
        public LicenseCount Cashbook;
        public LicenseCount TSE;
        public Map<String, LicenseCount> Device;
        public LicenseWrapper(List<AggregateResult> ActSer, List<AggregateResult> FutSer, List<AggregateResult> ActDev, List<AggregateResult> FutDev, List<AggregateResult> ActCaB, List<AggregateResult> FutCaB, List<AggregateResult> ActTse, List<AggregateResult> FutTse) {
            Device = new Map<String, LicenseCount>();
            Service = new LicenseCount();
            Cashbook = new LicenseCount();
            TSE = new LicenseCount();
            for (String s : FreqMap.keySet()) {
                Device.put(s, new LicenseCount());
            }
            for (AggregateResult ar : ActSer) {
                String bp = (String)ar.get('bp');
                String sbp = (String)ar.get('sbp');
                String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { 
                    if (bp == FreqMap.get(s) || sbp == s) {
                        Service.Current = s;
                        if (status != 'Active') { Service.Changes.add(new LicenseChange('Expiring', 1, (Date)ar.get('effdate'), s)); }
                    }
                }
            }
            for (AggregateResult ar : FutSer) {
                String bp = (String)ar.get('bp'); String sbp = (String)ar.get('sbp'); String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { if (bp == FreqMap.get(s) || sbp == s) { Service.Changes.add(new LicenseChange('Future', 1, (Date)ar.get('effdate'), s)); } }
            }
            for (AggregateResult ar : ActCaB) {
                String bp = (String)ar.get('bp');
                String sbp = (String)ar.get('sbp');
                String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { 
                    if (bp == FreqMap.get(s) || sbp == s) {
                        Cashbook.Current = s;
                        if (status != 'Active') { Cashbook.Changes.add(new LicenseChange('Expiring', 1, (Date)ar.get('effdate'), s)); }
                    }
                }
            }
            for (AggregateResult ar : FutCaB) {
                String bp = (String)ar.get('bp'); String sbp = (String)ar.get('sbp'); String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { if (bp == FreqMap.get(s) || sbp == s) { Cashbook.Changes.add(new LicenseChange('Future', 1, (Date)ar.get('effdate'), s)); } }
            }
            for (AggregateResult ar : ActTse) {
                String bp = (String)ar.get('bp');
                String sbp = (String)ar.get('sbp');
                String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { 
                    if (bp == FreqMap.get(s) || sbp == s) {
                        TSE.Current = s;
                        if (status != 'Active') { TSE.Changes.add(new LicenseChange('Expiring', 1, (Date)ar.get('effdate'), s)); }
                    }
                }
            }
            for (AggregateResult ar : FutTse) {
                String bp = (String)ar.get('bp'); String sbp = (String)ar.get('sbp'); String status = (String)ar.get('status');
                for (String s : FreqMap.keySet()) { if (bp == FreqMap.get(s) || sbp == s) { TSE.Changes.add(new LicenseChange('Future', 1, (Date)ar.get('effdate'), s)); } }
            }
            for (AggregateResult ar : ActDev) {
                String bp = (String)ar.get('bp');
                String sbp = (String)ar.get('sbp');
                String status = (String)ar.get('status');
                Integer num = ((Decimal)ar.get('numDevices')).intValue();
                for (String s : FreqMap.keySet()) {
                    if (bp == FreqMap.get(s) || sbp == s) {
                        if (status == 'Active') { 
                            Device.get(s).Active += num;
                        } else {
                            Device.get(s).Expiring += num;
                            Device.get(s).Changes.add(new LicenseChange('Expiring', num, (Date)ar.get('effdate'), null));
                        }
                    }
                }
            }
            for (AggregateResult ar : FutDev) {
                String bp = (String)ar.get('bp'); String sbp = (String)ar.get('sbp'); Integer num = ((Decimal)ar.get('numDevices')).intValue();
                for (String s : FreqMap.keySet()) { if (bp == FreqMap.get(s) || sbp == s) { Device.get(s).Changes.add(new LicenseChange('Future', num, (Date)ar.get('effdate'), null)); } }
            }
        }
    }
    
    public static Map<String,String> FreqMap = new Map<String,String>{'1'=>'Month','12'=>'Annual','36'=>'Three_Years','120'=>'Ten_Years'};
        
        public class LicenseChange{
            public String Type; public Integer Num; public Date EffDate; public String Freq;
            public LicenseChange(String iType, Integer iNum, Date iEffDate, String iFreq) {
                Type = iType; Num = iNum; EffDate = iEffDate; Freq = iFreq;
            }
        }
    
    public class LicenseCount{
        public Integer Active;
        public Integer Expiring;
        public String Current;
        public List<LicenseChange> Changes;
        public LicenseCount() {
            Active = 0;
            Expiring = 0;
            Current = 'None';
            Changes = new List<LicenseChange>();
        }
    }
    
    public class InvoiceDocWrapper implements Comparable{
        public Invoice__c Invoice;
        public Id ContentDocumentId;
        public String InvoiceName;
        public InvoiceDocWrapper(Invoice__c iInvoice, Id CDId) {
            Invoice = iInvoice;
            ContentDocumentId = CDId;
            InvoiceName = iInvoice.Name;
        }
        public Integer compareTo(Object compareTo) {
            InvoiceDocWrapper compareToIDW = (InvoiceDocWrapper)compareTo;
            if (InvoiceName > compareToIDW.InvoiceName) return 1;
            return -1;
        }
    }
    
    @AuraEnabled
    public Static String getInsightEmail(String token){
        system.debug('token '+token);
        String NewToken = PortalToken.refreshToken(Token,true);
        system.debug('new token '+NewToken);
        string tk =PortalToken.decryptToken(NewToken).VenueId;
        system.debug('here '+tk);
        MyObVenue__c v;
        try {               
            v = [
                SELECT Id, Contact__r.Name,InsightsEmail__c, MyOrderbirdId__c, Token__c, Uncertainty__c,
                InsightsUnsubbed__c, InsightsResubbed__c, Hourly_Revenue__c,Average_Revenue__c, Food_Drinks_Ratio__c
                FROM MyObVenue__c
                WHERE MyOrderbirdId__c = :PortalToken.decryptToken(NewToken).VenueId
                LIMIT 1
            ];
            
        }catch(Exception ep){
            system.debug('ep '+ep.getMessage());
        }       
        return json.serialize(new ResponseWrapper(NewToken, v));
    }   
    
    @AuraEnabled
    public Static String getInsightEmailfromEmail(String token){
        // NewToken = PortalToken.refreshToken(Token);
        PortalEmailWrapper pmm;
        MyObVenue__c v;
        pmm = new PortalEmailWrapper(PortalToken.decryptEmailToken(token,false));
        system.debug('pw '+pmm.TokenWrapper.Expired);
        if(pmm.TokenWrapper.Expired == true){
            system.debug('true true');
            throw new AuraHandledException('Token not valid');
        }
        else{
            try {               
                v = [
                    SELECT Id, Contact__r.Name,InsightsEmail__c, MyOrderbirdId__c, Token__c, Uncertainty__c,
                    InsightsUnsubbed__c, InsightsResubbed__c
                    FROM MyObVenue__c
                    WHERE Email_Index__c =:PortalToken.decryptEmailToken(token,false).EmailIndex
                    LIMIT 1
                ];
                
            }catch(Exception ep){
                system.debug('ep '+ep.getMessage());
            }  
        }     
        return json.serialize(new ResponseWrapper(token, v));
    } 
    
    @AuraEnabled
    public static Boolean updateEmail(String myObjId, String newEmail){
        system.debug('obj '+myObjId);
        boolean isSuccess = false;
        MyObVenue__c myObj;
        try{
            myObj=[SELECT Id, InsightsEmail__c 
                   FROM MyObVenue__c
                   WHERE Id =: myObjId];
            if(!String.isBlank(myObj.Id)){
                myObj.InsightsEmail__c = newEmail; 
            }
            try{
                update myObj;
                isSuccess =true; 
            }catch(Exception ep){
                system.debug(ep.getMessage());
            }       
        }catch(Exception ep){
            isSuccess = false;
        }   
        return isSuccess;
    }
    
    /*   @AuraEnabled
public Static String getInsightSubscription(String token){
String NewToken = PortalToken.refreshToken(Token);
MyObVenue__c v;
try {               
v = [
SELECT Id, Contact__r.Name,InsightsEmail__c, MyOrderbirdId__c, Token__c,InsightsUnsubbed__c,
InsightsResubbed__c
FROM MyObVenue__c
WHERE MyOrderbirdId__c = :PortalToken.decryptToken(NewToken).VenueId
LIMIT 1
];
}catch(Exception ep){
system.debug('ep '+ep.getMessage());
}            
return json.serialize(new ResponseWrapper(newToken, v.Id, v.InsightsUnsubbed__c, v.InsightsResubbed__c));
}*/
    
    @AuraEnabled
    public static Boolean updateSubscription(String venueId, Boolean status){
        Boolean statusChanged = false;
        MyObVenue__c myVenue;
        try {
            myVenue = [select id, InsightsUnsubbed__c, InsightsResubbed__c from MyObVenue__c where Id =:venueId];
            if(status == false){
                myVenue.InsightsUnsubbed__c = true;
                myVenue.InsightsResubbed__c = false;
                try{
                    update myVenue;
                    statusChanged =true; 
                }catch(Exception ep){
                    system.debug(ep.getMessage());
                }
            } 
            if(status == true){
                myVenue.InsightsUnsubbed__c = false;
                myVenue.InsightsResubbed__c = true;
                try{
                    update myVenue;
                    statusChanged =true; 
                }catch(Exception ep){
                    system.debug(ep.getMessage());
                }
            }      
        } catch (Exception e) {
            statusChanged =false;
            throw new AuraHandledException(e.getMessage());           
        }
        return statusChanged;
    }
    @AuraEnabled
    public static List<String> getInsightHourlyOption(){
        List<String> listOptions = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = MyObVenue__c.Hourly_Revenue__c.getDescribe();
            system.debug('fieldResult '+fieldResult);
            List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pValues) {
                system.debug('p++++ '+p.getValue()+' '+p.getLabel());
                listOptions.add(p.getValue());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listOptions;
    }
    
    @AuraEnabled
    public static List<String> getAverageRevenue(){
        List<String> listOptionsAverage = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = MyObVenue__c.Average_Revenue__c.getDescribe();
            system.debug('fieldResult '+fieldResult);
            List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pValues) {
                system.debug('p++++ '+p.getValue()+' '+p.getLabel());
                listOptionsAverage.add(p.getValue());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listOptionsAverage;
    }
    
    @AuraEnabled
    public static List<String> getFoodDrinkRatio(){
        List<String> listOptionsFoodDrink = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = MyObVenue__c.Food_Drinks_Ratio__c.getDescribe();
            system.debug('fieldResult '+fieldResult);
            List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pValues) {
                system.debug('p++++ '+p.getValue()+' '+p.getLabel());
                listOptionsFoodDrink.add(p.getValue());
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listOptionsFoodDrink;
    }
    
    @AuraEnabled
    public static Boolean updateMetricOptions(String hourlyRev, String avg, String food, String recordId){
        List<MyObVenue__c> listObjtoUpdate = new List<MyObVenue__c>();
        Boolean isSuccess =false;
        try {
            system.debug('called '+recordId+' '+hourlyRev+' '+avg+' '+food);
            List<MyObVenue__c> listExisting = [select id, Hourly_Revenue__c,Average_Revenue__c, Food_Drinks_Ratio__c
                                               FROM MyObVenue__c
                                               WHERE id =:recordId];
            
            for(MyObVenue__c myObj:listExisting){
                system.debug('myObj.Hourly_Revenue__c '+avg);
                myObj.Hourly_Revenue__c = !String.isBlank(hourlyRev) ? hourlyRev: myObj.Hourly_Revenue__c;
                myObj.Average_Revenue__c = !String.isBlank(avg) ? avg: myObj.Average_Revenue__c;
                myObj.Food_Drinks_Ratio__c = !String.isBlank(food) ? food: myObj.Food_Drinks_Ratio__c;
                listObjtoUpdate.add(myObj);        
            }
            Database.SaveResult[] srList = Database.update(listObjtoUpdate, true);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    isSuccess = true;
                }else {
                    for (Database.Error err : sr.getErrors()) {
                        isSuccess = false;
                        System.debug(err.getStatusCode() + ' : ' + err.getMessage() + ' : ' + err.getFields());
                    }
                }
            }      
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isSuccess;
    }
    
    public class PortalEmailWrapper {
        public Account Account;
        public MyObVenue__c Venue;
        public PortalToken.TokenEmailWrapper TokenWrapper;
        public PortalEmailWrapper(Account iAccount, MyObVenue__c iVenue) {
            Account = iAccount;
            Venue = iVenue;
        }
        public PortalEmailWrapper(PortalToken.TokenEmailWrapper tw) {
            TokenWrapper = tw;
        }
    }
}