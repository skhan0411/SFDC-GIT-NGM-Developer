public with sharing class TriggerTrainingClass {
	
	public static void calculateExpense(List<Expense__c> expense)
	{
	
	for(Expense__c e : expense)
	{
	
	AggregateResult ar = [Select sum(amount__c)s from Expense__c where client__c= :e.client__c AND reimbursed__c=true ];
	
	decimal amount= double.valueof(ar.get('s'));
	
	Account obj= new Account(id=e.client__c);
	obj.Total_Reimbursed_Expenses__c=amount;
	update obj;
	}
	}
    
}