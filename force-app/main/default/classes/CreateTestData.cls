public class CreateTestData {
    @AuraEnabled(cacheable=true)
    public static string getTestData(){
       
        //return title & ID
        return 'NCI-2017-01240';
    
    }

   

}