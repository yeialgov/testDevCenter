global class SchedFetch_Refund implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.RefundCollectionUpsert(ZuoraSyncController.FetchRefundCollection(UpdatedDate));
    }
}