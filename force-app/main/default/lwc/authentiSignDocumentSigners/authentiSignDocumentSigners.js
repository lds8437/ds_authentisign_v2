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

  get opportunityName() {
    return this.allData?.opportunity?.Name || '';
  }

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
    const objSigner = { data: {}, txtRoleId: this.getName('txtRole', 0), ddlUserContactId: this.getName('ddlUserContact', 0), btnDeleteId: this.getName('btnDelete', 0) };
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

  handleRoleChange(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    const signers = [...this.signers];
    signers[index].data.Role = event.detail.value || '';
    this.signers = signers;
  }

  handleUserContactddl(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    const fieldName = event.detail.value;
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
    const index = this.signers.length;
    this.signers = [...this.signers, {
      data: { Role: '', Name: '', Email: '', FirstName: '', Id: '', LastName: '', Type: '' },
      txtRoleId: this.getName('txtRole', index),
      ddlUserContactId: this.getName('ddlUserContact', index),
      btnDeleteId: this.getName('btnDelete', index)
    }];
  }

  deleteSigner(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    this.signers = this.signers.filter((_, i) => i !== index);
  }

  getName(prefix, index) {
    if (typeof index !== 'number' || isNaN(index) || index < 0) {
      console.warn(`Invalid index in getName: ${index}, using fallback`);
      return `${prefix}-0`;
    }
    const name = `${prefix}-${index}`;
    console.log(`Generated data-id: ${name}`);
    return name.replace(/[^a-zA-Z0-9-_]/g, '');
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
      const requestString = JSON.stringify(signers.map(signer => signer.data));
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
        this.showToast('Error', result.result.replace(/[()]/g, ''), 'error');
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