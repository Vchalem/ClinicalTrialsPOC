import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getTestData from '@salesforce/apex/CreateTestData.getTestData';

const FIELDS = [
    //contact fields that are being queried
    'Contact.Name',
    'Contact.Email',
    'Contact.HealthCloudGA__Gender__c',
    'Contact.HealthCloudGA__Age__c',
   // 'Contact.MailingAddress' //state

];


export default class trialinfodisplay extends LightningElement {
    @api recordId;
    @track NCI;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    contact;

    //call out with contact ID

    //return apex class with data --
    @wire(getTestData)
    idReturned({ error, data }) {
        if (data){
            this.NCI = data;
            this.error=undefined;
        }else if (error){
            this.error=error;
            this.NCI=undefined;
        }
    }      
    
    
    get url(){
        var url = "https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=";
        var link = url.concat(this.NCI);
        return link;
    }

    handleLoad(){
        //will be an action unto a flow screen...
    }

}