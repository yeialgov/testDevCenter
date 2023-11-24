/**
 * @author joern
 */
@IsTest
private class InvoicePaymentStatusTest {
    
    static testMethod void test() {
        InvoiceHandler InvoiceHandler = new InvoiceHandler();
        InvoicePaymentStatus InvoicePaymentStatus = new InvoicePaymentStatus();
    }
    
    /*
    static testMethod void isPosted_should_return_true() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(0.00, 'Posted', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        System.assertEquals(true, ips.isPosted(im.values().get(0)));
    }

    static testMethod void isPosted_should_return_false() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(0.00, 'Posted', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        inv.put('Zuora__Status__c', 'Cancelled');
        System.assertEquals(false, ips.isPosted(inv));
        inv.put('Zuora__Status__c', null);
        System.assertEquals(false, ips.isPosted(inv));
    }

    static testMethod void setPaymentsPerInvoice_should_return_one_invoice_with_three_payments() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(0.00, 'Posted', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        ips.paymentsPerInvoice = new Map<Id, List<Zuora__PaymentInvoice__c>>();
        ips.setPaymentsPerInvoice(im);
        System.assertEquals(1, ips.paymentsPerInvoice.size());
        System.assertEquals(3, ips.paymentsPerInvoice.values().get(0).size());
    }

    static testMethod void setInvoicePaymentStatus_should_set_paymentStatus_Settled() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(0.00, 'Posted', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        ips.setInvoicePaymentStatus(inv);
        System.assertEquals('Settled', inv.Payment_Status2__c);
    }

    static testMethod void setInvoicePaymentStatus_should_set_paymentStatus_Submitted() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(1.00, 'Posted', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        ips.setInvoicePaymentStatus(inv);
        System.assertEquals('Submitted', inv.Payment_Status2__c);
    }

    static testMethod void setInvoicePaymentStatus_should_set_paymentStatus_FailedToSettle() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(1.00, 'Posted', 'FailedToSettle', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        ips.setInvoicePaymentStatus(inv);
        System.assertEquals('Failed to Settle', inv.Payment_Status2__c);
    }

    static testMethod void setInvoicePaymentStatus_should_set_paymentStatus_FirstInstallmentPaid() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(6.66, 'Posted', 'Submitted', 'Installment Payment 3 Rates', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        ips.setInvoicePaymentStatus(inv);
        System.assertEquals('First Installment Paid', inv.Payment_Status2__c);
    }

    static testMethod void setInvoicePaymentStatus_should_set_paymentStatus_na() {
        Map<Id, Zuora__ZInvoice__c> im = setUpTestData(0.00, 'Something', 'Submitted', 'Due Upon Receipt', 10.00);
        InvoicePaymentStatus ips = new InvoicePaymentStatus(im);
        Zuora__ZInvoice__c inv = im.values().get(0);
        ips.setInvoicePaymentStatus(inv);
        System.assertEquals('n/a', inv.Payment_Status2__c);
    }

    private static Map<Id, Zuora__ZInvoice__c> setUpTestData(Decimal invoiceBalance, String invoiceStatus, String gatewayStatus, String paymentTerm, Decimal totalAmount) {
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c(
                Zuora__Status__c = invoiceStatus,
                Zuora__Balance2__c = invoiceBalance,
                Zuora__PaymentTerm__c = paymentTerm,
                Zuora__TotalAmount__c = totalAmount
        );
        insert invoice;

        Account za = new Account(Name='AccountName');
        insert za;

        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba.Zuora__Account__c = za.Id;
        insert ba;

        Zuora__Payment__c pm = new Zuora__Payment__c(
                Zuora__Type__c = 'Electronic',
                Zuora__GatewayStatus__c = 'Submitted',
                Zuora__AccountingCode__c = 'gocardless',
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 12, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 14, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__BillingAccount__c = ba.Id
        );
        Zuora__Payment__c pm2 = new Zuora__Payment__c(
                Zuora__Type__c = 'Electronic',
                Zuora__GatewayStatus__c = gatewayStatus,
                Zuora__AccountingCode__c = 'gocardless',
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 13, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 18, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__BillingAccount__c = ba.Id
        );
        Zuora__Payment__c pm3 = new Zuora__Payment__c(
                Zuora__Type__c = 'Electronic',
                Zuora__GatewayStatus__c = 'Submitted',
                Zuora__AccountingCode__c = 'gocardless',
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 13, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 17, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__BillingAccount__c = ba.Id
        );
        insert new List<SObject>{pm, pm2, pm3};


        Zuora__PaymentInvoice__c ip = new Zuora__PaymentInvoice__c(
                Zuora__ApplyAmount__c = 3.00,
                Zuora__Payment__c = pm.Id,
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 12, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 14, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__EXT_ID__c = '1212314521'
        );
        Zuora__PaymentInvoice__c ip2 = new Zuora__PaymentInvoice__c(
                Zuora__ApplyAmount__c = 3.00,
                Zuora__Payment__c = pm2.Id,
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 13, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 18, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__EXT_ID__c = '1212124211'
        );
        Zuora__PaymentInvoice__c ip3 = new Zuora__PaymentInvoice__c(
                Zuora__ApplyAmount__c = 3.00,
                Zuora__Payment__c = pm3.Id,
                CreatedDate = Datetime.newInstanceGmt(2017, 9, 26, 13, 20, 30),
                LastModifiedDate = Datetime.newInstanceGmt(2017, 9, 26, 17, 20, 30),
                Zuora__Invoice__c = invoice.Id,
                Zuora__EXT_ID__c = '12123211'
        );
        insert new List<SObject>{ip, ip2, ip3};

        Map<Id, Zuora__ZInvoice__c> invoices = new Map<Id, Zuora__ZInvoice__c>();
        invoices.put(invoice.Id, invoice);
        return invoices;
    }*/
}