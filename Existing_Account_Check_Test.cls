@isTest
public class Existing_Account_Check_Test {
	
    static testmethod void test1(){
        
        Account Ac = new Account();
        Ac.name = 'test 1';
        insert Ac;
        
        Account Ac1 = new Account();
        Ac1.Name = 'Test 6';
        insert Ac1;
     
    }
}