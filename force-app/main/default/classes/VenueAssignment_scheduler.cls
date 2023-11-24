global class VenueAssignment_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        VenueAssignment b = new VenueAssignment(); 
        database.executebatch(b);
    }
}