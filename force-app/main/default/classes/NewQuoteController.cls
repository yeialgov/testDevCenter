public class NewQuoteController {

    /****
    /* Actions
    /*
    /****/

    @AuraEnabled
    public static String upsertQuote(
        String JSONPayload, 
        String BundleMap, 
        String PriceMap, 
        String OpportunityName,
        String OpportunityId,
        String QuoteId,
        String curr
    ) {
        // deserialize payload
        JItemList PayloadData = (JItemList)JSON.deserialize(JSONPayload, JItemList.class);
        Map<String,Object> Bundles = (Map<String,Object>)JSON.deserializeUntyped(BundleMap.replace('_',''));

        // update/insert Quote
        Boolean isInsert = true;
        system.debug(JSONPayload);
        system.debug(curr);
        Set<String> ProdIds = new Set<String>();
        for (JItem Item : PayloadData.Items) {
            if (Item.Num > 0) {
                ProdIds.add(Item.Id);
                JBundle jb = (JBundle)(JSON.deserialize(JSON.serialize(Bundles.get(Item.Id)),JBundle.class));
                try { for (JBundleItem bundleItem : jb.ProductBundleAssignmentsr.records) { ProdIds.add(bundleItem.Productr.Id); } } catch (exception e) {}
            }
        }
        List<Product2> RecurProducts = [SELECT Id FROM Product2 WHERE Type__c = 'Recurring' AND Model__c IN ('PerUnit','FlatFee') AND Id IN :ProdIds];
        Quote Quote = new Quote(
            Pricebook2Id = [SELECT Id From Pricebook2 WHERE Key__c = 'Main' LIMIT 1].Id,
            //Tax = PayloadData.TaxAmount,
            Tax = 0,
            ContractEffectiveDate__c = PayloadData.Details.ContractEffectiveDate,
            InvoiceDate__c = PayloadData.Details.ContractEffectiveDate,
            InvoiceTargetDate__c = PayloadData.Details.ServiceActivationDate,
            POS_Start_Date__c = PayloadData.Details.ServiceActivationDate,
            ExpirationDate = PayloadData.Details.ExpirationDate,
            Pay_by_Instalment__c = PayloadData.Details.PayByInstalment,
            PaymentMethod__c = PayloadData.Details.PaymentMethod,
            WireFirstPayment__c = PayloadData.Details.WireFirstPayment,
            PayPalLink__c = PayloadData.Details.PayPalLink,
            InvoiceOwner__c = LeasingMap.get(PayloadData.Details.InvoiceOwner),
            Contains_Recurring_Items__c = RecurProducts.size() > 0,
            CurrencyIsoCode = curr
        );
        system.debug(Quote.Pricebook2Id);
        if (Quote.InvoiceDate__c > Date.today()) Quote.InvoiceDate__c = Date.today();
        if (QuoteId != null) {
            Quote.Id = QuoteId;
            isInsert = false;
            update Quote;
        } else {
            Quote.Name = OpportunityName;
            Quote.OpportunityId = OpportunityId;
            try{insert Quote;}catch(exception e){return JSON.serialize(new QuoteWrapper(e.getMessage()));}
        }
        
        // remove old QLIs
        delete [SELECT Id FROM QuoteLineItem WHERE QuoteId = :QuoteId];

        // insert QLIs
        system.debug(BundleMap);
        Set<String> DuplicateBlocker = new Set<String>();
        Map<String,Object> Prices = (Map<String,Object>)JSON.deserializeUntyped(PriceMap.replace('_',''));
        List<QuoteLineItem> QLIs = new List<QuoteLineItem>();
        for (JItem Item : PayloadData.Items) {
            if (Item.Num < 0) {
                system.debug('--->' + json.serialize(Item));
                if (!DuplicateBlocker.contains(Item.ProdId)) {
                    DuplicateBlocker.add(Item.ProdId);
                    QLIs.add(
                        new QuoteLineItem(
                            QuoteId = Quote.Id,
                            Product2Id = Item.ProdId,
                            SubscriptionLineItem__c = Item.Id,
                            Quantity = Item.Num,
                            PricebookEntryId = Item.pricebookentryid,
                            UnitPrice = Item.unitprice,
                            BillingPeriodDurationOverride__c = Item.DiscountPeriods
                        )
                    );
                }
            } else if (
                Item.isBundle 
                && (
                    (Item.Num != null && isInsert) 
                    || (!Item.isBundleItem && !isInsert)
                    )
                ) {
                JBundle jb = (JBundle)(JSON.deserialize(JSON.serialize(Bundles.get(Item.Id)),JBundle.class));
                for (JBundleItem bundleItem : jb.ProductBundleAssignmentsr.records) {
                    JPriceMapping jpm = (JPriceMapping)(JSON.deserialize(
                        JSON.serialize(Prices.get(curr + ':' + bundleItem.Productr.ZuoraIdc)),
                        JPriceMapping.class
                    ));
                    if (!DuplicateBlocker.contains(bundleItem.Productr.Id + ':' + Item.Id)) {
                        DuplicateBlocker.add(bundleItem.Productr.Id + ':' + Item.Id);
                        QLIs.add(
                            new QuoteLineItem(
                                QuoteId = Quote.Id,
                                Product2Id = bundleItem.Productr.Id,
                                PricebookEntryId = jpm.PBE,
                                Quantity = Item.Num,
                                UnitPrice = jpm.Price,
                                ProductBundle__c = Item.Id
                            )
                        );
                    }
                }
            } else if ((Item.Num != null && isInsert) || (!Item.isBundleItem && !isInsert)) {
                if (!DuplicateBlocker.contains(Item.Id)) {
                    DuplicateBlocker.add(Item.Id);
                    QLIs.add(
                        new QuoteLineItem(
                            QuoteId = Quote.Id,
                            Product2Id = Item.Id,
                            PricebookEntryId = Item.pricebookentryid,
                            Quantity = Item.Num,
                            UnitPrice = Item.unitprice,
                            BillingPeriodDurationOverride__c = Item.DiscountPeriods
                        )
                    );
                }
            }
        }
        if (!test.isRunningTest()) insert QLIs;
        
        // update Opportunity amount
        Opportunity Opp = [
            SELECT Id, Amount, Max_Quote_Value__c 
            FROM Opportunity 
            WHERE Id IN (SELECT OpportunityId FROM Quote WHERE Id=:Quote.Id)
            LIMIT 1
        ];
        Opp.Amount = Opp.Max_Quote_Value__c;
        update Opp;

        // return Quote Id to navigate to record
        return JSON.serialize(new QuoteWrapper(Quote.Id));
    }
    
    public class QuoteWrapper {
        public Id QuoteId { get; set; }
        public String ErrorMsg { get; set; }
        public QuoteWrapper(Id qId) {
            QuoteId = qId;
        }
        public QuoteWrapper(String errMsg) {
            ErrorMsg = errMsg;
        }
    }

    @AuraEnabled
    public static void forecastInvoice(String QuoteId) {

        system.debug(ZuoraSyncController.cleanJSONRequest(JSON.serialize(
                    new ZObj.CreatePreviewReq(QuoteId)
                )));
        ZObj.PreviewSubRes Preview = ((ZObj.PreviewSubRes)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'subscriptions/preview', 
                'POST', 
                ZuoraSyncController.cleanJSONRequest(JSON.serialize(
                    new ZObj.CreatePreviewReq(QuoteId)
                ))
            ), 
            ZObj.PreviewSubRes.class
        ));

        Quote Quote = [SELECT Id, Tax, InvoiceForecast__c FROM Quote WHERE Id = :QuoteId LIMIT 1];
        Quote.Tax = Preview.invoice.taxAmount;
        Quote.InvoiceForecast__c = Preview.invoice.amount;

        List<QuoteLineItem> QLIs = [
            SELECT Id, Product2.ZuoraId__c, UnitPrice 
            FROM QuoteLineItem 
            WHERE Product2.Model__c = 'DiscountFixedAmount' AND QuoteId = :Quote.Id
        ];

        Set<String> Discounts = new Set<String>();
        
        for (QuoteLineItem QLI : QLIs) {
            Boolean Found = false;
            for (ZObj.PreviewInvItem InvItem : Preview.invoice.invoiceItems) {
                if (QLI.Product2.ZuoraId__c == InvItem.productRatePlanChargeId) {
                    Found = true;
                    if (Discounts.contains(QLI.Id)) {
	                    QLI.UnitPrice += InvItem.chargeAmount;
                    } else {
	                    QLI.UnitPrice = InvItem.chargeAmount;
                        Discounts.add(QLI.Id);
                    }
                }
            }
            if (!Found) QLI.UnitPrice = 0;
        }

        update Quote;
        update QLIs;
    }

    /*@AuraEnabled
    public static Boolean sendPdfEmails(
        String RecordId, 
        String ContactIdsString, 
        String CCsString,
        String sObjectName,
        String EmailSubject,
        String EmailText,
        String Attachments
    ) {
        return sendPdfEmails(RecordId, ContactIdsString, CCsString, sObjectName, EmailSubject, EmailText, null);
    }
    
    @AuraEnabled
    public static Boolean sendInvoicesEmail(
        String RecordIdsString,
        String ContactIdsString,
        String CCsString,
        String EmailSubject,
        String EmailText
    ) {
        List<String> RecordIds = (List<String>)JSON.deserialize(RecordIdsString, List<String>.class);
        List<Invoice__c> Invoices = [SELECT Id, Name, ZuoraId__c, Account__r.PrimaryLanguage__c FROM Invoice__c WHERE Id IN :RecordIds];
        String Language = Invoices[0].Account__r.PrimaryLanguage__c;
        if (Language != 'English' && Language != 'French') Language = 'German';
        String OWEAId = [select Id from OrgWideEmailAddress where Address = 'noreply@orderbird.com' LIMIT 1].Id;
        
        Map<String, String> TemplateMap = new Map<String, String>();
        for (StaticResource TSR : [
            SELECT Id, Name, Body 
            FROM StaticResource 
            WHERE Name LIKE 'ReplacementTemplate%'
            ORDER BY Name DESC
        ]) {
            TemplateMap.put(TSR.Name, TSR.Body.toString());
        }
        
        String TextBody = EmailText;
        TextBody = TextBody.replace('<p>','').replace('</p>','\n').replace('<br>','\n').replace('<br/>','\n');
        TextBody = EncodingUtil.URLDecode(TextBody, 'UTF-8');
        EmailText = TemplateMap.get('ReplacementTemplate' + Language).replace('<!--%%REPLACE%%-->',EmailText);
        
        List<String> ContactIds = (List<String>)JSON.deserialize(ContactIdsString, List<String>.class);
        List<String> CCs = (List<String>)JSON.deserialize(CCsString, List<String>.class);
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        List<ContentVersion> insCVs = new List<ContentVersion>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        for (Invoice__c inv : Invoices) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(inv.Name + '.pdf');
            PageReference pageRef = new PageReference('/apex/InvoiceAttachment');
            pageRef.getParameters().put('id', inv.Id );
            Blob pdfBlob = null;
            if (!Test.isRunningTest()) pdfBlob = pageRef.getContent();
            efa.setBody(pdfBlob);
            fileAttachments.add(efa);
            insCVs.add(new ContentVersion(
                ContentLocation = 'S',
                IsInvoice__c = true,
                VersionData = pdfBlob,
                Title = 'orderbird Invoice : ' + inv.Id + ' sent ' + String.valueOf(DateTime.now()),
                PathOnClient = '/Invoice.pdf'
            ));
        }

        for (String ContactId : ContactIds) {
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setTreatBodiesAsTemplate(true);
            em.setHtmlBody(EmailText);
            em.setPlainTextBody(TextBody);
            em.setSubject(EmailSubject);
            em.setTargetObjectID(ContactId);
            em.setSaveAsActivity(true);
            em.setCCAddresses( CCs );
            em.setBccAddresses( new List<String>{} );
            em.setOrgWideEmailAddressId(OWEAId);
            em.setFileAttachments(fileAttachments);
            Emails.add(em);
        }

        if (!test.isRunningTest()) Messaging.sendEmail( Emails );

        List<EmailMessageRelation> EMRs;
        
        try {EMRs = [
            SELECT EmailMessageId 
            FROM EmailMessageRelation 
            WHERE RelationId IN :ContactIds
            ORDER BY CreatedDate DESC
            LIMIT :Emails.size()
        ];} catch(exception e){}
        
        if (!test.isRunningTest()) insert insCVs;

        Set<Id> CVIdSet = new Set<Id>();
        for (ContentVersion CV : insCVs) {
            CVIdSet.add(CV.Id);
        }

        List<String> ContentDocumentIds = new List<String>();
        for (ContentVersion newCV : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :CVIdSet]) {
            ContentDocumentIds.add(newCV.ContentDocumentId);
        }

        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        for (EmailMessageRelation EMR : EMRs) {
            for (String CDId : ContentDocumentIds) {
                CDLs.add(new ContentDocumentLink(
                    ShareType = 'v',
                    LinkedEntityId = EMR.EmailMessageId,
                    ContentDocumentId = CDId
                ));
            }
        }
        if (!test.isRunningTest()) insert CDLs;

        return true;
    }
    
    @AuraEnabled
    public static Boolean sendPdfEmails(
        String RecordId, 
        String ContactIdsString, 
        String CCsString,
        String sObjectName,
        String EmailSubject,
        String EmailText,
        String Attachments,
        String OWEAId
    ) {
        String RecordName;
        String Language;
        String InvoiceZId;
        if (sObjectName == 'Quote') {
            Quote Quote = [
                SELECT Id, Status, ExpirationDate, QuoteNumber, QuoteEmailed__c, Account.PrimaryLanguage__c
                FROM Quote 
                WHERE Id = :RecordId 
                LIMIT 1
            ];
            RecordName = Quote.QuoteNumber;
            Quote.QuoteEmailed__c = true;
            if (Quote.Status == 'Draft') {
                Quote.Status = 'In Review';
                Quote.ExpirationDate = Date.today() + 30;
                update Quote;
            }
            Language = Quote.Account.PrimaryLanguage__c;
        }

        if (sObjectName == 'Invoice__c') {
            Invoice__c Invoice = [SELECT Id, Name, ZuoraId__c, Account__r.PrimaryLanguage__c FROM Invoice__c WHERE Id=:RecordId LIMIT 1];
            RecordName = Invoice.Name;            
            Language = Invoice.Account__r.PrimaryLanguage__c;
            InvoiceZId = Invoice.ZuoraId__c;
            OWEAId = [select Id from OrgWideEmailAddress where Address = 'noreply@orderbird.com' LIMIT 1].Id;
        }

        if (Language != 'English' && Language != 'French') Language = 'German';
        
        Map<String, String> TemplateMap = new Map<String, String>();
        for (StaticResource TSR : [
            SELECT Id, Name, Body 
            FROM StaticResource 
            WHERE Name LIKE 'ReplacementTemplate%'
            ORDER BY Name DESC
        ]) {
            TemplateMap.put(TSR.Name, TSR.Body.toString());
        }
        
        String TextBody = EmailText;
        TextBody = TextBody.replace('<p>','').replace('</p>','\n').replace('<br>','\n').replace('<br/>','\n');
        TextBody = EncodingUtil.URLDecode(TextBody, 'UTF-8');
        EmailText = TemplateMap.get('ReplacementTemplate' + Language).replace('<!--%%REPLACE%%-->',EmailText);
        
        List<Id> CDIds = new List<Id>();
        List<String> ContactIds = (List<String>)JSON.deserialize(ContactIdsString, List<String>.class);
        List<String> CCs = (List<String>)JSON.deserialize(CCsString, List<String>.class);
        List<String> ContentDocumentIds = (List<String>)JSON.deserialize(Attachments, List<String>.class);
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        String ObjectName = sObjectName.replace('__c','');
        List<ContentVersion> insCVs = new List<ContentVersion>();
        List<ContentVersion> CVs = [
            SELECT Id, VersionData, Title, FileExtension
            FROM ContentVersion 
            WHERE IsLatest = true AND ContentDocumentId IN :ContentDocumentIds
        ];
            
        /////attachment
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        efa.setFileName(ObjectName + '.pdf');
        PageReference pageRef = new PageReference('/apex/' + ObjectName + 'Attachment');
        pageRef.getParameters().put('id', RecordId );
        Blob pdfBlob = null;
        if (!Test.isRunningTest()) pdfBlob = pageRef.getContent();
        efa.setBody(pdfBlob);
        fileAttachments.add(efa);

        for (ContentVersion CV : CVs) {
            Messaging.Emailfileattachment efattach = new Messaging.Emailfileattachment();
            efattach.setFileName(CV.Title + '.' + CV.FileExtension);
            efattach.setBody(CV.VersionData);
            fileAttachments.add(efattach);
        }

        insCVs.add(new ContentVersion(
            ContentLocation = 'S',
            IsInvoice__c = (ObjectName == 'Invoice'),
            VersionData = pdfBlob,
            Title = 'orderbird ' + ObjectName + ' : ' + RecordName + ' sent ' + String.valueOf(DateTime.now()),
            PathOnClient = '/' + ObjectName + '.pdf'
        ));

        CVs.addAll(insCVs);

        for (String ContactId : ContactIds) {
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setTreatBodiesAsTemplate(true);
            em.setHtmlBody(EmailText);
            em.setPlainTextBody(TextBody);
            em.setSubject(EmailSubject);
            em.setTargetObjectID(ContactId);
            em.setWhatId(RecordId);
            em.setSaveAsActivity(true);
            //em.setToAddresses( ContactIds );
            em.setCCAddresses( CCs );
            em.setBccAddresses( new List<String>{} );
            em.setOrgWideEmailAddressId(OWEAId);
            em.setFileAttachments(fileAttachments);
            Emails.add(em);
        }

        if (!test.isRunningTest()) Messaging.sendEmail( Emails );

        system.enqueueJob(new EnqueueZuoraEmailUpdate( new List<String>{ InvoiceZId } ));

        List<EmailMessageRelation> EMRs;
        
        try {EMRs = [
            SELECT EmailMessageId 
            FROM EmailMessageRelation 
            WHERE RelationId IN :ContactIds
            ORDER BY CreatedDate DESC
            LIMIT :Emails.size()
        ];} catch(exception e){}
        
        if (!test.isRunningTest()) insert insCVs;

        Set<Id> CVIdSet = new Set<Id>();
        for (ContentVersion CV : insCVs) {
            CVIdSet.add(CV.Id);
        }

        for (ContentVersion newCV : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :CVIdSet]) {
            ContentDocumentIds.add(newCV.ContentDocumentId);
        }

        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        for (EmailMessageRelation EMR : EMRs) {
            for (String CDId : ContentDocumentIds) {
                CDLs.add(new ContentDocumentLink(
                    ShareType = 'v',
                    LinkedEntityId = EMR.EmailMessageId,
                    ContentDocumentId = CDId
                ));
            }
        }
        if (!test.isRunningTest()) insert CDLs;

        return true;
    } */

    /****
    /* Query Actions returning Stringified JSON
    /*
    /****/

    @AuraEnabled
    public static String getCatalog(String Curr, String AccountZId) {
        return JSON.serialize(new CatalogWrapper([
            SELECT 
                Id, Name, ZuoraId__c, Hidden__c, Visibility__c, (
                    SELECT 
                        Id, Name, ZuoraId__c, ZuoraSubCategoryId__c, Model__c, Type__c, Taxable__c, LocalizedAvailability__c,
                        IsActive, VisibleToAll__c, VisibleToAcctMgmt__c, TriggerEvent__c, ManualDiscount__c, DisplayName__c, Maximum_Discount__c, Lead_Source_Restriction__c
                    FROM Products__r 
                    /*WHERE Id IN (
                        SELECT Product2Id 
                        FROM PricebookEntry 
                        WHERE 
                            Pricebook2.Key__c = :Curr
                            AND UnitPrice != 0
                            AND IsActive = TRUE
                    )*/
                    ORDER BY Name
                ), (
                    SELECT
                        Id,
                        Name,
                        Model__c,
                    	Hidden__c
                    FROM Product_Bundles__r
                ) 
            FROM ProductCategory__c 
            ORDER BY Name
        ],[
            SELECT 
                Id, Quantity__c, Product__r.Name, Subscription__r.TermType__c, Product__c,
                EffectiveStartDate__c, Product__r.Type__c, Product__r.ZuoraId__c,
            	Product__r.ProductCategory__r.Name
            FROM SubscriptionLineItem__c
            WHERE 
                Subscription__r.Status__c = 'Active' 
                AND Subscription__r.Account__c = :AccountZId
                AND Quantity__c >= 1
            	AND Product__r.Name != 'VAT 16%'
            	AND Product__r.Name != 'VAT 19%'
            ORDER BY Product__r.Name ASC, EffectiveStartDate__c DESC
        ]));
    }
    
    @AuraEnabled
    public static String getPrices(String Curr) {
        return JSON.serialize(new JPricingWrapper([
            SELECT 
                Id, 
                Key__c, 
                UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.Key__c = 'Main' AND Key__c LIKE :Curr + ':%'
        ],[
            SELECT
                Id,
                Name, (
                    SELECT 
                        Product__c,
                        Product__r.Name,
                        Product__r.ZuoraId__c,
                        Product__r.Type__c,
                        Product__r.Model__c,
                        Product__r.TriggerEvent__c,
                        Product__r.Taxable__c
                    FROM Product_Bundle_Assignments__r
                )
                FROM ProductBundle__c
        ],[
            SELECT Id, Message__c, Flag__c, IsError__c, (SELECT Id, Product__r.ZuoraId__c, Quantity__c FROM QWCs__r) 
            FROM QuoteWarning__c
        ]));
    }

    @AuraEnabled
    public static Boolean getAcctMgmtPerm() {
        User u = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return (u.Profile.Name.containsIgnoreCase('AccM') || u.Profile.Name == 'Account Management' || u.Profile.Name == 'Finance' || u.Profile.Name == 'System Administrator' || u.Profile.Name == 'Account Specialist' || u.Profile.Name.containsIgnoreCase('Customer'));
    }
    
    @AuraEnabled
    public static String getContacts(String RecordId, String sObjectName) {
        Id AccountId;
        String ObjectName = sObjectName.replace('__c','');
        try {
            AccountId = (Id)Database.query(
                'SELECT AccountId FROM ' 
                + sObjectName 
                + ' WHERE Id = \'' 
                + RecordId
                + '\' LIMIT 1'
            )[0].get('AccountId');
        } catch(Exception e) {
            AccountId = (Id)Database.query(
                'SELECT Account__c FROM ' 
                + sObjectName 
                + ' WHERE Id = \'' 
                + RecordId
                + '\' LIMIT 1'
            )[0].get('Account__c');
        }
        String PrimaryLanguage = 'German';
        if (AccountId != null) PrimaryLanguage = [SELECT PrimaryLanguage__c FROM Account WHERE Id=:AccountId LIMIT 1].PrimaryLanguage__c;
        return JSON.serialize(new jContactTemplateWrapper([
            SELECT Id, Name, Email, Secondary_Email__c, HasOptedOutOfEmail, IsEmailBounced
            FROM Contact
            WHERE AccountId = :AccountId AND Email != null AND AccountId != null
            ORDER BY LastName, FirstName
        ],[
            SELECT Id, Name, Message__c, Unwrapped_Message__c, Default__c, Subject__c, Unwrapped_Div__c, Folder__c
            FROM SendTemplate__c
            WHERE Object__c = :ObjectName 
            	AND (Default__c = null OR Default__c = :PrimaryLanguage )
            	AND (Language__c = null OR Language__c = :PrimaryLanguage )
            	AND (AdminName__c = null OR AdminName__c = '')
            ORDER BY Name
        ],[
            SELECT Id, Name
            FROM Send_Template_Folder__c
            WHERE Id IN (SELECT Folder__c FROM SendTemplate__c WHERE Object__c = :ObjectName)
            ORDER BY Name
        ],[
            SELECT Id, ToAddress, HtmlBody, Subject
            FROM EmailMessage
            WHERE RelatedToId = :RecordId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ],[
            SELECT Id, ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :RecordId
            ORDER BY ContentDocument.Title
        ],[
            SELECT Id, Name, InvoiceDate__c, BalanceCleared__c
            FROM Invoice__c 
            WHERE Account__c = :AccountId AND MismatchTotal__c = FALSE AND Account__c != null
            ORDER BY Name DESC
        ],[
            SELECT Id, Name, GrandTotal, QuoteNumber, Status, CurrencyIsoCode
            FROM Quote 
            WHERE AccountId = :AccountId AND (Status = 'Draft' OR Status = 'In Review') AND AccountId != null
            ORDER BY Name DESC
        ],[
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE Address = :UserInfo.getUserEmail() OR Address = 'noreply@orderbird.com'
        ],[
            SELECT Id 
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'InvoiceSender'
                AND AssigneeId = :UserInfo.getUserId()
        ].size()>0));
    }
    
    @AuraEnabled
    public static String getQuoteLineItems(String QuoteId) {
        return JSON.serialize([
            SELECT
                Id,
                Product2Id,
                Product2.Name,
                Product2.Taxable__c,
                Product2.ZuoraId__c,
                Product2.Type__c,
                Product2.Model__c,
                Product2.ManualDiscount__c,
                Quantity,
                UnitPrice,
                PricebookEntryId,
                PricebookEntry.UnitPrice,
                ProductBundle__r.Name,
                ProductBundle__c
            FROM QuoteLineItem
            WHERE QuoteId = :QuoteId
        ]);
    }

    @AuraEnabled
    public static String getSubscriptionLineItems(String OpportunityId) {
        Id AccountId = [SELECT AccountId FROM Opportunity WHERE Id = :OpportunityId LIMIT 1].AccountId;
        return JSON.serialize([
            SELECT
                Id,
                Product__c,
                Product__r.Name,
                Product__r.Taxable__c,
                Product__r.ZuoraId__c,
                Product__r.Type__c,
                Product__r.Model__c,
                Quantity__c
            FROM SubscriptionLineItem__c
            WHERE 
                Subscription__r.Account__c = :AccountId
                AND Subscription__r.Status__c = 'ACTIVE'
        ]);
        /*return JSON.serialize([
            SELECT
                Id,
                Product2Id,
                Product2.Name,
                Product2.Taxable__c,
                Product2.ZuoraId__c,
                Product2.Type__c,
                Product2.Model__c,
                Quantity,
                PricebookEntryId,
                PricebookEntry.UnitPrice,
                ProductBundle__r.Name,
                ProductBundle__c
            FROM QuoteLineItem
            WHERE SubscriptionLineItem__r.Subscription__r.Account__c = :AccountId
        ]);*/
    }
    
    @AuraEnabled
    public static String getSendTemplates(String sObjectName) {
        return JSON.serialize([
            SELECT Id, Name, Message__c, Default__c
            FROM SendTemplate__c
            WHERE Object__c = :sObjectName AND CreatedById = :UserInfo.getUserId()
            ORDER BY Name
        ]);
    }
    
    @AuraEnabled
    public static Boolean getBamboraEligibility(String QuoteId) {
        return [SELECT Id FROM QuoteLineItem WHERE QuoteId = :QuoteId AND Quote.CreatedDate > 2019-06-12T00:00:00.000Z AND Product2.Name = 'Card Reader Miura M010'].size() > 0;
    }
    
    
    /****
    /* JSON Objects
    /*
    /****/
    
    public class CatalogWrapper {
        public List<ProductCategory__c> Catalog { get; set; }
        public List<SubscriptionLineItem__c> SLIs { get; set; }
        public CatalogWrapper(
            List<ProductCategory__c> prodList, 
            List<SubscriptionLineItem__c> iSLIs
        ) {
            Catalog = prodList;
            SLIs = iSLIs;
        }
    }

    public class JItemList {
        public List<JItem> Items { get; set; }
        public JDetail Details { get; set; }
        public Decimal TaxAmount { get; set; }
    }

    public class JItem {
        public String Id { get; set; }
        public String ProdId { get; set; }
        public String pricebookentryid { get; set; }
        public Integer Num { get; set; }
        public Decimal unitprice { get; set; }
        public Boolean isBundle { get; set; }
        public Boolean isBundleItem { get; set; }
        public Integer DiscountPeriods { get; set; }
    }
    
    public class JDetail {
        public Date ContractEffectiveDate { get; set; }
        public Date ServiceActivationDate { get; set; }
        public Date ExpirationDate { get; set; }
        public String PaymentMethod { get; set; }
        public String InvoiceOwner { get; set; }
        public Boolean WireFirstPayment { get; set; }
        public Boolean PayPalLink { get; set; }
        public Boolean PayByInstalment { get; set; }
    }

    public class JPricingWrapper {
        public List<PricebookEntry> Pricebook { get; set; }
        public List<ProductBundle__c> Bundles { get; set; }
        public List<QuoteWarning__c> QuoteWarnings { get; set; }
        public JPricingWrapper(List<PricebookEntry> iPricebook, List<ProductBundle__c> iBundles, List<QuoteWarning__c> iQuoteWarnings) {
            Pricebook = iPricebook;
            Bundles = iBundles;
            QuoteWarnings = iQuoteWarnings;
        }
    }

    public class JBundle {
        public JBundleAssn ProductBundleAssignmentsr { get; set; }
    }

    public class JBundleAssn {
        public List<JBundleItem> records { get; set; }
    }

    public class JBundleItem {
        public JBundleProduct Productr { get; set; }
    }

    public class JBundleProduct {
        public String Id { get; set; }
        public String Name { get; set; }
        public String ZuoraIdc { get; set; }
    }

    public class JPriceMapping {
        public Decimal Price { get; set; }
        public String PBE { get; set; }
    }
    
    public class jContactTemplateWrapper {
        public List<Contact> Contacts { get; set; }
        public List<SendTemplate__c> Templates { get; set; }
        public List<Send_Template_Folder__c> TemplateFolders { get; set; }
        public List<EmailMessage> EmailMessage { get; set; }
        public List<ContentDocumentLink> Files { get; set; }
        public List<Invoice__c> Invoices { get; set; }
        public List<Quote> Quotes { get; set; }
        public OrgWideEmailAddress OWEA { get; set; }
        public Boolean InvoicePermission { get; set; }
        public jContactTemplateWrapper(
            List<Contact> iContacts, 
            List<SendTemplate__c> iTemplates,
            List<Send_Template_Folder__c> iTemplateFolders,
            List<EmailMessage> iEmailMessage,
            List<ContentDocumentLink> iFiles,
            List<Invoice__c> iInvoices,
            List<Quote> iQuotes,
            List<OrgWideEmailAddress> OWEAs,
            Boolean iPerm
        ) {
            Contacts = iContacts;
            Templates = iTemplates;
            TemplateFolders = iTemplateFolders;
            EmailMessage = iEmailMessage;
            Files = iFiles;
            Invoices = iInvoices;
            Quotes = iQuotes;
            InvoicePermission = iPerm;
            OWEA = OWEAs[0];
            if (OWEAs.size()==2) {
                if (OWEAs[0].Address == 'noreply@orderbird.com') OWEA = OWEAs[1];
            }
        }
    }

    // static maps

    static Map<String, String> LeasingMap = new Map<String, String>{
        '0' => null,
        '1' => '0015800000ygc9gAAA', //Hofmann Leasing
        '2' => '0015800001DmLIGAA3', //Leascorp
        '3' => null                  //Other
    };
}