import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLayouts from '@salesforce/apex/LayoutListCtrl.getLayouts';
import getLayoutMappings from '@salesforce/apex/LayoutListCtrl.getLayoutMappings';
import saveAttachment from '@salesforce/apex/LayoutListCtrl.saveAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AuthentiSignLayoutList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName = 'Opportunity';
    @track layouts = [];
    @track data = [];
    @track selectedRecord;
    @track savedLayoutId;
    @track signingStatus;
    @track attachmentId;
    @track documentAttachmentId;
    @track opportunity;
    @track selectedOption = 'document';
    @track radioOptions = [
        { label: 'Document', value: 'document' },
        { label: 'Layout', value: 'layout' }
    ];
    @track documents = [];
    @track selectedDocument;
    @track selectedDocumentName;
    @track documentSigningId;
    @track documentSigningStatus;
    @track documentSigningStatusMessage;
    @track documentSigningUrl;
    @track spinner = false;

    get isDocumentSelected() {
        return this.selectedOption === 'document';
    }

    get isDocumentDisabled() {
        return this.selectedDocument && this.documentSigningId;
    }

    get isDocumentSigned() {
        return this.documentSigningStatus === 'document signed';
    }

    get isLayoutSigned() {
        return this.signingStatus === 'document signed';
    }

    get btnStartClass() {
        return this.selectedRecord && this.selectedRecord !== '' ? 'slds-button slds-button_brand' : 'slds-button slds-button_brand slds-hide';
    }

    get btnStartDocumentClass() {
        return this.selectedDocument && this.selectedDocument !== '' ? 'slds-button slds-button_brand' : 'slds-button slds-button_brand slds-hide';
    }

    connectedCallback() {
        this.init();
    }

    async init() {
        try {
            this.spinner = true;
            const result = await getLayouts({ recordId: this.recordId, objectName: this.objectApiName });
            console.log('getLayouts result:', result);

            this.data = result.wrapper || [];
            this.layouts = [{ label: 'Select Layout', value: '' }, ...result.wrapper.map(item => ({ label: item.name, value: item.id }))];
            this.selectedRecord = result.opportunity?.Layout_Id__c;
            this.savedLayoutId = result.opportunity?.Layout_Id__c;
            this.signingStatus = result.signingStatus;
            this.documentSigningStatus = result.documentSigningStatus;
            this.attachmentId = result.opportunity?.AttachmentId__c;
            this.documentAttachmentId = result.opportunity?.Document_Attachment_Id__c;
            this.opportunity = result.opportunity;

            this.populateDocuments(result.documents, result.opportunity?.Document_Id__c, result.opportunity?.Document_Signing_Id__c);
        } catch (error) {
            console.error('Error in init:', error);
            this.showToast('Error', error.body?.message || 'Unknown error', 'error');
        } finally {
            this.spinner = false;
        }
    }

    populateDocuments(documents, docId, docSigningId) {
        const docs = [{ label: 'Select Document', value: '' }];
        Object.keys(documents).forEach(key => {
            docs.push({ label: key, value: documents[key] });
        });
        this.documents = docs;

        setTimeout(() => {
            this.selectedDocument = docId;
            this.documentSigningId = docSigningId;
        }, 100);
    }

    handleChangeRadio(event) {
        this.selectedOption = event.detail.value;
        console.log('Selected Option:', this.selectedOption);
    }

    handleChangeDocument(event) {
        this.selectedDocument = event.detail.value;
        const record = this.documents.find(doc => doc.value === this.selectedDocument);
        this.selectedDocumentName = record ? record.label : '';
    }

    handleLayoutChange(event) {
        this.selectedRecord = event.detail.value;
        console.log('layoutId:', this.selectedRecord);
    }

    async navigateToMappings() {
        try {
            const mappings = await getLayoutMappings({ layoutId: this.selectedRecord, objectName: this.objectApiName });
            console.log('Mappings:', mappings);

            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__authentiSignMappingLayout'
                },
                state: {
                    c__layouts: JSON.stringify(this.data),
                    c__opportunityId: this.recordId,
                    c__layoutId: this.selectedRecord,
                    c__mappings: JSON.stringify(mappings),
                    c__objectName: this.objectApiName
                }
            });
        } catch (error) {
            console.error('Error in navigateToMappings:', error);
            this.showToast('Error', error.body?.message || 'Unknown error', 'error');
        }
    }

    navigateToSigners() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__authentiSignDocumentSigners'
            },
            state: {
                c__opportunityId: this.recordId,
                c__documentId: this.selectedDocument,
                c__documentName: this.selectedDocumentName,
                c__objectName: this.objectApiName
            }
        });
    }

    async displayPdf() {
        if (this.attachmentId) {
            window.open(`/servlet/servlet.FileDownload?file=${this.attachmentId}`, '_blank');
        } else {
            await this.saveAttachment(true);
        }
    }

    async displayPdfDocument() {
        if (this.documentAttachmentId) {
            window.open(`/servlet/servlet.FileDownload?file=${this.documentAttachmentId}`, '_blank');
        } else {
            await this.saveAttachment(false);
        }
    }

    async saveAttachment(isLayout) {
        this.spinner = true;
        try {
            const params = {
                opportunityId: this.opportunity?.Id,
                signingId: isLayout ? this.opportunity?.Signing_Id__c : this.opportunity?.Document_Signing_Id__c,
                objectName: this.objectApiName,
                isLayout
            };
            const attachmentId = await saveAttachment(params);
            if (attachmentId) {
                if (isLayout) {
                    this.attachmentId = attachmentId;
                } else {
                    this.documentAttachmentId = attachmentId;
                }
                this.dispatchEvent(new CustomEvent('force:refreshView'));
                window.open(`/servlet/servlet.FileDownload?file=${attachmentId}`, '_blank');
            }
        } catch (error) {
            console.error('Error in saveAttachment:', error);
            this.showToast('Error', error.body?.message || 'Unknown error', 'error');
        } finally {
            this.spinner = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}