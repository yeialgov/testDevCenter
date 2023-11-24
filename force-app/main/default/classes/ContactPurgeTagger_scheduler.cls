global class ContactPurgeTagger_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ContactPurgeTagger b = new ContactPurgeTagger(); 
        database.executebatch(b);
    }
}