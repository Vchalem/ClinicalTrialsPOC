import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Contact.Name',
    'Contact.Email',
    'Contact.HealthCloudGA__Gender__c',
    'Contact.HealthCloudGA__Age__c',
    'Contact.MailingAddress' //state

];


export default class trialinfodisplay extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    contact;

    //send recordID to callout 
    //do call to apx class - 
    //return to apx class the test data to display

//url concatenate
//https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=  NCI-2017-01240




}