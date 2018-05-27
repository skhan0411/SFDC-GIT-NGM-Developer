public with sharing class account_Method {
    
    public static void afterUpdate(list<Account> newlist, list<Account> oldlist){
        list<Account> needUpdatedTotalReimbursements= new list<Account>();
        for(integer i=0; i<newlist.size(); i++)
        {
            if(newlist[i].Total_Reimbursed_Expenses__c != oldlist[i].Total_Reimbursed_Expenses__c){
               // needUpdatedTotalReimbursements(newlist[i]);
            }
        }
        if(!needUpdatedTotalReimbursements.isEmpty()) {
            updatedAccountTotalReimbursements(needUpdatedTotalReimbursements);
        }
    }
    
    public static void updatedAccountTotalReimbursements(list<Account> scope){
        set<id> acctids= new set<id>();
        map<string, decimal> accountTotals= new map <string, decimal>();
        for(Account a: scope)acctids.add(a.id);
        list<AggregateResult> arlist=[select sum(amount__c) amount, client__c  from Expense__c where reimbursed__c=true AND client__c IN :acctids GROUP BY client__c];
            for(AggregateResult ar: arlist)
        {
           // accountTotals.put(string.valueof(ar.get('client__c')), decimal.valueof(ar.get('expr0')));
            
        }
        
        for(Account a: scope){
            a.Total_Reimbursed_Expenses__c= accountTotals.get(a.id);
        }
        update scope;
    }
    
}