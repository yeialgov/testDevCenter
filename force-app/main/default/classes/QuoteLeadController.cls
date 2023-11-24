public class QuoteLeadController {
    
    @InvocableMethod(label='Generate Quote Id' description='Generate Quote Id for Lead')   
    public static void GenerateQuoteId(List<Id> LeadIds) {
        Map<String,String> HexMap = new Map<String,String>{'4a'=>'80','4b'=>'81','4c'=>'82','4d'=>'83','4e'=>'84','4f'=>'85','5a'=>'86','6a'=>'87','6b'=>'88','6c'=>'89','6d'=>'90','6e'=>'91','6f'=>'92','7a'=>'93'};
        Map<Id,String> ResultMap = new Map<Id,String>();
        for (Id LeadId : LeadIds) {
            string x = String.valueOf(LeadId).mid(5,10);
            String o = '';
            for (integer i=0; i<10; i++) {
                String s = x.mid(i,1);
                if (s != '0' || o != '') {
                    String hex = EncodingUtil.convertToHex(Blob.valueOf(s));
                    if (HexMap.keySet().contains(hex)) hex = HexMap.get(Hex);
                    o += Hex;
                }
            }
            ResultMap.put(LeadId, 'Q'+o.mid(0,3)+'-'+o.mid(3,3)+'-'+o.mid(6,4));
        }
        List<Lead> Leads = [SELECT Id, PreorderQuote__c FROM Lead WHERE Id IN :LeadIds];
        for (Lead l : Leads) { l.PreorderQuote__c = ResultMap.get(l.Id); }
        update Leads;
    }
}