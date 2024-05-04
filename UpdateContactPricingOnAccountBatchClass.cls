/**
 * @description : Batch class to process Sum of Pricing of related Contacts of each Account
 * Create these Total_Contacts_Pricing__c(Account obj) and Pricing__c(Contact obj) two fields 
 * Created date: 05/04/2024
 * Author: Nagaraju Rajula
 */
public class UpdateContactPricingOnAccountBatchClass implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,Total_Contacts_Pricing__c FROM Account');
    }
    public static void execute(Database.BatchableContext bc, List<SObject> scope){
        Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Total_Contacts_Pricing__c FROM Account WHERE Id = :scope]);
        Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, AccountId, Pricing__c FROM Contact WHERE AccountId =: scope]);
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        for(Id contId:contMap.keySet()){
            Decimal sum = 0;
            if(acctMap.ContainsKey(contMap.get(contId).AccountId) 
               && (contMap.get(contId).Pricing__c != NULL  || contMap.get(contId).Pricing__c > 0 ))
               {
                if(sumMap.ContainsKey(contMap.get(contId).AccountId)){
                    sum = sumMap.get(contMap.get(contId).AccountId) + contMap.get(contId).Pricing__c;
                    sumMap.put(contMap.get(contId).AccountId, sum);
                }else {
                    sumMap.put(contMap.get(contId).AccountId, contMap.get(contId).Pricing__c);
                }
            }
        }
        for(Id acctId: acctMap.keySet()){
            acctMap.get(acctId).Total_Contacts_Pricing__c = sumMap.get(acctId);
        }
        
        try {
            update acctMap.values();
        } catch (Exception e) {
            System.debug('An Error has been occured while updating the batch: '+e);
        }
        
    }
    public void finish(Database.BatchableContext bc){
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
                          FROM AsyncApexJob
                          WHERE Id = :bc.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject(' Account Pricing update has been completed ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}
