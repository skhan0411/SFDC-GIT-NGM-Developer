public with sharing class LeadController {
    
    public string searchstring {get;set;} 
    public List<Lead> records {get; set;} 
    public LeadController(){ 
        records = [select Name, Lead.street,Lead.city, Lead.state,Lead.country, Phone, Status from Lead]; 
        
    } 
    public void Search(){ 
        System.debug('********************searchstring***********************'+searchstring);
         String searchstring = Apexpages.currentPage().getParameters().get('searchstring');
        string searchquery=null;
         if(searchstring!=null){
             searchquery='select Name, Lead.street,Lead.city, Lead.state,Lead.country, Phone, Status from Lead where Lead.street like \'%'+searchstring+'%\' OR Lead.city like \'%'+searchstring+'%\' OR Lead.state like \'%'+searchstring+'%\'OR Lead.country like \'%'+searchstring+'%\''; 
        }
        else{
             searchquery='select Name, Lead.street,Lead.city, Lead.state,Lead.country, Phone, Status from Lead'; 
        }
        
        records= Database.query(searchquery); 
    }
    
}