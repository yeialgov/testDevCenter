/**
 * Account/Lead trigger class
 *
 * Assign Region, SDR, CSM, Regional Manager and Account Manager to
 * Accounts and Region to Leads based on country or postal code.
 */
public with sharing class RegionManager {

    @TestVisible
    private Map<String, Region__c> regions = new Map<String, Region__c>();

    @TestVisible
    private Region__c region;

    /**
     * Assignment of all fields per object type which are needed
     */
    private Map<String, List<String>> fields = new Map<String, List<String>>{
           'Lead' => new List<String>{'Region__c'},
           'Account' => new List<String>{
                   'Region__c',
                   'AccountManager__c',
                   'SDR__c',
                   'CSM__c',
                   'RegionalManager__c'
           },
           'Region__c' => new List<String>{
                   'Name',
                   'Region__c',
                   'AccountManager__c',
                   'SDR__c',
                   'CSM__c',
                   'RegionalManager__c',
                   'AccountManager__r.IsActive',
                   'RegionalManager__r.IsActive',
                   'SDR__r.IsActive',
                   'CSM__r.IsActive'
           }
    };

    /**
     * Assignment of object-type-dependent field names.
     * OBJECT-TYPE-Name + FIELDNAME => object-type-dependent field name OR
     * USER-LOOKUP => RELATED-SOBJECT
     */
    private Map<String, String> fieldMap = new Map<String, String>{
            'LeadCountry' => 'Country',
            'LeadCountryCode' => 'CountryCode',
            'LeadPostalCode' => 'PostalCode',
            'AccountCountry' => 'BillingCountry__c',
            'AccountCountryCode' => 'BillingCountryCode__c',
            'AccountPostalCode' => 'BillingPostalCode__c',
            'AccountManager__c' => 'AccountManager__r',
            'SDR__c' => 'SDR__r',
            'CSM__c' => 'CSM__r',
            'RegionalManager__c' => 'RegionalManager__r'
    };

    private Map<String, String> regionMap = new Map<String, String>{
            'FR' => 'France',
            'DE' => 'Germany',
            'AT' => 'Austria',
            'CH' => 'Switzerland'
    };

    /**
     * Allowed values are 'Lead' and 'Account'
     */
    private String objectType;

    /**
     * Country field Id, depends on object type
     */
    private String countryField;

    /**
     * CountryCode field Id, depends on object type
     */
    private String countryCodeField;

    /**
     * Postal code field Id, depends on object type
     */
    private String postalCodeField;

    public RegionManager(String type) {
        this.objectType = type;
        this.countryField = this.fieldMap.get(type + 'Country');
        this.countryCodeField = this.fieldMap.get(type + 'CountryCode');
        this.postalCodeField = (String)this.fieldMap.get(type + 'PostalCode');
        this.loadAllRegions();
    }

    /**
     * Use setRegionValues in before insert triggers
     */
    public void setRegionValues(sObject obj) {
        Region__c region = this.getRegion(obj);
        if (region != null) {
            this.setFieldValues(obj, region);
        }
    }

    /**
     * Use setRegionValues in before update triggers. Checks, if country or postal codes
     * has been changed.
     */
    public void updateRegionValues(sObject obj, sObject objOld) {
        //if(hasChanged(obj, objOld)) {
            Region__c region = this.getRegion(obj);
            if (region != null) {
                this.setFieldValues(obj, region);
            }
        //}
    }

    @TestVisible
    private void setFieldValues(sObject obj, Region__c region) {
        for (String field : this.fields.get(this.objectType)) {
            if (region.get(field) != null) {
                if (this.fieldMap.get(field) != null) {
                    User u = (User) region.getSObject(this.fieldMap.get(field));
                    if(u != null && u.IsActive) {
                        obj.put(field, region.get(field));
                    } /* else {
                    	obj.put(field, null);
                    } */
                } else {
                    obj.put(field, region.get(field));
                }
            }
        }
    }

    /*@TestVisible
    private Boolean hasChanged(sObject obj, sObject objOld) {
        return obj.get(this.countryCodeField) != objOld.get(this.countryCodeField) ||
                obj.get(this.postalCodeField) != objOld.get(this.postalCodeField);
    }*/

    @TestVisible
    private Region__c getRegion(sObject obj) {
        String regionName;
        String countryCode = (String)obj.get(this.countryCodeField);
        if (String.isEmpty(countryCode)) {
            for (String regionMapKey : regionMap.keySet()) {
                if (regionMap.get(regionMapKey) == (String)obj.get(this.countryField)) countryCode = regionMapKey;
            }
        }
        if(!String.isEmpty(countryCode) && this.usePostalCode(countryCode)) {
            String postalCode = (String)obj.get(this.postalCodeField);
            if(postalCode != null && postalCode.length() > 2) {
                regionName = postalCode.substring(0,2);
            } else {
                return null;
            }
        } else {
            regionName = this.regionMap.get(countryCode);
        }
        return this.regions.get(regionName);
    }

    @TestVisible
    private void loadAllRegions() {
        String query = 'SELECT  ' +
                String.join(this.fields.get('Region__c'), ', ') +
                ' FROM Region__c';
        List<Region__c> pCodes = Database.query(query);
        for (Region__c pc : pCodes) {
            this.regions.put(pc.Name, pc);
        }
    }

    /**
     * Check if we have to use the postal code field to find the region object by name
     */
    private Boolean usePostalCode(String country) {
        return country.equals('DE');
    }
}