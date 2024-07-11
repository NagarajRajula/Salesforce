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

        Map<String, Contact> conMap = new Map<String, Contact>();
        List<Contact> contInsertList = new List<Contact>();
        List<Contact> contUpdateList = new List<Contact>();
        List<Account> acList = new List<Account>();
        
        for(Account a : [Select Id,Name,Rating, Description, AccountNumber From Account]){
            if(a.AccountNumber == ac.AccountNumber){
                Account ac1 = new Account(
                    Id = a.Id,
                    Name = ac.Name,
                    Rating = ac.Rating,
                    Description = ac.Description
                );
                acList.add(ac1);
            }
        }
        
        for(Contact c : [SELECT Id,FirstName, LastName, Email, AccountId FROM Contact]){
            conMap.put(c.Email, c);
        }
        
        for(Contact c: conList){
            if(conMap.containsKey(c.Email)){
                Contact con = new Contact(
                    Id = conMap.get(c.Email).Id,
                    FirstName = c.FirstName,
                    LastName = c.LastName,
                    Email = c.Email,
                    AccountId = acList[0].Id
                );
                contUpdateList.add(con);
            } else {
                Contact con = new Contact(
                    FirstName = c.FirstName,
                    LastName = c.LastName,
                    Email = c.Email,
                    AccountId = acList[0].Id
                );
                contInsertList.add(con);
            }
        }        
        
        RestResponse res = RestContext.Response;
        String insertedAccountText;
        
        try{
            if(acList.size() > 0){
                update acList;
            }
            else {
                insert ac;
                insertedAccountText = JSON.serialize(ac);
            }
            if(contUpdateList.size() > 0){
                update contUpdateList;} 
            if(contInsertList.size() > 0){
                insert contInsertList;
            }
            res.statuscode = 200;
            res.responsebody = Blob.valueOf('Update Account : '+ JSON.serialize(acList) +
                                            '\n Inserted Account: '+ insertedAccountText + 
                                            '\n Inserted Contacts:  '+ JSON.serialize(contInsertList) +
                                            '\n Updated Contacts:  '+ JSON.serialize(contUpdateList));
        } catch(Exception e){
            System.debug(LoggingLEVEL.Debug, 'Exception has occured while peforming DML '+e);
            res.statuscode = 300;
            res.responsebody = Blob.valueOf('Exception has occured while peforming DML '+e);
        }
    }
    
}
