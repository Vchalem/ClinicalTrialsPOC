import { LightningElement, track, api, wire } from 'lwc';
//import getTestData from '@salesforce/apex/CreateTestData.getTestData';
import getTrialsForContact from '@salesforce/apex/CT_ClinicalTrialUtil.getTrialsForContact';



export default class trialinfodisplay extends LightningElement {
    @api recordId;
    @track NCI;
    @track recId = ' ';

 
    //when LWC loads - call apx class w/ contact ID
    @wire(getTrialsForContact, {recordId: '$recordId'})
    wiredContact({ error, data }) {
        if (data) {
            this.NCI = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.NCI = undefined;
        }
    }

    get stringJson(){
        return this.wiredContact.data;
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

