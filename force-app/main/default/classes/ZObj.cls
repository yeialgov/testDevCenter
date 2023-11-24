public class ZObj {

    /* REQUEST OBJECTS */

    public class CreateAccountReq {
        public String AccountNumber { get; set; }
        public Boolean AutoPay { get; set; }
        public String Batch { get; set; }
        public String BcdSettingOption { get; set; }
        public Integer BillCycleDay { get; set; }
        public String CrmId { get; set; }
        public String CurrencyX { get; set; }
        public String Name { get; set; }
        public String LegalCompanyNamexxc { get; set; }
        public String PaymentTerm { get; set; }
        public String Status { get; set; }
        public String TaxExemptStatus { get; set; }
        public String TaxExemptCertificateID { get; set; }
        public String Tax_Exempt_Reasonxxc { get; set; }
        public String VATId { get; set; }
        public CreateAccountReq(Quote Quote) {
            AccountNumber = Quote.Account.CustomerIdText__c;
            AutoPay = false;
            Batch = 'Batch2';
            BcdSettingOption = 'AutoSet';
            BillCycleDay = 0;
            CrmId = Quote.AccountId;
            CurrencyX = Quote.Account.CurrencyIsoCode;
            Name = Quote.Account.Name;
            PaymentTerm = 'Due Upon Receipt';
            Status = 'Draft';
            LegalCompanyNamexxc = Quote.Account.LegalCompanyName__c;
            TaxExemptStatus = 'No';
            if (Quote.Account.Tax_Exempt_Reason__c != 'Non Tax Exempt' && Quote.Account.Tax_Exempt_Reason__c != null) {
                TaxExemptStatus = 'Yes';
                if (Quote.Account.Tax_Exempt_Reason__c.containsIgnoreCase('third')) {
                    TaxExemptCertificateID = 'Not Applicable';
                } else {
                    VATId = Quote.Account.VATNumber__c;
                }
            }
            Tax_Exempt_Reasonxxc = Quote.Account.Tax_Exempt_Reason__c;
            
            if (Quote.InvoiceOwner__c == null && (Quote.WireFirstPayment__c || Quote.PayPalLink__c || Quote.PaymentMethod__c == 'Wire Transfer')) {
                Batch = 'Batch7';
            }
            if (Quote.Pay_by_Instalment__c) {
                Batch = 'Batch4';
                PaymentTerm = 'Installment Payment 3 Rates ';
            }
        }
    }

    public class CreateContactReq {
        public String AccountId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Country { get; set; }
        public CreateContactReq(Quote Quote, String AccountZId) {
            AccountId = AccountZId;
            FirstName = 'Auto';
            LastName = 'Contact';
            Country = Quote.Account.BillingCountry;
        }
    }

    public class ActivateAccountReq {
        public String BillToId { get; set; }
        public String SoldToId { get; set; }
        public String Status { get; set; }
        public ActivateAccountReq(String ContactZId) {
            BillToId = ContactZId;
            SoldToId = ContactZId;
            Status = 'Active';
        }
    }

    public class AmendActionReq {
        public List<AmendRequest> requests { get; set; }
        public AmendActionReq(AmendmentSet Data, Boolean IsPreview, Date InvTargetDate) {
            requests = new List<AmendRequest>{ new AmendRequest(Data, IsPreview, InvTargetDate) };
        }
        public AmendActionReq(AmendmentSet Data, Date StartDate, List<String> ProdSysRef, Date InvTargetDate, String BilCycTyp, String BilPerAli) {
            requests = new List<AmendRequest>{ new AmendRequest(Data, StartDate, ProdSysRef, InvTargetDate, BilCycTyp, BilPerAli) };
        }
    }

    public class AmendRequest {
        public AmendOptions AmendOptions { get; set; }
        public List<Amendment> Amendments { get; set; }
        public PreviewOptions PreviewOptions { get; set; }
        public AmendRequest(AmendmentSet Data, Boolean IsPreview, Date InvTargetDate) {
            AmendOptions = new AmendOptions(IsPreview, InvTargetDate);
            PreviewOptions = new PreviewOptions(IsPreview);
            Amendments = new List<Amendment>();
            if (Data.RemProdQLIs != null) {
                for (AmendmentPair RemProdQLI : Data.RemProdQLIs) {
                    Amendments.add(new Amendment(RemProdQLI, Data.UpdRedcMap, 'Remove'));
                }
            }
            if (Data.UpdProdQLIs != null) {
                for (AmendmentPair UpdProdQLI : Data.UpdProdQLIs) {
                    Amendments.add(new Amendment(UpdProdQLI, Data.UpdRedcMap, 'Update'));
                }
            }
            if (Data.NewProdQLIs != null) {
                for (QuoteLineItem NewProdQLI : Data.NewProdQLIs) {
                    Amendments.add(new Amendment(NewProdQLI, Data.SubscriptionZId));
                }
            }
            if (Data.RepProdQLIs != null) {
                for (QuoteLineItem RepProdQLI : Data.RepProdQLIs) {
                    Amendments.add(new Amendment(RepProdQLI, Data.SubscriptionZId, Data.UpdRedcMap));
                }
            }
        }
        public AmendRequest(AmendmentSet Data, Date StartDate, List<String> ProdSysRef, Date InvTargetDate, String BilCycTyp, String BilPerAli) {
            AmendOptions = new AmendOptions();
            PreviewOptions = new PreviewOptions(false);
            Amendments = new List<Amendment>();
            for (String PRS : ProdSysRef) { Amendments.add(new Amendment( StartDate, PRS, Data.SubscriptionZId, BilCycTyp, BilPerAli )); }
        }
    }

    public class AmendOptions {
        public Boolean GenerateInvoice { get; set; }
        public InvoiceProcessingOptions InvoiceProcessingOptions { get; set; }
        public AmendOptions(Boolean IsPreview, Date InvTargetDate) {
            GenerateInvoice = IsPreview;
            if (IsPreview) InvoiceProcessingOptions = new InvoiceProcessingOptions(InvTargetDate);
        }
        public AmendOptions() {
            GenerateInvoice = false;
        }
    }

    public class InvoiceProcessingOptions {
        public Date InvoiceTargetDate { get; set; }
        public InvoiceProcessingOptions(Date InvTargetDate) {
            InvoiceTargetDate = InvTargetDate;
        }
    }

    public class PreviewOptions {
        public Boolean EnablePreviewMode { get; set; }
        public PreviewOptions(Boolean IsPreview) {
            EnablePreviewMode = IsPreview;
        }
    }
    
    public class SubUpdReq {
        public List<SubUpdAdd> add { get; set; }
        public SubUpdReq(String ProdSysRef, Date iServiceActivationDate) {
            add = new List<SubUpdAdd>{new SubUpdAdd(ProdSysRef, iServiceActivationDate)};
        }
    }
    
    public class SubUpdAdd{
        public List<ChargeOverride> chargeOverrides { get; set; }
        public Date contractEffectiveDate { get; set; }
        public Date customerAcceptanceDate { get; set; }
        public String productRatePlanId { get; set; }
        public Date serviceActivationDate { get; set; }
        public SubUpdAdd(String ProdSysRef, Date iServiceActivationDate){
            try { 
                Product2 product = [SELECT Id, ZuoraId__c, ZuoraSubCategoryId__c FROM Product2 WHERE UniqueSysRef__c = :ProdSysRef LIMIT 1]; 
                chargeOverrides = new List<ChargeOverride>{new ChargeOverride(product.ZuoraId__c)};
                    contractEffectiveDate = Date.today();
                customerAcceptanceDate = iServiceActivationDate;
                productRatePlanId = product.ZuoraSubCategoryId__c;
                serviceActivationDate = iServiceActivationDate;
            } catch(exception e) {}
        }
    }

    public class Amendment {
        public Date ContractEffectiveDate { get; set; }
        public Date CustomerAcceptanceDate { get; set; }
        public Date ServiceActivationDate { get; set; }
        public String Name { get; set; } //a string of 100 characters or fewer
        public RatePlanData RatePlanData { get; set; }
        public String Status { get; set; } // Completed
        public String SubscriptionId { get; set; }
        public String Type { get; set; } // NewProduct RemoveProduct UpdateProduct
        public Amendment(Date StartDate, String ProdSysRef, String SubscriptionZId, String BilCycTyp, String BilPerAli) {
            Type = 'NewProduct';
            Status = 'Completed';
            ContractEffectiveDate = StartDate;
            CustomerAcceptanceDate = Date.today();
            ServiceActivationDate = StartDate;
            Name = 'New ' + ProdSysRef;
            SubscriptionId = SubscriptionZId;
            try {
                Product2 Product = [SELECT Id, ZuoraId__c, ZuoraSubCategoryId__c FROM Product2 WHERE UniqueSysRef__c = :ProdSysRef LIMIT 1];
                RatePlanData = new RatePlanData(
                    Product.ZuoraSubCategoryId__c, 
                    null,
                    new List<RatePlanChargeData>{new RatePlanChargeData(
                        new RatePlanCharge(
                            Product.ZuoraId__c,
                            1,
                            BilCycTyp,
                            BilPerAli
                        )
                    )}
                );
            } catch(exception e) {}
        }
        public Amendment(
            AmendmentPair ProdQLI,
            Map<String, Decimal> RedcMap,
            String AmendType
        ) {
            Type = AmendType + 'Product';
            Status = 'Completed';
            ContractEffectiveDate = ProdQLI.QLI.Quote.ContractEffectiveDate__c;
            CustomerAcceptanceDate = ProdQLI.QLI.Quote.ContractEffectiveDate__c;
            if (ProdQLI.QLI.Product2.Type__c == 'OneTime') ContractEffectiveDate = ProdQLI.SLI.EffectiveStartDate__c;
            ServiceActivationDate = ProdQLI.QLI.Quote.POS_Start_Date__c;
            Name = AmendType + ' ' + ProdQLI.QLI.Id;
            SubscriptionId = ProdQLI.SLI.Subscription__r.ZuoraId__c;
            RatePlanData = new RatePlanData(
                ProdQLI.SLI.Product__r.ZuoraSubCategoryId__c, 
                ProdQLI.SLI.ZuoraSubCategoryId__c, 
                new List<RatePlanChargeData>{new RatePlanChargeData(
                    new RatePlanCharge(
                        ProdQLI.QLI.Product2.ZuoraId__c,
                        RedcMap.get(ProdQLI.SLI.ZuoraId__c),
                        ProdQLI.QLI.Id,
                        ProdQLI.QLI.UnitPrice
                    )
                )}
            );
        }
        public Amendment(QuoteLineItem NewProdQLI, String SubscriptionZId) {
            Type = 'NewProduct';
            Status = 'Completed';
            ContractEffectiveDate = NewProdQLI.Quote.ContractEffectiveDate__c;
            CustomerAcceptanceDate = NewProdQLI.Quote.ContractEffectiveDate__c;
            ServiceActivationDate = NewProdQLI.Quote.POS_Start_Date__c;
            Name = 'New ' + NewProdQLI.Id;
            SubscriptionId = SubscriptionZId;
            RatePlanData = new RatePlanData(
                NewProdQLI.Product2.ZuoraSubCategoryId__c, 
                null,
                new List<RatePlanChargeData>{new RatePlanChargeData(
                    new RatePlanCharge(
                        NewProdQLI.Product2.ZuoraId__c,
                        NewProdQLI.Quantity,
                        NewProdQLI.Id,
                        NewProdQLI.UnitPrice,
                        NewProdQLI.BillingPeriodDurationOverride__c,
                        NewProdQLI.Product2.ManualDiscount__c,
                        NewProdQLI.Product2.Model__c
                    )
                )}
            );
        }
        public Amendment(
            QuoteLineItem NewProdQLI, 
            String SubscriptionZId, 
            Map<String, Decimal> RedcMap
        ) {
            Type = 'NewProduct';
            Status = 'Completed';
            ContractEffectiveDate = NewProdQLI.Quote.ContractEffectiveDate__c;
            CustomerAcceptanceDate = NewProdQLI.Quote.ContractEffectiveDate__c;
            ServiceActivationDate = NewProdQLI.Quote.POS_Start_Date__c;
            Name = 'New ' + NewProdQLI.Id;
            SubscriptionId = SubscriptionZId;
            RatePlanData = new RatePlanData(
                NewProdQLI.Product2.ZuoraSubCategoryId__c, 
                null,
                new List<RatePlanChargeData>{new RatePlanChargeData(
                    new RatePlanCharge(
                        NewProdQLI.Product2.ZuoraId__c,
                        RedcMap.get(NewProdQLI.Id),
                        NewProdQLI.Id,
                        NewProdQLI.UnitPrice
                    )
                )}
            );
        }
    }

    public class RatePlanData {
        public RatePlan RatePlan { get; set; }
        public List<RatePlanChargeData> RatePlanChargeData { get; set; }
        public RatePlanData(String ProdRatePlanId, String RatePlanId, List<RatePlanChargeData> iRPCD) {
            RatePlan = new RatePlan(ProdRatePlanId, RatePlanId);
            RatePlanChargeData = iRPCD;
        }
    }

    public class RatePlan {
        public String ProductRatePlanId { get; set; }
        public String AmendmentSubscriptionRatePlanId { get; set; }
        public RatePlan(String iProductRatePlanId, String ASRPId) {
            ProductRatePlanId = iProductRatePlanId;
            AmendmentSubscriptionRatePlanId = ASRPId;
        }
    }

    public class RatePlanChargeData {
        public RatePlanCharge RatePlanCharge { get; set; }
        public RatePlanChargeData(RatePlanCharge RPC) {
            RatePlanCharge = RPC;
        }
    }

    public class RatePlanCharge {
        public String ProductRatePlanChargeId { get; set; }
        public Decimal Quantity { get; set; }
        public String test1xxc { get; set; }
        public Decimal DiscountAmount { get; set; }
        public Decimal Price { get; set; }
        public String DiscountLevel { get; set; }
        public String EndDateCondition { get; set; }
        public Integer UpToPeriods { get; set; }
        public String BillCycleType { get; set; }
        public String BillingPeriodAlignment { get; set; }
        public RatePlanCharge(String PRPCId, Decimal Qty, String BilCycTyp, String BilPerAli) {
            ProductRatePlanChargeId = PRPCId;
            Quantity = Qty;
            BillCycleType = BilCycTyp;
            BillingPeriodAlignment = BilPerAli;
        }
        public RatePlanCharge(String PRPCId, Decimal Qty, String SFId, Decimal UnitPrice) {
            ProductRatePlanChargeId = PRPCId;
            Quantity = Qty;
            test1xxc = SFId;
            try { Price = math.abs(UnitPrice); } catch(exception e){}
        }
        public RatePlanCharge(
            String PRPCId, 
            Decimal Qty, 
            String SFId,
            Decimal DiscAmt,
            Decimal BillPerOverride,
            Boolean IsManualDiscount,
            String ProductModel
        ) {
            ProductRatePlanChargeId = PRPCId;
            Quantity = Qty;
            test1xxc = SFId;
            if (/*IsManualDiscount && */ProductModel == 'DiscountFixedAmount') {
                try { DiscountAmount = Math.abs(DiscAmt); } catch(exception e){}
                EndDateCondition = 'FixedPeriod';
                UpToPeriods = Integer.valueOf(BillPerOverride);
                if (UpToPeriods == null) UpToPeriods = 1;
            }
            if (/*IsManualDiscount && */ProductModel != 'DiscountFixedAmount') {
                try { Price = math.abs(DiscAmt); } catch(exception e){}
            }
            //if (!IsManualDiscount) { try { Price = Math.abs(DiscAmt); } catch(exception e){} }
        }
    }

    public class CreateSubscriptionReq {
        public String accountKey { get; set; }
        public Date contractEffectiveDate { get; set; }
        public String invoiceOwnerAccountKey { get; set; }
        public Boolean invoiceSeparately { get; set; }
        public Integer renewalTerm { get; set; }
        public Boolean runBilling { get; set; }
        public Date serviceActivationDate { get; set; }
        public Date targetDate { get; set; }
        public String termType { get; set; }
        public List<SubReqRatePlan> subscribeToRatePlans { get; set; }
        public CreateSubscriptionReq(Quote Quote, List<QuoteLineItem> QLIs, String AccountZId) {
            accountKey = AccountZId;
            contractEffectiveDate = Quote.ContractEffectiveDate__c;
            renewalTerm = 0;
            serviceActivationDate = Quote.POS_Start_Date__c;
            targetDate = Quote.SpecialRestart__c > 0 ? Quote.ContractEffectiveDate__c : Quote.POS_Start_Date__c;
            termType = 'EVERGREEN';
            invoiceSeparately = false;
            runBilling = false;
            if(Quote.InvoiceOwner__c != null) {
                invoiceOwnerAccountKey = Quote.InvoiceOwner__r.ZuoraId__c;
                invoiceSeparately = true;
            }
            subscribeToRatePlans = new List<SubReqRatePlan>();
            for (QuoteLineItem QLI : QLIs) {
                subscribeToRatePlans.add(new SubReqRatePlan(QLI, (
                    Quote.Account.Batch__c == 'Batch7' || Quote.WireFirstPayment__c || Quote.PayPalLink__c || Quote.PaymentMethod__c == 'Wire Transfer'
                )));
            }
        }
    }

    public class SubReqRatePlan {

        public String productRatePlanId { get; set; }
        public List<ChargeOverride> chargeOverrides { get; set; }
        public SubReqRatePlan(QuoteLineItem QLI, Boolean TriggerUCE) {
            productRatePlanId = QLI.Product2.ZuoraSubCategoryId__c;
            chargeOverrides = new List<ChargeOverride>{ new ChargeOverride(QLI, TriggerUCE) };
        }
    }

    public class ChargeOverride {

        public String productRatePlanChargeId { get; set; }
        public Decimal quantity { get; set; }
        public String test1xxc { get; set; }
        public Decimal discountAmount { get; set; }
        //public String discountLevel { get; set; }
        public String endDateCondition { get; set; }
        //public String triggerEvent { get; set; }
        public Integer upToPeriods { get; set; }
        public ChargeOverride(String RatePlanChargeZId) {
            productRatePlanChargeId = RatePlanChargeZId;
        }
        public ChargeOverride(QuoteLineItem QLI, Boolean TriggerUCE) {
            productRatePlanChargeId = QLI.Product2.ZuoraId__c;
            if (QLI.Product2.Model__c == 'PerUnit') quantity = QLI.Quantity;
            if (QLI.Product2.ManualDiscount__c) {
                try { discountAmount = Math.abs(QLI.UnitPrice); } catch(exception e) {}
                //discountLevel = 'account';
                endDateCondition = 'Fixed_Period';
                upToPeriods = Integer.valueOf(QLI.BillingPeriodDurationOverride__c);
                if (upToPeriods == null) upToPeriods = 1;
            }
            //if (TriggerUCE) triggerEvent = 'UCE';
            test1xxc = QLI.Id;
        }
    }

    public class GenerateInvoiceReq {
        public String type { get; set; }
        public List<GenerateObject> objects { get; set; }
        public GenerateInvoiceReq(String AccountZId, Date InvoiceDate, Date InvTargetDate) {
            type = 'Invoice';
            objects = new List<GenerateObject>{new GenerateObject(
                AccountZId, InvoiceDate, InvTargetDate
            )};
        }
    }

    public class GenerateObject {
        public String AccountId { get; set; }
        public Date InvoiceDate { get; set; }
        public Date TargetDate { get; set; }
        public GenerateObject(String AccountZId, Date InvDate, Date InvTargetDate) {
            AccountId = AccountZId;
            InvoiceDate = InvDate;
            TargetDate = InvTargetDate;
        }
    }

    public class CancelSubReq {
        public String cancellationPolicy { get; set; }
        public Date cancellationEffectiveDate { get; set; }
        public CancelSubReq(String SubscriptionZId, Date EffectiveDate) {
            if (EffectiveDate == null) {
                cancellationPolicy = 'EndOfLastInvoicePeriod';
            } else {
                cancellationPolicy = 'SpecificDate';
                cancellationEffectiveDate = EffectiveDate;
            }
        }
    }

    public class RevokeSubReq {
        public Date cancellationEffectiveDate { get; set; }
        public String cancellationPolicy { get; set; }
        public Date documentDate { get; set; }
        public Boolean runBilling { get; set; }
        public Date targetDate { get; set; }
        public RevokeSubReq(Date CancelDate, Date InvTargetDate) {
            cancellationEffectiveDate = CancelDate;
            cancellationPolicy = 'SpecificDate';
            documentDate = Date.today();
            //runBilling = false;
            runBilling = true;
            targetDate = InvTargetDate;
        }
    }

    public class CreatePreviewReq {
        public Date contractEffectiveDate { get; set; }
        public Date targetDate { get; set; }
        public PreviewAccountInfo previewAccountInfo { get; set; }
        public Date serviceActivationDate { get; set; }
        public List<SubReqRatePlan> subscribeToRatePlans { get; set; }
        public String termType { get; set; }
        public CreatePreviewReq(String QuoteId) {
            Quote Quote = [
                SELECT Id, ContractEffectiveDate__c, POS_Start_Date__c, Account.Tax_Exempt_Reason__c,
                    Account.BillingCountry, Account.CurrencyIsoCode
                FROM Quote 
                WHERE Id = :QuoteId 
                LIMIT 1
            ];
            List<QuoteLineItem> QLIs = [
                SELECT Id, Product2.ZuoraSubCategoryId__c, Product2.ZuoraId__c, Product2.ManualDiscount__c,
                    Product2.Model__c, Quantity, UnitPrice, BillingPeriodDurationOverride__c
                FROM QuoteLineItem
                WHERE QuoteId = :QuoteId
            ];
            contractEffectiveDate = Quote.ContractEffectiveDate__c;
            targetDate = Quote.POS_Start_Date__c;
            serviceActivationDate = Quote.POS_Start_Date__c;
            termType = 'EVERGREEN';
            previewAccountInfo = new PreviewAccountInfo(Quote);
            subscribeToRatePlans = new List<SubReqRatePlan>();
            for (QuoteLineItem QLI : QLIs) {
                subscribeToRatePlans.add(new SubReqRatePlan(QLI, false));
            }
        }
    }

    public class PreviewAccountInfo {
        public Integer billCycleDay { get; set; }
        public PreviewContact billToContact { get; set; }
        public String currencyX { get; set; }
        public PreviewAccountInfo(Quote Quote) {
            String BillingCountry = Quote.Account.BillingCountry;
            if (Quote.Account.Tax_Exempt_Reason__c != null && Quote.Account.Tax_Exempt_Reason__c != 'Non Tax Exempt') BillingCountry = 'Zambia';
            billCycleDay = 0;
            billToContact = new PreviewContact(BillingCountry);
            currencyX = Quote.Account.CurrencyIsoCode;
        }
    }

    public class PreviewContact {
        public String country { get; set; }
        public PreviewContact(String MailingCountry) {
            country = MailingCountry;
        }
    }
    
    public class BatchChangePackage {
        public String type { get; set; }
        public List<BatchChange> objects { get; set; }
        public BatchChangePackage(List<BatchChange> BatchChanges) {
            type = 'Account';
            objects = BatchChanges;
        }
    }
    
    public class BatchChange {
        public String Id { get; set; }
        public String Batch { get; set; }
        public String PaymentTerm { get; set; }
        public BatchChange(String AccountZId, String BillingBatch) {
            Id = AccountZId;
            Batch = BillingBatch;
            PaymentTerm = 'Due Upon Receipt';
        }
    }
    
    public class InvoiceVATUpdatePackage {
        public String type { get; set; }
        public List<InvoiceVATUpdate> objects { get; set; }
        public InvoiceVATUpdatePackage(List<InvoiceVATUpdate> InvoiceVATUpdates) {
            type = 'Invoice';
            objects = InvoiceVATUpdates;
        }
    }
    
    public class InvoiceVATUpdate {
        public String Id { get; set; }
        public String VATIdxxc { get; set; }
        public String VAT_refxxc { get; set; }
        public String TaxExemptReasonxxc { get; set; }
        public InvoiceVATUpdate(Invoice__c Invoice) {
            Id = Invoice.ZuoraId__c;
            VATIdxxc = Invoice.VatId__c;
            VAT_refxxc = Invoice.VAT_ref__c;
            TaxExemptReasonxxc = Invoice.TaxExemptReason__c;
        }
    }
    
    public class CreateBillRuns {
        public String type { get; set; }
        public List<CreateBillRun> objects { get; set; }
        public CreateBillRuns(List<CreateBillRun> BillRuns) {
            type = 'Invoice';
            objects = BillRuns;
        }
    }
    
    public class CreateBillRun {
        public String AccountId { get; set; }
        public Date InvoiceDate { get; set; }
        public Date TargetDate { get; set; }
        public CreateBillRun(String AccountZId, Date InvTargetDate) {
            AccountId = AccountZId;
            InvoiceDate = Date.today();
            TargetDate = InvTargetDate;
        }
    }

    public class CreateCBAs {
    	public String type { get; set; }
    	public List<CreateCBA> objects { get; set; }
    	public CreateCBAs(List<CreateCBA> CBAs) {
    		type = 'CreditBalanceAdjustment';
    		objects = CBAs;
    	}
    }

    public class CreateCBA {
    	public Decimal Amount { get; set; }
    	public String SourceTransactionId { get; set; }
    	public String Type { get; set; }
        public CreateCBA(Decimal Amt, String InvZId, String CBAType) {
            Amount = Amt;
            SourceTransactionId = InvZId;
            Type = CBAType;
        }
    }
    
    public class InvoicePosts {
    	public String type { get; set; }
    	public List<InvoicePost> objects { get; set; }
    	public InvoicePosts(List<InvoicePost> Updates) {
    		type = 'Invoice';
    		objects = Updates;
    	}
    }
    
    public class InvoicePost {
        public String Id { get; set; }
        public String Status { get; set; }
        public InvoicePost(String InvoiceZId) {
            Id = InvoiceZId;
            Status = 'Posted';
        }
    }
    
    public class CreatePayments {
    	public String type { get; set; }
    	public List<CreatePayment> objects { get; set; }
    	public CreatePayments(List<CreatePayment> CreatePayments) {
    		type = 'Payment';
    		objects = CreatePayments;
    	}
    }
    
    public class CreatePayment {
        public String AccountId { get; set; }
        public Decimal Amount { get; set; }
        public Decimal AppliedInvoiceAmount { get; set; }
        public Date EffectiveDate { get; set; }
        public String InvoiceId { get; set; }
        public String PaymentMethodId { get; set; }
        public String Status { get; set; }
        public String Type { get; set; }
        public CreatePayment(String AccountZId, String InvoiceZId, String PmtMtdZId, Decimal InvAmount) {
            AccountId = AccountZId;
            Amount = InvAmount;
            AppliedInvoiceAmount = InvAmount;
            EffectiveDate = Date.today();
            InvoiceId = InvoiceZId;
            PaymentMethodId = PmtMtdZId;
            Status = 'Processed';
            Type = 'Electronic';
        }
    }
    
    public class SubTSETermedProrateReq {
        public String accountKey { get; set; }
        public Boolean autoRenew { get; set; }
        public Boolean collectX { get; set; }
        public Date contractEffectiveDate { get; set; }
        public Date customerAcceptanceDate { get; set; }
        public Date documentDate { get; set; }
        public Integer initialTerm { get; set; }
        public String initialTermPeriodType { get; set; }
        public Boolean invoiceSeparately { get; set; }
        public Date targetDate { get; set; }
        public Integer renewalTerm { get; set; }
        public String renewalTermPeriodType { get; set; }
        public Boolean runBilling { get; set; }
        public Date serviceActivationDate { get; set; }
        public List<TSERatePlan> subscribeToRatePlans { get; set; }
        public Date termStartDate { get; set; }
        public String termType { get; set; }
        public void common(Date StartDate, String AccountZId, Date RenewalDate) {
            accountKey = AccountZId;
            autoRenew = false;
            collectX = false;
            contractEffectiveDate = StartDate;
            customerAcceptanceDate = StartDate;
            documentDate = StartDate;
            initialTerm = StartDate.daysBetween(RenewalDate);
            initialTermPeriodType = 'Day';
            invoiceSeparately = true;
            targetDate = RenewalDate;
            renewalTerm = 12;
            renewalTermPeriodType = 'Month';
            runBilling = true;
            serviceActivationDate = StartDate;
            termStartDate = StartDate;
            termType = 'TERMED';
        }
        public SubTSETermedProrateReq(Date StartDate, String AccountZId, Date RenewalDate, String ProductZId, String RatePlanZId) {
            subscribeToRatePlans = new List<TSERatePlan>{ new TSERatePlan(ProductZId, RatePlanZId) };
            common(StartDate, AccountZId, RenewalDate);
        }
        public SubTSETermedProrateReq(Date StartDate, String AccountZId, Date RenewalDate) {
            subscribeToRatePlans = new List<TSERatePlan>{ new TSERatePlan('TSE'), new TSERatePlan('TSE_fee') };
            common(StartDate, AccountZId, RenewalDate);
        }
    }
    
    public class TSERatePlan {
        public String productRatePlanId { get; set; }
        public List<ChargeOverride> chargeOverrides { get; set; }
        public TSERatePlan(String ProductZId, String RatePlanZId) {
            productRatePlanId = RatePlanZId;
            chargeOverrides = new List<ChargeOverride>{ new ChargeOverride(ProductZId) };
        }
        public TSERatePlan(String USR) {
            Product2 product;
            if (Test.isRunningTest()) { product = [SELECT Id, ZuoraId__c, ZuoraSubCategoryId__c FROM Product2 LIMIT 1]; } else {
                product = [
                    SELECT Id, ZuoraId__c, ZuoraSubCategoryId__c 
                    FROM Product2 
                    WHERE UniqueSysRef__c = :USR
                    LIMIT 1
                ];
            }
            productRatePlanId = product.ZuoraSubCategoryId__c;
            chargeOverrides = new List<ChargeOverride>{ new ChargeOverride(product.ZuoraId__c) };
        }
    }
    
    public class SubTSETermedCancelReq {
        public String cancellationPolicy { get; set; }
        public Boolean collectX { get; set; }
        public Date documentDate { get; set; }
        public Boolean runBilling { get; set; }
        public Date targetDate { get; set; }
        public SubTSETermedCancelReq(Date CancelDate, Boolean doBill) {
            cancellationPolicy = 'EndOfCurrentTerm';
            collectX = doBill ? false : null;
            documentDate = Date.today();
            runBilling = doBill;
            targetDate = CancelDate;
        }
    }
    
    /* RESPONSE OBJECTS */

    public class SuccessId {
        public Boolean Success { get; set; }
        public String Id { get; set; }
    }

    public class SubSuccessId {
        public Boolean success { get; set; }
        public String subscriptionId { get; set; }
        public String invoiceId { get; set; }
        public List<ZReason> reasons { get; set; }
    }

    public class ZReason {
        public String message { get; set; }
    }

    public class AmendResults {

        public List<AmendResult> results { get; set; }
    }

    public class AmendResult {
        public String SubscriptionId { get; set; }
        public Boolean Success { get; set; }
        public List<ZError> Errors { get; set; }
    }

    public class ZError {
        public String Message { get; set; }
    }

    public class UpdatedSubscription {
        public Boolean success { get; set; }
        public String subscriptionId { get; set; }
    }

    public class PreviewSubRes {
        public Boolean success { get; set; }
        public PreviewInvoice invoice { get; set; }
    }

    public class PreviewInvoice {
        public Decimal amount { get; set; }
        public Decimal amountWithoutTax { get; set; }
        public Decimal taxAmount { get; set; }
        public List<PreviewInvItem> invoiceItems { get; set; }
    }

    public class PreviewInvItem { 
        public Decimal chargeAmount { get; set; }
        public String productRatePlanChargeId { get; set; }
    }

    /* CATALOG */
    
    public class FetchCatalog { 

        public List<FetchCatalogProducts> products { get; set; } 
    }

    public class FetchCatalogProducts {
        public String name { get; set; }
        public String id { get; set; }
        public String sku { get; set; }
        public String category { get; set; }
        public String CheckoutClusterxxc { get; set; }
        public String ProductGenerationxxc { get; set; }
        public String ProductTypexxc { get; set; }
        public List<FetchCatalogProductRatePlans> productRatePlans { get; set; }
    }

    public class FetchCatalogProductRatePlans {
        public String name { get; set; }
        public String id { get; set; }
        public String status { get; set; }
        public Date effectiveStartDate { get; set; }
        public Date effectiveEndDate { get; set; }
        public String QuoteBuilderVisibilityxxc { get; set; }
        public String QuoteBuilderItemNamexxc { get; set; }
        public String Localizedavailabilityxxc { get; set; }
        public List<FetchCatalogProductRatePlanCharges> productRatePlanCharges { get; set; }
    }

    public class FetchCatalogProductRatePlanCharges {
        public String id { get; set; }
        public String name { get; set; }
        public String Charge_Name_DExxc { get; set; }
        public String Charge_Name_FRxxc { get; set; }
        public String LicensedDevicesxxc { get; set; }
        public String PurchasePricexxc { get; set; }
        public String External_Product_IDxxc { get; set; }
        public String MRR_RPCxxc { get; set; }
        public String triggerEvent { get; set; }
        public String type { get; set; }
        public String model { get; set; }
        public String billingPeriod { get; set; }
        public Integer specificBillingPeriod { get; set; }
        public Boolean taxable { get; set; }
        public String QuoteBuilderOverrideBillingPeriodandPricexxc { get; set; }
        public List<FetchCatalogPricing> pricing { get; set; }
        public FetchFinanceInfo financeInformation { get; set; }
    }
    
    public class FetchFinanceInfo {
        public String recognizedRevenueAccountingCode { get; set; }
    }

    public class FetchCatalogPricing {
        public String currencyX { get; set; }
        public Decimal price { get; set; }
        public Decimal discountAmount { get; set; }
    }

    /* SUBSCRIPTION */

    public class FetchSubscriptionPackages {
        public Boolean Success { get; set; }
        public List<FetchSubscriptionPackage> Subscriptions { get; set; }
        public FetchSubscriptionPackages(List<FetchSubscriptionPackage> Subs) {
            Subscriptions = Subs;
        }
    }

    public class FetchSubscriptionPackage {
        public String id { get; set; }
        public String accountId { get; set; }
        public Date contractEffectiveDate { get; set; }
        public Date customerAcceptanceDate { get; set; }
        public String invoiceOwnerAccountId { get; set; }
        public Boolean invoiceSeparately { get; set; }
        public String status { get; set; }
        public String subscriptionId { get; set; }
        public String subscriptionNumber { get; set; }
        public Boolean success { get; set; }
        public String termType { get; set; }
        public Date serviceActivationDate { get; set; }
        public Date subscriptionStartDate { get; set; }
        public Date termStartDate { get; set; }
        public Date termEndDate { get; set; }
        public List<FetchSubscriptionRatePlans> ratePlans { get; set; }
    }

    public class FetchSubscriptionRatePlans {
        public String id { get; set; }
        public String lastChangeType { get; set; }
        public List<FetchSubscriptionRatePlanCharges> ratePlanCharges { get; set; }
    }

    public class FetchSubscriptionRatePlanCharges {
        public String id { get; set; }
        public String description { get; set; }
        public Double dmrc { get; set; }
        public Double dtcv { get; set; }
        public Date effectiveEndDate { get; set; }
        public Date effectiveStartDate { get; set; }
        public Double mrr { get; set; }
        public String numberX { get; set; }
        public String originalChargeId { get; set; }
        public Double price { get; set; }
        public String productRatePlanChargeId { get; set; }
        public Double quantity { get; set; }
        public String test1xxc { get; set; }
        public Double tcv { get; set; }
        public Integer version { get; set; }
    }
    
    public class TSENewProdAmendReq {
        
        public TSENewProdAmendReq(String SubscriptionZId, Date RenewalDate) {
            
        }
    }

    /* AMENDMENT WRAPPERS */

    public class AmendmentPair {
        public QuoteLineItem QLI { get; set; }
        public SubscriptionLineItem__c SLI { get; set; }
        public AmendmentPair(QuoteLineItem iQLI, SubscriptionLineItem__c iSLI) {
            QLI = iQLI;
            SLI = iSLI;
        }
    }

    public class AmendmentSet {
        public List<QuoteLineItem> NewProdQLIs { get; set; }
        public List<AmendmentPair> UpdProdQLIs { get; set; }
        public List<AmendmentPair> RemProdQLIs { get; set; }
        public List<QuoteLineItem> RepProdQLIs { get; set; }
        public Map<String, Decimal> UpdRedcMap { get; set; }
        public String SubscriptionZId { get; set; }
        public AmendmentSet(
            List<QuoteLineItem> iNewProdQLIs,
            List<AmendmentPair> iUpdProdQLIs,
            List<AmendmentPair> iRemProdQLIs,
            List<QuoteLineItem> iRepProdQLIs,
            Map<String, Decimal> iUpdRedcMap,
            String iSubscriptionZId
        ) {
            NewProdQLIs = iNewProdQLIs;
            UpdProdQLIs = iUpdProdQLIs;
            RemProdQLIs = iRemProdQLIs;
            RepProdQLIs = iRepProdQLIs;
            UpdRedcMap  = iUpdRedcMap;
            SubscriptionZId = iSubscriptionZId;
        }
        public AmendmentSet(String iSubscriptionZId) {
            SubscriptionZId = iSubscriptionZId;
        }
    }

    public class AmendItem {
        public String SubscriptionId { get; set; }
        public String Product { get; set; }
        public String ProductSubCategory { get; set; }
        public Decimal Quantity { get; set; }
        public Boolean IsAddition { get; set; }
        public String QuoteLineItemSFID { get; set; }
        public AmendItem(String iSubscriptionId, QuoteLineItem QLI) { // Add
            SubscriptionId = iSubscriptionId;
            Product = QLI.Product2.ZuoraId__c;
            ProductSubCategory = QLI.Product2.ZuoraSubCategoryId__c;
            Quantity = QLI.Quantity;
            IsAddition = true;
            QuoteLineItemSFID = QLI.Id;
        }
        public AmendItem(SubscriptionLineItem__c SLI, QuoteLineItem QLI) { // Update
            SubscriptionId = SLI.Subscription__r.ZuoraId__c;
            Product = SLI.ZuoraId__c;
            ProductSubCategory = SLI.ZuoraSubCategoryId__c;
            Quantity = QLI.Quantity;
            IsAddition = false;
            QuoteLineItemSFID = QLI.Id;
        }
        public AmendItem(SubscriptionLineItem__c SLI, QuoteLineItem QLI, Decimal Qty) { // Update
            SubscriptionId = SLI.Subscription__r.ZuoraId__c;
            Product = SLI.ZuoraId__c;
            ProductSubCategory = SLI.ZuoraSubCategoryId__c;
            Quantity = Qty;
            IsAddition = false;
            QuoteLineItemSFID = QLI.Id;
        }
    }

    public class SendQuoteResp {
        public Boolean success { get; set; }
        public String accountId { get; set; }
        public String invoiceId { get; set; }
        public String subscriptionId { get; set; }
    }

    public class FetchQuerySubscriptions {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchSubscription> records { get; set; }
        public FetchQuerySubscriptions() {
            records = null;
        }
    }

    public class FetchAccounts {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchAccount> records { get; set; }
        public FetchAccounts() {
            records = null;
        }
    }

    public class FetchAccount {
        public Boolean AutoPay { get; set; }
        public String AutoPayUncheckedReasonxxc { get; set; }
        public Decimal Balance { get; set; }
        public String Batch { get; set; }
        public Integer BillCycleDay { get; set; }
        public Decimal CreditBalance { get; set; }
        public String DefaultPaymentMethodId { get; set; }
        public String Id { get; set; }
        public String PaymentGateway { get; set; }
        public String PaymentTerm { get; set; }
        public String Status { get; set; }
        public String TaxExemptCertificateID { get; set; }
        public String TaxExemptCertificateType { get; set; }
        public Date TaxExemptEffectiveDate { get; set; }        
        public Date TaxExemptExpirationDate { get; set; }
        public String TaxExemptStatus { get; set; }
        public Decimal TotalInvoiceBalance { get; set; }
        public String VATId { get; set; }    
        public String LegalCompanyNamexxc { get; set; }
        public String Tax_Exempt_Reasonxxc { get; set; }
    }
    
    public class UpdateInvoiceReq {
        public List<UpdateInvObj> objects { get; set; }
        public String type { get; set; }
        public UpdateInvoiceReq(List<String> InvoiceZIds) {
            type = 'Invoice';
            objects = new List<UpdateInvObj>();
            for (String InvoiceZId : InvoiceZIds) {
                objects.add(new UpdateInvObj(InvoiceZId));
            }
        }
    }
    
    public class UpdateInvObj {
        public String Id { get; set; }
        public Date SalesforceSendDatexxc { get; set; }
        public UpdateInvObj(String InvoiceZId) {
            Id = InvoiceZId;
            SalesforceSendDatexxc = Date.today();
        }
    }
    
    public class UpdateAccountReq {
        public List<UpdateAcctObj> objects { get; set; }
        public String type { get; set; }
        public UpdateAccountReq(List<Account> Accounts) {
            type = 'Account';
            objects = new List<UpdateAcctObj>();
            for (Account Account : Accounts) {
                objects.add(new UpdateAcctObj(Account));
            }
        }
    }
    
    public class UpdateAcctObj {
        public String Id { get; set; }
        public String LegalCompanyNamexxc { get; set; }
        public String myOrderbirdEmailxxc { get; set; }
        public String Tax_Exempt_Reasonxxc { get; set; }
        public String Dunning_Statusxxc { get; set; }
        public String VATId { get; set; }
        public String Name { get; set; }
        public UpdateAcctObj(Account Account) {
            Id = Account.ZuoraId__c;
            LegalCompanyNamexxc = Account.LegalCompanyName__c;
            myOrderbirdEmailxxc  = Account.myOrderbirdEmail__c;
            Tax_Exempt_Reasonxxc = Account.Tax_Exempt_Reason__c;
            Dunning_Statusxxc = Account.Dunning_Status__c;
            VATId = Account.VATNumber__c;
            Name = Account.Name;
        }
    }
    
    public class FetchAmendments {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchAmendment> records { get; set; }
        public FetchAmendments() {
            records = null;
        }
    }

    public class FetchAmendment {
        public String Id { get; set; }
        public Date EffectiveDate { get; set; }
        public String SubscriptionId { get; set; }
    }

    public class FetchSubscriptions {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchSubscription> records { get; set; }
        public FetchSubscriptions() {
            records = null;
        }
    }

    public class FetchSubscription {
        public String AccountId { get; set; }
        public Boolean AutoRenew { get; set; }
        public Date CancelledDate { get; set; }
        public Date ContractAcceptanceDate { get; set; }
        public Date ContractEffectiveDate { get; set; }
        public Double CurrentTerm { get; set; }
        public String CurrentTermPeriodType { get; set; }
        public String Id { get; set; }
        public String InvoiceOwnerId { get; set; }
        public Boolean IsInvoiceSeparate { get; set; }
        public String Name { get; set; }
        public String OriginalId { get; set; }
        public String PreviousSubscriptionId { get; set; }
        public String RenewalSetting { get; set; }
        public Double RenewalTerm { get; set; }
        public String RenewalTermPeriodType { get; set; }
        public Date ServiceActivationDate { get; set; }
        public String Status { get; set; }
        public Date SubscriptionEndDate { get; set; }
        public Date SubscriptionStartDate { get; set; }
        public Date TermEndDate { get; set; }
        public Date TermStartDate { get; set; }
        public String TermType { get; set; }
        public Integer Version { get; set; }
    }

    public class FetchSLIMap {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchSLIMapping> records { get; set; }
        public FetchSLIMap() {
            records = null;
        }
    }

    public class FetchSLIMapping {
        public String Id { get; set; }
        public String SubscriptionId { get; set; }
    }

    public class FetchSubItems {
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchSubItem> records { get; set; }
        public FetchSubItems() {
            records = null;
        }
    }

    public class FetchSubItem {
        public String Id { get; set; }
        public String BillingPeriodAlignment { get; set; }
        public String ChargeNumber { get; set; }
        public String Description { get; set; }
        public Double DMRC { get; set; }
        public Double DTCV { get; set; }
        public Date EffectiveEndDate { get; set; }
        public Date EffectiveStartDate { get; set; }
        public Boolean IsLastSegment { get; set; }
        public Double MRR { get; set; }
        public String Name { get; set; }
        public String OriginalId { get; set; }
        public Double Price { get; set; }
        public Double DiscountAmount { get; set; }
        public String ProductRatePlanChargeId { get; set; }
        public Double Quantity { get; set; }
        public String RatePlanId { get; set; }
        public String Test1xxc { get; set; }
        public Double TCV { get; set; }
        public String VAT_refxxc { get; set; }
        public Integer Version { get; set; }
    }

    public class FetchInvoices { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchInvoice> records { get; set; }
        public FetchInvoices() {
            records = null;
        }
    }

    public class FetchInvoice {
        public String AccountId { get; set; }
        public Decimal AdjustmentAmount { get; set; }
        public Decimal Amount { get; set; }
        public Decimal AmountWithoutTax { get; set; }
        public Decimal Balance { get; set; }
        public Decimal CreditBalanceAdjustmentAmount { get; set; }
        public Date DueDate { get; set; }
        public String Id { get; set; }
        public String IncludesHardwarexxc { get; set; }
        public Boolean IncludesOneTime { get; set; }
        public Boolean IncludesRecurring { get; set; }
        public Boolean IncludesUsage { get; set; }
        public Date InvoiceDate { get; set; }
        public String InvoiceNumber { get; set; }
        public Decimal PaymentAmount { get; set; }
        public DateTime PostedDate { get; set; }
        public Decimal RefundAmount { get; set; }
        public String Status { get; set; }
        public Date TargetDate { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal TaxExemptAmount { get; set; }
        public DateTime UpdatedDate { get; set; }
        public String VAT_refxxc { get; set; }
    }

    public class FetchInvoiceItems { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchInvoiceItem> records { get; set; }
        public FetchInvoiceItems() {
            records = null;
        }
    }

    public class FetchInvoiceItem {
        public Decimal ChargeAmount { get; set; }
        public String ChargeName { get; set; }
        public String Id { get; set; }
        public String InvoiceId { get; set; }
        public Decimal Quantity { get; set; }
        public String RatePlanChargeId { get; set; }
        public String ChargeId { get; set; }
        public Date ServiceStartDate { get; set; }
        public Date ServiceEndDate { get; set; }
        public String SubscriptionId { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal TaxExemptAmount { get; set; }
        public Decimal UnitPrice { get; set; }
    }

    public class FetchPayments { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchPayment> records { get; set; }
        public FetchPayments() {
            records = null;
        }
    }

    public class FetchPayment {
        public String AccountId { get; set; }
        public String AccountingCode { get; set; }
        public Decimal Amount { get; set; }
        public Decimal AppliedInvoiceAmount { get; set; }
        public Decimal AppliedCreditBalanceAmount { get; set; }
        public String AuthTransactionId { get; set; }
        public String BankIdentificationNumber { get; set; }
        public DateTime CancelledOn { get; set; }
        public String Comment { get; set; }
        public DateTime CreatedDate { get; set; }
        public Decimal CreditBalanceAmount { get; set; }
        public String CurrencyX { get; set; }
        public DateTime EffectiveDate { get; set; }
        public String GatewayResponse { get; set; }
        public String GatewayResponseCode { get; set; }
        public String GatewayState { get; set; }
        public String Id { get; set; }
        public String PaymentNumber { get; set; }
        public Decimal RefundAmount { get; set; }
        public DateTime SettledOn { get; set; }
        public String Status { get; set; }
        public DateTime SubmittedOn { get; set; }
        //public Boolean Success { get; set; }
        public String Type { get; set; }
        public Decimal UnappliedAmount { get; set; }
    }

    public class FetchInvPmts { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchInvPmt> records { get; set; }
        public FetchInvPmts() {
            records = null;
        }
    }

    public class FetchInvPmt {
        public Decimal Amount { get; set; }
        public String Id { get; set; }
        public String InvoiceId { get; set; }
        public String PaymentId { get; set; }
        public Decimal RefundAmount { get; set; }
    }

    public class FetchRefunds { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchRefund> records { get; set; }
        public FetchRefunds() {
            records = null;
        }
    }

    public class FetchRefund {
        public String AccountId { get; set; }
        public Decimal Amount { get; set; }
        public DateTime CancelledOn { get; set; }
        public String CurrencyX { get; set; }
        public DateTime EffectiveDate { get; set; }
        public String GatewayResponse { get; set; }
        public String GatewayResponseCode { get; set; }
        public String GatewayState { get; set; }
        public String Id { get; set; }
        public String PaymentId { get; set; }
        public Date RefundDate { get; set; }
        public String RefundNumber { get; set; }
        public DateTime SettledOn { get; set; }
        public String Status { get; set; }
        public String Type { get; set; }
    }

    public class FetchInvRefs { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchInvRef> records { get; set; }
        public FetchInvRefs() {
            records = null;
        }
    }

    public class FetchInvRef {
        public String Id { get; set; }
        public String InvoiceId { get; set; }
        public String RefundId { get; set; }
        public Decimal RefundAmount { get; set; }
    }

    public class FetchPmtMtds { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchPmtMtd> records { get; set; }
        public FetchPmtMtds() {
            records = null;
        }
    }

    public class FetchPmtMtd {
        public String Id { get; set; }
        public String AccountId { get; set; }
        public String Name { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String AchAbaCode { get; set; }
        public String AchAccountNumberMask { get; set; }
        public String AchAccountType { get; set; }
        public String AchBankName { get; set; }
        public Boolean Active { get; set; }
        public String BankBranchCode { get; set; }
        public String BankCheckDigit { get; set; }
        public String BankCode { get; set; }
        public String BankIdentificationNumber { get; set; }
        public String BankName { get; set; }
        public String BankTransferAccountName { get; set; }
        public String BankTransferAccountNumberMask { get; set; }
        public String BankTransferAccountType { get; set; }
        public String BankTransferType { get; set; }
        public String BusinessIdentificationCode { get; set; }
        public String City { get; set; }
        public String Country { get; set; }
        public Integer CreditCardExpirationMonth { get; set; }
        public Integer CreditCardExpirationYear { get; set; }
        public String CreditCardHolderName { get; set; }
        public String CreditCardMaskNumber { get; set; }
        public String CreditCardType { get; set; }
        public String IPAddress { get; set; }
        public DateTime LastFailedSaleTransactionDate { get; set; }
        public DateTime LastTransactionDateTime { get; set; }
        public String LastTransactionStatus { get; set; }
        public String MandateID { get; set; }
        public String PaymentMethodStatus { get; set; }
        public String PaypalBaid { get; set; }
        public String PaypalEmail { get; set; }
        public String PaypalPreapprovalKey { get; set; }
        public String PaypalType { get; set; }
        public String Phone { get; set; }
        public String Type { get; set; }
    }
    
    public class FetchCBAs { 
        public Boolean done { get; set; }
        public String queryLocator { get; set; }
        public List<FetchCBA> records { get; set; }
        public FetchCBAs() {
            records = null;
        }
    }

    public class FetchCBA {
        public String Id { get; set; }
        public String AccountId { get; set; }
        public Date AdjustmentDate { get; set; }
        public Decimal Amount { get; set; }
        public DateTime CancelledOn { get; set; }
        public String Comment { get; set; }
        public String NumberX { get; set; }
        public String Status { get; set; }
        public String Type { get; set; }
        public String SourceTransactionId { get; set; }
        public String SourceTransactionNumber { get; set; }
        public String SourceTransactionType { get; set; }
    }
    
}