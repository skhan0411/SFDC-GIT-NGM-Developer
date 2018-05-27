public class InsertMerArc {


    public static void MerchandiseInsert(List<Merchandies__c > m) {
    Merchandise_Arc__c ma = new Merchandise_Arc__c();
    ma.name = m[0].name;
    insert ma;
    }
    
}