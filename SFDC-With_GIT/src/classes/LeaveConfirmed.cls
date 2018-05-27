public with sharing class LeaveConfirmed {
    
    
    public static void totalConfirmedLeaves(List<Employee_Leave_Account__c> leave)
    {
    for(Employee_Leave_Account__c e: leave){
    
    AggregateResult ar = [select sum(Leaves_To_be_Added__c) EmpLeave from Employee_Leave_Account__c where EmployeeName__c= :e.EmployeeName__c AND isLeaveConfirmed__c =true];
    
    
    decimal value = double.valueof(ar.get('EmpLeave'));
    
    Employee__c obj = new Employee__c(id=e.EmployeeName__c);
    obj.Total_confirmed_leaves__c=value;
    update obj;
    
    }
    }
}