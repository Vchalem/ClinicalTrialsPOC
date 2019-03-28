public class CT_ClinicalTrialUtil {
    
    // Wrapper class to hold the weather in the format we want
    public class Trial {
        public String nci_id { get; set; }           // trial.nci_id
        public String brief_title { get; set; }        // trial.brief_title
        public String brief_summary { get; set; }      // trial.brief_summary
        public String brief_title_abbr { get; set; }
        
        public Trial(String idString, String titleString, String summaryString, String titleAbbrString) {
            nci_id = idString;
            brief_title = titleString;
            brief_title_abbr = titleAbbrString;
            brief_summary = summaryString;
        }
    }
    
    // Query the record to get input parameters, result to be used in Lightning Components (record based view)
    @AuraEnabled(cacheable=true)
    public static String getTrialsForContact(Id recordId) {

        // Input parameters, to get from Contact record
        String state = '';
        String gender = '';
        String result = '';
        
        // Output parameters, as list of returned trials
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
            result = makeCallout(state,gender,trials);
        }

        // Return the serialized trial wrapper class, or null
        String out = result.equalsIgnoreCase('success!') ? JSON.serialize(trials) : null;
        System.debug('Output: ' + out);
        return out;
    }
    
    // Method to perform callout, using state and gender as input
    public static String makeCallout(String state, String gender, List<CT_ClinicalTrialUtil.Trial> trials){
        
        // Define the response to send to caller
        String outcomeMsg;
        
        // Define basic information (could move this to protected custom settings)
        String endpoint = 'https://clinicaltrialsapi.cancer.gov'; // add to "Remote Site Settings"
        String resource = '/v1/clinical-trials?';
        String filter = 'current_trial_status=active&sites.org_state_or_province=' + state + '&eligibility.structured.gender=' + gender;
        String inclusions = '&include=nci_id&include=brief_title&include=brief_summary&include=primary_purpose.primary_purpose_code';
        
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
                        
                        // Parse entire JSON response.
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            // Start at the array of trials.
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != null) {
                                    // Advance to the start object marker to
                                    //  find next invoice statement object.
                                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                        // Read entire invoice object, including its array of line items.
                                        Trial trial = (CT_ClinicalTrialUtil.Trial)parser.readValueAs(CT_ClinicalTrialUtil.Trial.class);
                                        system.debug('Trial id: ' + trial.nci_id);

                                        // Create a shorter version of the title, for display
                                        trial.brief_title_abbr = trial.brief_title.abbreviate(20);

                                        // For debugging purposes, serialize again to verify what was parsed.
                                        String s = JSON.serialize(trial);
                                        system.debug('Serialized trial: ' + s);
                    
                                        // Skip the child start array and start object markers.
                                        parser.skipChildren();
                                        trials.add(trial);
                                    }
                                }
                            }
                        }                  
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
    
}