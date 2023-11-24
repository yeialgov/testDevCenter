global class SchedFetch_Invoice implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.InvoiceCollectionUpsert(ZuoraSyncController.FetchInvoiceCollection(UpdatedDate));
    }
}