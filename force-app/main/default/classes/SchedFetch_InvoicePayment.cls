global class SchedFetch_InvoicePayment implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.InvPmtCollectionUpsert(ZuoraSyncController.FetchInvPmtCollection(UpdatedDate));
    }
}