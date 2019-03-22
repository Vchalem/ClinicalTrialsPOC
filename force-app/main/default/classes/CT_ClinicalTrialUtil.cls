public class CT_ClinicalTrialUtil {
    
    // Wrapper class to hold the weather in the format we want
    public class Trial {
        public String title { get; set; }        // trial.brief_title
        public String summary { get; set; }      // trial.brief_summary
        public String purpose { get; set; }      // trial.primary_purpose.primary_purpose_code
    }
    
    // Query the record to get input parameters, result to be used in Lightning Components (record based view)
    @AuraEnabled
    public static String getTrialsForContact(Id recordId) {

        // Input parameters, to get from Contact record
        String state = '';
        String gender = '';
        String result = '';
        
        // Output parameters, as list of returned trials
        List<Object> trialObjects = new List<Object>();
        List<CT_ClinicalTrialUtil.Trial> trials = new List<CT_ClinicalTrialUtil.Trial>();
        
        // Compare the SObject type of the record Id to Contact
        if (recordId.getSobjectType() == Contact.SObjectType) {
            Contact c = [SELECT MailingAddress, HealthCloudGA__Gender__c FROM Contact WHERE Id = :recordId];
            
            // Access the compound address field MailingAddress
            Address addr = (Address)c.MailingAddress;
            if (null != addr) state = addr.getState();

            gender = c.HealthCloudGA__Gender__c;
            
        } else throw new System.SObjectException('Local trials not available for this record type');
        
        // Make the callout if we have a valid state and gender
        if (String.isNotBlank(state) && String.isNotBlank(gender)) {
            result = makeCallout(state,gender,trialObjects);
        }

        // Return the serialized trial wrapper class, or null
        return result.equalsIgnoreCase('success!') ? JSON.serialize(trialObjects) : null;
    }
    
    // Method to perform callout, using state and gender as input
    public static String makeCallout(String state, String gender, List<Object> trialObjects){
        
        // Define the response to send to caller
        String outcomeMsg;
        
        // Define basic information (could move this to protected custom settings)
        String endpoint = 'https://clinicaltrialsapi.cancer.gov'; // add to "Remote Site Settings"
        String resource = '/v1/clinical-trials?';
        String filter = 'sites.org_state_or_province=' + state + '&eligibility.structured.gender=' + gender;
        String inclusions = '&include=brief_title&include=brief_summary&include=primary_purpose.primary_purpose_code&include=eligibility.structured.min_age&include=eligibility.structured.max_age';

        String method = 'GET';  
        
        // Check to ensure a callout can be performed using the Limits class. 
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            outcomeMsg = 'Maximum number of callouts has been reached.';
        } else {
            // Define the request
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http h = new Http();
            
            // Configure the request and headers
            req.setEndpoint(endpoint + resource + filter + inclusions);
            req.setMethod(method);
            req.setTimeout(120000);          
            req.setHeader('Accept', '*/*');
            req.setHeader('Content-Type', 'application/json');
                        
            // Attempt the callout - create return error on exception
            try {
                
                // Perform callout and set response
                res = h.send(req);
                
                // check response 
                if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                    
                    System.debug('@@@');
                    System.debug(res.getBody());
                    
                    // Deserialize the JSON string into collections of primitive data types.
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
                    // Check results for expected key (trials)
                    if (results.containsKey('trials')) {
                        // The deserialized response contains the expected key!
                        outcomeMsg = 'Success!';
                        
                        // Cast the values in the 'trials' key as a list
                        List<Object> trials = (List<Object>) results.get('trials');  
                        
                        /*
                        trial = (CT_ClinicalTrialutil.Trial) JSON.deserializeStrict(response.getBody(), CT_ClinicalTrialutil.Trial.class);
                        */                              
                               
                    } else {
                        outcomeMsg = 'Error: Malformed response';
                    }
                } else {
                    // callout failed
                    outcomeMsg = 'Error: Callout failed. Review debug log for additional information.';
                }
                
            } catch (DMLexception e) {
                // Unexpected exceptions will be caught here, like a deserialization error.
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
            }
        }
        
        // Return the response
        return outcomeMsg;
    }
    
    // Method to perform callout, using state and gender as input
    public static String convertToTrials(List<Object> trialObjects, List<CT_ClinicalTrialUtil.Trial> trials){

        System.debug('Received the following trials:');
        for (Object trial: trials) {
            CT_ClinicalTrialUtil.Trial nextTrial = new CT_ClinicalTrialUtil.Trial();
            //nextTrial.title = trial.brief_title;
            //nextTrial.summary = trial.brief_summary;
            //nextTrial.purpose = trial.primary_purpose;
            System.debug(trial);
        }
        return 'Success';
    }                    
    
}