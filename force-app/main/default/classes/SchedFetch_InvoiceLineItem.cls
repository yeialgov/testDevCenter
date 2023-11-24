global class SchedFetch_InvoiceLineItem implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.InvItemCollectionUpsert(ZuoraSyncController.FetchInvItemCollection(UpdatedDate));
    }
}