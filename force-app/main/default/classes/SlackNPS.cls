public class SlackNPS implements Queueable, Database.AllowsCallouts {
    
    public String ASId { get; set; }
    
    public SlackNPS(String ausuId) {
        ASId = ausuId;
    }
    
    public SlackNPS() {}
    
    public void execute(QueueableContext context) {
        
        String webhook = NPSSlackWebhook__c.getInstance([SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1].Id).WebhookURL__c;
        if (test.isRunningTest()) webhook = 'testendpoint';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(webhook);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        if (ASId != null) {
            AutomatedSurvey__c Survey = [
                SELECT Id, NPS__c, Comment__c, 
                Contact__r.Name, Contact__r.Email, Contact__r.NameIssue__c, 
                Contact__r.AccountId, Contact__r.Account.Name, Contact__r.Account.Target_Product__c
                FROM AutomatedSurvey__c
                WHERE Id = :ASId
            ];
            req.setBody(JSON.serialize(new NPSSlackPost(Survey)));
        } else {
            req.setBody(JSON.serialize(new NPSSlackPost()));
        }
        if (!test.isRunningTest()) HttpResponse res = h.send(req);

    }
        
    public class NPSSlackPost {
        public List<NPSBlock> blocks { get; set; }
        public NPSSlackPost(AutomatedSurvey__c Survey) {
            blocks = new List<NPSBlock> { new NPSBlock(Survey) };
        }
        public NPSSlackPost() {
            blocks = new List<NPSBlock> { new NPSBlock() };
        }
    }
    
    public class NPSBlock {
        public String type { get; set; }
        public String block_id { get; set; }
        public NPSText text { get; set; }
        public NPSAccessory accessory { get; set; }
        public NPSBlock(AutomatedSurvey__c Survey) {
            type = 'section';
            block_id = 'section1';
            text = new NPSText(Survey);
            accessory = new NPSAccessory(String.valueOf(Survey.NPS__c));
        }
        public NPSBlock() {
            type = 'section';
            block_id = 'section1';
            text = new NPSText();
            accessory = new NPSAccessory();
        }
    }
    
    public class NPSText {
        public String type { get; set; }
        public String text { get; set; }
        public NPSText(AutomatedSurvey__c Survey) {
            type  = 'mrkdwn';
            text  = '<https://orderbird.lightning.force.com/lightning/r/Account/';
            text += Survey.Contact__r.AccountId;
            text += '/view|';
            text += Survey.Contact__r.Account.Name;
            text += '> ';
            text += Survey.Contact__r.Account.Target_Product__c == 'MINI' ? ':mini:' : '';
            text += '\n :bust_in_silhouette: ';
            if (Survey.Contact__r.NameIssue__c) { text += Survey.Contact__r.Email; } else { text += Survey.Contact__r.Name; }
            if (Survey.Comment__c != null) text += '\n>' + Survey.Comment__c;
        }
        public NPSText() {
            type  = 'mrkdwn';
            AggregateResult distantHalf = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c != LAST_n_DAYS:180 
                	AND DateResponded__c = LAST_n_DAYS:360
            ];
            AggregateResult recentHalf = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c = LAST_n_DAYS:180
            ];
            AggregateResult distantHalfMini = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c != LAST_n_DAYS:180 
                	AND DateResponded__c = LAST_n_DAYS:360
                	AND IsMini__c = TRUE
            ];
            AggregateResult recentHalfMini = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c = LAST_n_DAYS:180
                	AND IsMini__c = TRUE
            ];
            AggregateResult distantMonth = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c != LAST_n_DAYS:30 
                	AND DateResponded__c = LAST_n_DAYS:60
            ];
            AggregateResult recentMonth = [
                SELECT AVG(NPS_Calculator__c) avgNPS 
                FROM AutomatedSurvey__c 
                WHERE 
                	NPS__c != null 
                	AND DateResponded__c = LAST_n_DAYS:30
            ];
            String MonthNPS = '0.0'; try { MonthNPS = String.valueOf(((Decimal)recentMonth.get('avgNPS')).setScale(1)); } catch(exception e) {  }
            String HalfNPS = '0.0'; try { HalfNPS = String.valueOf(((Decimal)recentHalf.get('avgNPS')).setScale(1)); } catch(exception e) {  }
            String HalfMiniNPS = '0.0'; try { HalfMiniNPS = String.valueOf(((Decimal)recentHalfMini.get('avgNPS')).setScale(1)); } catch(exception e) {  }
            Decimal MonthDelta = 0.0; try { MonthDelta = ((Decimal)recentMonth.get('avgNPS')-(Decimal)distantMonth.get('avgNPS')).setScale(1); } catch(exception e) {  }
            Decimal HalfDelta = 0.0; try { HalfDelta = ((Decimal)recentHalf.get('avgNPS')-(Decimal)distantHalf.get('avgNPS')).setScale(1); } catch(exception e) {  }
            Decimal HalfMiniDelta = 0.0; try { HalfMiniDelta = ((Decimal)recentHalfMini.get('avgNPS')-(Decimal)distantHalfMini.get('avgNPS')).setScale(1); } catch(exception e) {  }
            String MonthChange = MonthDelta < 0 ? String.valueOf(MonthDelta) : '+' + String.valueOf(MonthDelta);
            String HalfChange = HalfDelta < 0 ? String.valueOf(HalfDelta) : '+' + String.valueOf(HalfDelta);
            String HalfChangeMini = HalfMiniDelta < 0 ? String.valueOf(HalfMiniDelta) : '+' + String.valueOf(HalfMiniDelta);
            text  = '_Daily Digest_\nLast 30 Days *['
                + MonthNPS
                + ']* `'
                + MonthChange
                + '`\nLast 180 Days *['
                + HalfNPS
                +']* `'
                + HalfChange
                + '`\n:mini: Last 180 Days *['
                + HalfMiniNPS
                +']* `'
                + HalfChangeMini
                +'`';
        }
    }
    
    public class NPSAccessory {
        public String type { get; set; }
        public String image_url { get; set; }
        public String alt_text { get; set; }
        public NPSAccessory() {
            type = 'image';
            alt_text = 'Update';
            image_url = 'https://media.giphy.com/media/FP47IFqWyXfdKYU6VG/giphy.gif';
        }
        public NPSAccessory(String NPS) {
            type = 'image';
            alt_text = NPS;
            switch on NPS {
                when '10' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/10_white%2C_green_rounded_rectangle.svg/120px-10_white%2C_green_rounded_rectangle.svg.png';
                }
                when '9' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/9_white%2C_green_rounded_rectangle.svg/84px-9_white%2C_green_rounded_rectangle.svg.png';
                }
                when '8' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/8_white%2C_blue_rounded_rectangle.svg/84px-8_white%2C_blue_rounded_rectangle.svg.png';
                }
                when '7' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/7_white%2C_blue_rounded_rectangle.svg/168px-7_white%2C_blue_rounded_rectangle.svg.png';
                }
                when '6' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/6_white%2C_red_rounded_rectangle.svg/84px-6_white%2C_red_rounded_rectangle.svg.png';
                }
                when '5' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/5_white%2C_red_rounded_rectangle.svg/84px-5_white%2C_red_rounded_rectangle.svg.png';
                }
                when '4' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/4_white%2C_red_rounded_rectangle.svg/84px-4_white%2C_red_rounded_rectangle.svg.png';
                }
                when '3' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/3_white%2C_red_rounded_rectangle.svg/84px-3_white%2C_red_rounded_rectangle.svg.png';
                }
                when '2' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/2_white%2C_red_rounded_rectangle.svg/84px-2_white%2C_red_rounded_rectangle.svg.png';
                }
                when '1' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/1_white%2C_red_rounded_rectangle.svg/72px-1_white%2C_red_rounded_rectangle.svg.png';
                }
                when '0' {
                    image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/0_white%2C_red_rounded_rectangle.svg/84px-0_white%2C_red_rounded_rectangle.svg.png';
                }
            }
        } 
    }
}