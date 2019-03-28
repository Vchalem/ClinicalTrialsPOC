import { LightningElement, track, api, wire } from 'lwc';
import getTrialsForContact from '@salesforce/apex/CT_ClinicalTrialUtil.getTrialsForContact';
import { NavigationMixin } from 'lightning/navigation';



export default class trialinfodisplay extends NavigationMixin(LightningElement) {
    @api recordId;
    @track trials;
    @track trialsString;
    @track url;
    @track selectedItem;
    @track url3;
 
   

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

    handleItemClicked(event) {
        this.selectedItem = event.target.dataset.item;
        var url2 = "https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=";
        var link = url2.concat(this.selectedItem);
        this.url=link;
    }

    navigateToWebPage(event) {
        // Navigate to a URL
        this.selectedItem = event.target.dataset.item;
        var url2 = "https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=";
        var link = url2.concat(this.selectedItem);
        this.url3="https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/trial-guide/detailschecklist.pdf";
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url3
            }
        });
    }

}