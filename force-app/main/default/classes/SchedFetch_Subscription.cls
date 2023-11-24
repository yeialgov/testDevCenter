global class SchedFetch_Subscription implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.SubscriptionCollectionUpsert(ZuoraSyncController.FetchSubscriptionCollection(UpdatedDate));
    }
}