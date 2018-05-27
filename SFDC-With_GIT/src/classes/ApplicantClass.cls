public class ApplicantClass {
@auraenabled
    public static List<Applicant__c> appli(){
        return [select Salutation__c, Given_Names__c,Email__c, Address__c from Applicant__c];
    }
    
    @auraenabled
    public static List<account> accInsert(){
        account a = new account();
     //   a.name = acName;
        //insert a;
        return [select id, name,fax from account];
    }
}