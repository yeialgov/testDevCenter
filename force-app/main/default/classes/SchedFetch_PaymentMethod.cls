global class SchedFetch_PaymentMethod implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.PmtMtdCollectionUpsert(ZuoraSyncController.FetchPmtMtdCollection(UpdatedDate));
    }
}