import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLayouts from '@salesforce/apex/LayoutListCtrl.getLayouts';
import getLayoutMappings from '@salesforce/apex/LayoutListCtrl.getLayoutMappings';
import saveAttachment from '@salesforce/apex/LayoutListCtrl.saveAttachment';
import createLayout from '@salesforce/apex/LayoutListCtrl.createLayout';
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
    @track showModal = false;
    @track templateName = '';
    @track layoutId = '';

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

    get modalClass() {
        return this.showModal ? 'slds-modal slds-fade-in-open' : 'slds-modal';
    }

    get backdropClass() {
        return this.showModal ? 'slds-backdrop slds-backdrop_open' : 'slds-backdrop';
    }

    get isSubmitDisabled() {
        return !this.templateName || this.templateName.trim() === '' || this.spinner;
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
            if (!this.selectedRecord) {
                this.showToast('Error', 'Please select a layout before proceeding.', 'error');
                return;
            }

            this.spinner = true;
            console.log('Navigating to authentiSignMappingLayout with layoutId:', this.selectedRecord);

            const mappings = await getLayoutMappings({ layoutId: this.selectedRecord, objectName: this.objectApiName });
            console.log('getLayoutMappings result:', mappings);

            const state = {
                c__opportunityId: this.recordId,
                c__layoutId: this.selectedRecord,
                c__objectName: this.objectApiName,
                c__mappings: mappings
            };

            console.log('Navigation state:', state);

            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__authentiSignMappingLayout'
                },
                state
            });
        } catch (error) {
            console.error('Error in navigateToMappings:', error);
            let errorMessage = 'Failed to navigate to mapping layout';
            if (error.body?.message) {
                errorMessage += `: ${error.body.message}`;
            } else if (error.message) {
                errorMessage += `: ${error.message}`;
            }
            this.showToast('Error', errorMessage, 'error');
        } finally {
            this.spinner = false;
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

    handleCreateTemplateClick(event) {
        console.log('Create New Template icon clicked at:', new Date().toISOString());
        console.log('Event details:', event);
        this.showModal = true;
        this.layoutId = ''; // Reset layoutId when opening modal
        console.log('showModal set to:', this.showModal);
    }

    handleCloseModal() {
        console.log('Closing modal');
        this.showModal = false;
        this.templateName = '';
        this.layoutId = '';
    }

    handleTemplateNameChange(event) {
        this.templateName = event.detail.value;
        console.log('Template name updated:', this.templateName);
    }

    async handleSubmitTemplate() {
        if (!this.templateName || this.templateName.trim() === '') {
            this.showToast('Error', 'Please enter a template name.', 'error');
            return;
        }

        this.spinner = true;
        try {
            console.log('Submitting template:', this.templateName);
            const layoutId = await createLayout({ templateName: this.templateName });
            console.log('Layout ID received:', layoutId);
            this.layoutId = layoutId;
            this.showToast('Success', `Template "${this.templateName}" created with ID: ${layoutId}`, 'success');
            // Keep modal open to display layoutId
        } catch (error) {
            console.error('Error in handleSubmitTemplate:', JSON.stringify(error));
            let errorMessage = 'Failed to create template.';
            if (error.body && error.body.message) {
                errorMessage = error.body.message;
                console.error('Apex error message:', errorMessage);
            } else if (error.message) {
                errorMessage = error.message;
            }
            this.showToast('Error', errorMessage, 'error');
        } finally {
            this.spinner = false;
        }
    }
}