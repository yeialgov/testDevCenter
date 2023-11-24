public class LookupSearchResult {

    private Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private String engName;

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, String engName) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.engName = engName;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    @AuraEnabled
    public String getEngName() {
        return engName;
    }
}