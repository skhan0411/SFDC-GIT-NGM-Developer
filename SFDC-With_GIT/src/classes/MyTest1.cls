@isTest
public class MyTest1 {
    public static testMethod void doTest() {
        Merchandies__c mer = new Merchandies__c();
        List<Merchandies__c> ls= [select id, name from Merchandies__c limit 1];
        mer.id = ls[0].id;
        delete mer;
    
    }

}