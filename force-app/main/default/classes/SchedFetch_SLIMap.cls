global class SchedFetch_SLIMap implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date UpdatedDate = Date.today().addDays(-2);
        ZuoraSyncController.SLIMapCollectionUpsert(ZuoraSyncController.FetchSLIMapCollection(UpdatedDate));
    }
}