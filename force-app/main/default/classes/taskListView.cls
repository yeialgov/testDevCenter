public with sharing class taskListView {
    
    public list<Task> tasks { get; set; }
    public list<Task> tasksSec { get; set; }
    public list<Task> tasksTer { get; set; }

    public Id taskToClose { get; set; }
    
    public String dateRange { get; set; }

    public Static Map<String,String> listViews = new Map<String,String>{
        'Today + Overdue' => ' AND ActivityDate <= TODAY ',
            'Overdue' => ' AND ActivityDate < TODAY ',
            'Today' => ' AND ActivityDate = TODAY ',
            'Tomorrow' => ' AND ActivityDate = TOMORROW ',
            'Next 7 Days' => ' AND ActivityDate = NEXT_n_DAYS:7 ',
            'Next 7 Days + Overdue' => ' AND ActivityDate <= NEXT_n_DAYS:7 ',
            'This Month' => ' AND ActivityDate = THIS_MONTH ',
            'All Open' => ' '
    };
            
    public taskListView() {
        if (dateRange == null) dateRange = 'Today + Overdue';
        updateList();
    }
    
    public void updateList() {
        tasks = Database.query(getSoql(dateRange, 0));
        tasksSec = Database.query(getSoql(dateRange, 1));
        tasksTer = Database.query(getSoql(dateRange, 2));
        tasks.addAll(tasksSec);
        tasks.addAll(tasksTer);
    }
    
    public Static String getSoql(String viewName, Integer sortGroup) {
        String r = 'SELECT Id, IsClosed, Subject, Status, ActivityDate, WhoId, Who.Name, WhatId, What.Name, AccountId, Account.Name, ReminderDateTime, Activity_Type__c, Type__c ' 
            + 'FROM Task '
            + 'WHERE IsClosed = false AND OwnerId = \'' + UserInfo.getUserId() + '\''
            + listViews.get(viewName);
        if (sortGroup==0) {
            r += 'AND Subject = \'A NEW INBOUND LEAD requires your attention!\' ';
            r += 'ORDER BY CreatedDate DESC LIMIT 25';
        } else if (sortGroup==1) {
            r += 'AND Subject != \'A NEW INBOUND LEAD requires your attention!\' ';
            r += 'AND WhatId IN (SELECT ConvertedOpportunityId FROM Lead WHERE ConvertedDate >= LAST_n_DAYS:5) ';
            r += 'ORDER BY ActivityDate ASC LIMIT 25';
        } else {
            r += 'AND Subject != \'A NEW INBOUND LEAD requires your attention!\' ';
            r += 'AND WhatId NOT IN (SELECT ConvertedOpportunityId FROM Lead WHERE ConvertedDate >= LAST_n_DAYS:5) ';
            r += 'ORDER BY ActivityDate ASC, Activity_Type__c DESC LIMIT 25';
        }
        return r;
    }
    
    public void rangeQuery() {
        updateList();
    }
    
    public void taskClose() {
        Task t = [SELECT Id, Status FROM Task WHERE Id=:taskToClose LIMIT 1];
        t.Status = 'Completed';
        update t;
        updateList();
    }
    
}