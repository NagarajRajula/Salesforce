/*
 * ClassName: RestExplorerPUT
 * Author: Nagaraju Rajula
 * Created on: 11-Jul-2024
 * Description: Class will be called from external systems, permforms only http PUT method.
 * Account: Check Account number if existing in Salesforce Accounts , if Yes, update the input data to related Account record, 
 * 		    if Not creates a new Account.
 * Contact: Accepts list of Contacts, check if Email value existing in all Salesforce Contacts, if Yes, 
 * 			update the input data to related contact record, if Not creates a new Contact.
 * Response -> Body: will be updated/ Created data
 * Sample input: {
                    "createOrUpdatePayload": {
                        "account": {
                            "Name": "Rajula PUT 1",
                            "Rating": "Warm",
                            "AccountNumber": "1234567811",
                            "Description": "Inbound integration inserting/updating account record."
                        },
                        "contacts": [
                            {
                                "FirstName": "PUT FirstName 1",
                                "LastName": "PUT  LastName 1",
                                "Email": "nagaraju.rajula1@gmail.com"
                            },
                            {
                                "FirstName": "PUT FirstName 2",
                                "LastName": "PUT LastName 2",
                                "Email": "nagaraju.rajula2@gmail.com"
                            }
                        ]
                    }
                }
 */
@RestResource(urlMapping='/Account/PUT/*')
global class RestExplorerPUT {
    
    global class responseWrapper{
        Account account;
        Contact[] contacts;
    }
    
    /*
     * PUT method
     * params: responseWrapper
     */
    @HttpPut
    global static void doPut(responseWrapper createOrUpdatePayload){
        
        Account ac = createOrUpdatePayload.account;
        Contact[] conList = createOrUpdatePayload.contacts;
        
        Boolean isAccountExists = false;
        Id accountId;
        
        Map<String, Account> acMap = new Map<String, Account>();
        Map<String, Contact> conMap = new Map<String, Contact>();
        Map<String, Boolean> conExistsCheck = new Map<String, Boolean>();
        List<Contact> contInsertList = new List<Contact>();
        List<Contact> contUpdateList = new List<Contact>();
        
        for(Account a : [Select Id,Name,Rating, Description, AccountNumber From Account]){
            acMap.put(a.AccountNumber, a);
            accountId = a.Id;
        }
        
        for(Contact c : [SELECT Id,FirstName, LastName, Email, AccountId FROM Contact]){
            conMap.put(c.Email, c);
        }
        
        if(acMap.containsKey(ac.AccountNumber)){
            isAccountExists = true;
        }
        
        for(Contact c: conList){
            if(conMap.containsKey(c.Email)){
                Contact con = new Contact(
                    Id = conMap.get(c.Email).Id,
                    FirstName = c.FirstName,
                    LastName = c.LastName,
                    Email = c.Email,
                    AccountId = accountId
                );
                contUpdateList.add(con);
            } else {
                Contact con = new Contact(
                    FirstName = c.FirstName,
                    LastName = c.LastName,
                    Email = c.Email,
                    AccountId = accountId
                );
                contInsertList.add(con);
            }
        }
        
        if(isAccountExists){
            if(ac.Name != acMap.get(ac.AccountNumber).Name){
                acMap.get(ac.AccountNumber).Name = ac.Name;
            } else if(ac.Rating != acMap.get(ac.AccountNumber).Rating){
                acMap.get(ac.AccountNumber).Rating = ac.Rating;
            }
        }
        
        
        RestResponse res = RestContext.Response;
        
        try{
            if(isAccountExists){
                update acMap.values();
            }
            else {
                insert ac;
            }
            if(contUpdateList.size() > 0){
                update contUpdateList;} 
            if(contInsertList.size() > 0){
                insert contInsertList;
            }
            res.statuscode = 200;
            res.responsebody = Blob.valueOf('Update Account : '+ JSON.serialize(acMap.get(ac.AccountNumber)) +
                                            '\n Inserted Account: '+ JSON.serialize(ac) + 
                                            '\n Inserted Contacts:  '+ JSON.serialize(contInsertList) +
                                            '\n Updated Contacts:  '+ JSON.serialize(contUpdateList));
        } catch(Exception e){
            System.debug(LoggingLEVEL.Debug, 'Exception has occured while peforming DML '+e);
            res.statuscode = 300;
            res.responsebody = Blob.valueOf('Exception has occured while peforming DML '+e);
        }
    }
    
}
