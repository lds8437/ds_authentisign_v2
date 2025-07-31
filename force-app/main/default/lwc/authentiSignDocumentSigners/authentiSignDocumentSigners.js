import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllData from '@salesforce/apex/AuthentiSignMappingCtrl.getAllData';
import submitDocumentRequest from '@salesforce/apex/AuthentiSignMappingCtrl.submitDocumentRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AuthentiSignDocumentSigners extends NavigationMixin(LightningElement) {
    @api opportunityId;
    @api documentId;
    @api documentName;
    @api objectName = 'Opportunity';
    @track allData;
    @track usercontactfields = [];
    @track signers = [];
    @track showMessage = false;
    @track messageTitle;
    @track messageType;
    @track message;
    @track spinner = false;

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        this.spinner = true;
        try {
            const allData = await getAllData({ recordId: this.opportunityId, objectName: this.objectName });
            this.allData = allData;

            this.usercontactfields = [{ label: '--Select--', value: '' }, ...Object.keys(allData.usercontactfieldmap).map(fieldName => ({
                label: allData.opportunityFieldProps[fieldName].label,
                value: fieldName,
                lookupname: allData.usercontactfieldmap[fieldName]
            }))].sort((a, b) => a.label.localeCompare(b.label));

            this.addSignerByDefault(allData);
        } catch (error) {
            console.error('Error in doInit:', error);
            this.showToast('Error', error.body?.message || 'Unknown error', 'error');
        } finally {
            this.spinner = false;
        }
    }

    addSignerByDefault(allData) {
        const signers = [];
        const objSigner = { data: {} };
        const fieldName = 'ContactId';
        const lookupField = allData.usercontactfieldmap[fieldName];
        const opportunityRecord = allData.opportunity[lookupField];

        if (opportunityRecord) {
            objSigner.data = { ...opportunityRecord, fieldName };
            const participientFields = allData.participientFields[lookupField];
            let objectType = participientFields[participientFields.length - 1].replace(/[()]/g, '');
            objectType = objectType.includes('User') ? 'User' : objectType;
            objSigner.data.Type = objectType;
        }
        objSigner.data.Role = 'Signer 1';
        signers.push(objSigner);
        this.signers = signers;
    }

    handleUserContactddl(event) {
        const fieldName = event.detail.value;
        const nameAttr = event.detail.name;
        const index = parseInt(nameAttr.split('-')[1]);
        const allData = this.allData;
        const lookupField = allData.usercontactfieldmap[fieldName];
        const opportunityRecord = allData.opportunity[lookupField];

        const signers = [...this.signers];
        const signer = signers[index];

        if (opportunityRecord) {
            signer.data = { ...opportunityRecord, fieldName };
            const participientFields = allData.participientFields[lookupField];
            let objectType = participientFields[participientFields.length - 1].replace(/[()]/g, '');
            objectType = objectType.includes('User') ? 'User' : objectType;
            signer.data.Type = objectType;
        } else {
            signer.data = { Role: '', Name: '', Email: '', FirstName: '', Id: '', LastName: '', Type: '', fieldName };
        }
        this.signers = signers;
    }

    addSigner() {
        this.signers = [...this.signers, {
            data: { Role: '', Name: '', Email: '', FirstName: '', Id: '', LastName: '', Type: '' }
        }];
    }

    deleteSigner(event) {
        const index = parseInt(event.target.name.split('-')[1]);
        this.signers = this.signers.filter((_, i) => i !== index);
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: this.objectName,
                actionName: 'view'
            }
        });
    }

    async createRequest() {
        this.spinner = true;
        const signers = this.signers;
        let errorMessage = '';

        if (signers.length === 0) {
            errorMessage = 'No signer added, please add signers.';
        } else {
            signers.forEach(signer => {
                if (!signer.data.Id) {
                    errorMessage += 'Please select valid User/Contact\n';
                }
                if (!signer.data.Role) {
                    errorMessage += 'Please add the role of signer\n';
                }
            });
        }

        if (errorMessage) {
            this.spinner = false;
            this.showToast('Error', errorMessage, 'error');
            return;
        }

        try {
            const requestString = JSON.stringify(signers);
            const result = await submitDocumentRequest({
                requestString,
                opportunityId: this.allData.opportunity.Id,
                opportunityName: this.allData.opportunity.Name,
                documentId: this.documentId,
                documentName: this.documentName,
                objectName: this.objectName
            });

            if (result?.status === 'success') {
                this.showToast('Success', 'Signing submitted successfully.', 'success');
                setTimeout(() => this.handleBack(), 2000);
            } else if (result?.status?.startsWith('error')) {
                this.showToast('Error', result.result.replace(/[{}]/g, ''), 'error');
            } else {
                this.showToast('Error', 'Something went wrong, please contact System Administrator.', 'error');
            }
        } catch (error) {
            console.error('Error in createRequest:', error);
            this.showToast('Error', error.body?.message || 'Unknown error', 'error');
        } finally {
            this.spinner = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}