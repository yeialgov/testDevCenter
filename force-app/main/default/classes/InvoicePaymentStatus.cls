/**
 * @author joern
 * @description https://jira.orderbird.com/browse/SAL-1311
 */
public with sharing class InvoicePaymentStatus {/*

    private String paymentStatusField = 'Payment_Status2__c';

    /**
     * Payments per invoice
     *
    @TestVisible
    private Map<Id, List<Zuora__PaymentInvoice__c>> paymentsPerInvoice = new Map<Id, List<Zuora__PaymentInvoice__c>>();

    public InvoicePaymentStatus(Map<Id, SObject> invoices) {
        if (invoices != null) {
            this.setPaymentsPerInvoice((Map<Id, Zuora__ZInvoice__c>)invoices);
        }
    }

    /**
     * @description set invoice payment status
     * @param invoice
     *
    public void setInvoicePaymentStatus(Zuora__ZInvoice__c invoice) {
        invoice.put(this.paymentStatusField, 'n/a');

        if(this.isPosted(invoice)) {

            if (invoice.Zuora__Balance2__c == 0) {
                invoice.put(this.paymentStatusField, 'Settled');
            } else {
                Zuora__PaymentInvoice__c lastPayment = getLastPayment(invoice.Id);

                if (lastPayment != null) {
                    String type = (String) lastPayment.Zuora__Payment__r.Zuora__Type__c;
                    String gatewayStatus = (String) lastPayment.Zuora__Payment__r.Zuora__GatewayStatus__c;
                    String accountingCode = (String) lastPayment.Zuora__Payment__r.Zuora__AccountingCode__c;
                    String paymentTerm = invoice.Zuora__PaymentTerm__c;

                    if (type == 'Electronic' &&
                            accountingCode == 'gocardless' &&
                            gatewayStatus == 'Submitted' &&
                            paymentTerm != 'Installment Payment 3 Rates') {
                        invoice.put(this.paymentStatusField, 'Submitted');
                    } else if (type == 'Electronic' && accountingCode == 'gocardless' && gatewayStatus == 'FailedToSettle') {
                        invoice.put(this.paymentStatusField, 'Failed to Settle');
                    } else if (paymentTerm == 'Installment Payment 3 Rates') {
                        Decimal totalAmount4 = invoice.Zuora__TotalAmount__c / 4.00;
                        Decimal totalAmount2 = invoice.Zuora__TotalAmount__c / 2.00;
                        Decimal payed = invoice.Zuora__TotalAmount__c - invoice.Zuora__Balance2__c;
                        if (payed < totalAmount2 && payed > totalAmount4) {
                            invoice.put(this.paymentStatusField, 'First Installment Paid');
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Get last payment for given invoice
     * @param  invoiceId
     * @return Zuora__PaymentInvoice__c || null
     *
    @TestVisible
    private Zuora__PaymentInvoice__c getLastPayment(Id invoiceId) {
        if (this.paymentsPerInvoice.get(invoiceId) == null) {
            return null;
        } else {
            return this.paymentsPerInvoice.get(invoiceId).get(0);
        }
    }

    /**
     * @description Retrieve all related payments and build Map<Id, List<Zuora__PaymentInvoice__c>>
     * @param invoices
     *
    @TestVisible
    private void setPaymentsPerInvoice(Map<Id, Zuora__ZInvoice__c> invoices) {
        Set<Id> invoiceIds = invoices.keySet();
        Map<Id, Zuora__PaymentInvoice__c> payments = new Map<Id, Zuora__PaymentInvoice__c>([
                SELECT Id, Zuora__Invoice__c, Zuora__Payment__r.Id, Zuora__Payment__r.Zuora__Invoice__c,
                        Zuora__Payment__r.Zuora__Type__c, Zuora__Payment__r.Zuora__GatewayStatus__c,
                        Zuora__Payment__r.Zuora__AccountingCode__c, Zuora__Payment__r.LastModifiedDate
                FROM Zuora__PaymentInvoice__c
                WHERE Zuora__Invoice__c IN :invoiceIds
                ORDER BY LastModifiedDate DESC]);

        for (Zuora__PaymentInvoice__c payment : payments.values()) {
            if(this.paymentsPerInvoice.containsKey(payment.Zuora__Invoice__c)) {
                this.paymentsPerInvoice.get(payment.Zuora__Invoice__c).add(payment);
            } else {
                List<Zuora__PaymentInvoice__c> p = new List<Zuora__PaymentInvoice__c>();
                p.add(payment);
                this.paymentsPerInvoice.put(payment.Zuora__Invoice__c, p);
            }
        }
    }

    /**
     * @description Check if invoice is posted
     * @param invoice
     * @return Boolean
     *
    @TestVisible
    private Boolean isPosted(Zuora__ZInvoice__c invoice) {
        String status = invoice.Zuora__Status__c;
        return status != null && status.equalsIgnoreCase('posted');
    }
*/}