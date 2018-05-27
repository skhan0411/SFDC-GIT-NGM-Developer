public class AddMultipleExpense {
  
    
   public Account thisAccount {get;set;}
    public list<Expense__c> expenses {get;set;}
    public Expense__c newExpense {get;set;}
    
    public AddMultipleExpense(ApexPages.StandardController scon){
        //thisAccount = new Account();
        //thisAccount.id= ApexPages.currentPage().getParameters().get('id');
        thisAccount= [select id, name, (select id, amount__c,reimbursed__c, date__c from Expenses__r order by reimbursed__c desc) from Account where id=:scon.getId()];
        expenses = thisAccount.expenses__r;

    }
    
    public void generateNewExpense(){
        
        newExpense= new Expense__c();
        newExpense.client__c=thisAccount.id;
    }
    
    public pagereference addExpense(){
        generateNewExpense();
        expenses.add(newExpense);
        return null;
    }
    
    public pagereference saveExpenses()
    {
        try{
            upsert expenses;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm, 'Expenses Saved'));
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
        }
        return null;
    }
}