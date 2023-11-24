global class SchedFetch_Payment implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.PaymentCollectionUpsert(ZuoraSyncController.FetchPaymentCollection(UpdatedDate));
    }
}