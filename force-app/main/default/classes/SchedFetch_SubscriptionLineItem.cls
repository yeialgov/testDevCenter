global class SchedFetch_SubscriptionLineItem implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.SubItemCollectionUpsert(ZuoraSyncController.FetchSubItemCollection(UpdatedDate));
    }
}