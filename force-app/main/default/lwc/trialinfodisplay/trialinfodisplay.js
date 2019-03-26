import { LightningElement, track, api, wire } from 'lwc';
import getTrialsForContact from '@salesforce/apex/CT_ClinicalTrialUtil.getTrialsForContact';
import { NavigationMixin } from 'lightning/navigation';



export default class trialinfodisplay extends NavigationMixin(LightningElement) {
    @api recordId;
    @track trials;
    @track trialsString;
 
   

    //when LWC loads - call apx class w/ contact ID
    @wire(getTrialsForContact, {recordId: '$recordId'})
    wiredContact({ error, data }) {
        if (data) {
            this.trialsString = data;
            this.trials=JSON.parse(this.trialsString);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.trialsString = undefined;
            this.trials=undefined
        }
    }

    
    url = 'https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=';

    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: "salesforce.com"
            }
        },
       );
    }

 

    
}


    
    //idReturned({ error, data }) {


        // if (data){
          //  this.NCI = data;
           // this.error=undefined;
        //}else if (error){
          //  this.error=error;
          //  this.NCI=undefined;
        //}
   // }      

    
    
    
    //get url(){
      //  var url = "https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=";
       // var link = url.concat(this.NCI);
        //return link;
   // }

    //handleLoad(){
        //will be an action unto a flow screen...
    //}

