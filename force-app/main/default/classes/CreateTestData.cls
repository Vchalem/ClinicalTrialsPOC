public class CreateTestData {
    @AuraEnabled(cacheable=true)
    public static Id getTestData(Id recordId){ //add params..
       
        //query for contact 
        Contact c = [SELECT Id, HealthCloudGA__Gender__c FROM Contact WHERE Id =:recordId LIMIT 1];
    
        //return c.HealthCloudGA__Gender__c;

        return c.Id;

        //return title & ID
        //return 'NCI-2017-01240';
    
    }

   

}