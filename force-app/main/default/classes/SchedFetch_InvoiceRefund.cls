global class SchedFetch_InvoiceRefund implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.InvRefCollectionUpsert(ZuoraSyncController.FetchInvRefCollection(UpdatedDate));
    }
}