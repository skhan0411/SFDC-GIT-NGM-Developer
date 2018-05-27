public class EmployeesWithLeave {

    public list<Leave__c> leaves {get;set;}
    public Leave__c leave {get;set;}
    public EmployeesWithLeave(){
        
        //employee= [select id, name,	First_Name__c, (select id, name, From_Date__c,To_Date__c from Leaves__r) from Employee__c where id=:scon.getId()];
        leaves= [Select Employee__r.id,Employee__r.name, name, Employee__r.First_Name__c, From_Date__c, To_Date__c,Status__c from Leave__c where Employee__r.id= 'a017F00000Cq3On'];
    }
}