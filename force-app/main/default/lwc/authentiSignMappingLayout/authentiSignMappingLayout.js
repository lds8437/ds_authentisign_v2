import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllData from '@salesforce/apex/AuthentiSignMappingCtrl.getAllData';
import fillandSubmit from '@salesforce/apex/AuthentiSignMappingCtrl.fillandSubmit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AuthentiSignMappingLayout extends NavigationMixin(LightningElement) {
  @api layouts;
  @api opportunityId;
  @api layoutId;
  @api mappings;
  @api objectName = 'Opportunity';
  @track allData;
  @track fields = [];
  @track selectedLayout;
  @track opportunityFields = [];
  @track opportunityLineItemFields = [];
  @track lineItemRecords = [];
  @track roles = [];
  @track usercontactfields = [];
  @track lineItemId = '';
  @track lineItemField = '';
  @track expirationDate;
  @track spinner = false;

  get opportunityName() {
    return this.allData?.opportunity?.Name || '';
  }

  get selectedLayoutName() {
    return this.selectedLayout?.name || '';
  }

  connectedCallback() {
    this.doInit();
  }

  async doInit() {
    this.spinner = true;
    try {
      const layouts = JSON.parse(this.layouts || '[]');
      this.selectedLayout = layouts.find(x => x.id === this.layoutId);
      this.fields = (this.selectedLayout?.fields || []).map((field, index) => ({
        field,
        chkQuoteLIId: this.getName('chkQuoteLI', index),
        ddlSFQuoteFieldId: this.getName('ddlSFQuoteField', index),
        ddlLineItemsId: this.getName('ddlLineItems', index),
        ddlSFQuoteLineItemFieldId: this.getName('ddlSFQuoteLineItemField', index),
        txtQuoteFieldValueId: this.getName('txtquotefieldvalue', index),
        lineItemClass: 'slds-hide',
        fieldValue: ''
      }));
      this.roles = (this.selectedLayout?.layoutParticipants || []).map((p, index) => ({
        name: p.role,
        value: p.role,
        data: {},
        fieldName: '',
        ddlUserContactId: this.getName('ddlUserContact', index)
      }));

      const allData = await getAllData({ recordId: this.opportunityId, objectName: this.objectName });
      this.allData = allData;

      this.opportunityFields = [{ label: '--Select--', value: '' }, ...Object.keys(allData.opportunityFieldProps).map(fieldName => {
        const fieldProps = allData.opportunityFieldProps[fieldName];
        const rec = { label: fieldProps.label, value: fieldName };
        if (fieldProps.type.includes('REFERENCE')) {
          const lookupFieldName = fieldProps.custom === 'true' ? fieldName.replace('__c', '__r') : fieldName.replace(/Id/g, '');
          return [{ label: fieldProps.label, value: fieldName }, { label: `${fieldProps.label} > Name`, value: lookupFieldName, data: null }];
        }
        return rec;
      }).flat()].sort((a, b) => a.label.localeCompare(b.label));

      this.usercontactfields = [{ label: '--Select--', value: '' }, ...Object.keys(allData.usercontactfieldmap).map(fieldName => ({
        label: allData.opportunityFieldProps[fieldName].label,
        value: fieldName,
        lookupname: allData.usercontactfieldmap[fieldName]
      }))].sort((a, b) => a.label.localeCompare(b.label));

      this.opportunityLineItemFields = [{ label: '--Select--', value: '' }, ...Object.keys(allData.opportunityLineItemFieldProps).map(fieldName => {
        const fieldProps = allData.opportunityLineItemFieldProps[fieldName];
        const rec = { label: fieldProps.label, value: fieldName };
        if (fieldProps.type.includes('REFERENCE')) {
          const lookupFieldName = fieldProps.custom === 'true' ? fieldName.replace('__c', '__r') : fieldName.replace(/Id/g, '');
          return [{ label: fieldProps.label, value: fieldName }, { label: `${fieldProps.label} > Name`, value: lookupFieldName }];
        }
        return rec;
      }).flat()].sort((a, b) => a.label.localeCompare(b.label));

      this.lineItemRecords = [{ label: '--Select--', value: '' }, ...allData.opportunityLineItems.map(item => ({
        label: item.OpportunityLineItem?.Product2?.Name || item.Name,
        value: item.Id
      }))].sort((a, b) => a.label.localeCompare(b.label));

      this.expirationDate = allData.opportunity?.CloseDate;

      if (this.mappings) {
        setTimeout(() => this.populateFieldsValue(this.mappings), 500);
      }
    } catch (error) {
      console.error('Error in doInit:', error);
      this.showToast('Error', error.body?.message || 'Unknown error', 'error');
    } finally {
      this.spinner = false;
    }
  }

  populateFieldsValue(mappings) {
    const objMappings = JSON.parse(mappings || '{}');
    const updatedFields = this.fields.map((fieldObj, index) => {
      const mapping = objMappings.fieldsMap?.[fieldObj.field];
      let lineItemClass = 'slds-hide';
      let fieldValue = '';
      if (mapping) {
        if (mapping.object === 'lineitem') {
          lineItemClass = 'slds-show';
          this.lineItemId = mapping.lineItemId;
          this.lineItemField = mapping.field;
          fieldValue = this.handleChangeQuoteLineItemddl({ detail: { value: mapping.lineItemId, id: fieldObj.ddlLineItemsId } });
        } else {
          fieldValue = this.handleChangeQuoteddl({ detail: { value: mapping.field, id: fieldObj.ddlSFQuoteFieldId } });
        }
      }
      return { ...fieldObj, lineItemClass, fieldValue };
    });
    this.fields = updatedFields;

    const ddlUserContacts = this.template.querySelectorAll('[data-id^=ddlUserContact-]');
    const updatedRoles = this.roles.map(role => {
      const mapping = objMappings.rolesMap?.[role.name];
      let fieldName = '';
      if (mapping) {
        fieldName = mapping;
        const ddl = Array.from(ddlUserContacts).find(d => d.title === role.name);
        if (ddl) {
          ddl.value = mapping;
          this.handleUserContactddl({ detail: { value: mapping, id: role.ddlUserContactId } });
        }
      }
      return { ...role, fieldName };
    });
    this.roles = updatedRoles;
  }

  isChecked(isChecked, index) {
    const fieldObj = this.fields[index];
    const ddlQuotes = this.template.querySelector(`[data-id="${fieldObj.ddlSFQuoteFieldId}"]`);
    const ddlLineItems = this.template.querySelector(`[data-id="${fieldObj.ddlLineItemsId}"]`);
    const ddlQuoteLineItems = this.template.querySelector(`[data-id="${fieldObj.ddlSFQuoteLineItemFieldId}"]`);
    const txtField = this.template.querySelector(`[data-id="${fieldObj.txtQuoteFieldValueId}"]`);

    ddlQuotes.classList.toggle('slds-hide', isChecked);
    ddlLineItems.classList.toggle('slds-hide', !isChecked);
    ddlQuoteLineItems.classList.toggle('slds-hide', !isChecked);
    if (!isChecked) {
      ddlQuotes.value = '';
      ddlLineItems.value = '';
      ddlQuoteLineItems.value = '';
      txtField.value = '';
      this.lineItemField = '';
      this.lineItemId = '';
    }
    const updatedFields = [...this.fields];
    updatedFields[index] = { ...fieldObj, lineItemClass: isChecked ? 'slds-show' : 'slds-hide', fieldValue: '' };
    this.fields = updatedFields;
  }

  handleChangeQuoteddl(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    const value = event.detail.value;
    const fieldObj = this.fields[index];
    const txtControl = this.template.querySelector(`[data-id="${fieldObj.txtQuoteFieldValueId}"]`);
    const fieldValue = this.allData.opportunity[value] || (this.allData.opportunity[value]?.Name || '');
    txtControl.value = fieldValue;
    const updatedFields = [...this.fields];
    updatedFields[index] = { ...fieldObj, fieldValue };
    this.fields = updatedFields;
    return fieldValue;
  }

  handleChangeQuoteLineItemddl(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    const fieldObj = this.fields[index];
    const txtControl = this.template.querySelector(`[data-id="${fieldObj.txtQuoteFieldValueId}"]`);
    const id = event.target.dataset.id;

    if (id.includes('ddlLineItems')) {
      this.lineItemId = event.detail.value;
    } else if (id.includes('ddlSFQuoteLineItemField')) {
      this.lineItemField = event.detail.value;
    }

    let fieldValue = '';
    if (this.lineItemField && this.lineItemId) {
      const lineItemRecord = this.allData.opportunityLineItems.find(x => x.Id === this.lineItemId);
      fieldValue = lineItemRecord?.[this.lineItemField] || (lineItemRecord?.[this.lineItemField]?.Name || '');
      txtControl.value = fieldValue;
    } else {
      txtControl.value = '';
    }
    const updatedFields = [...this.fields];
    updatedFields[index] = { ...fieldObj, fieldValue };
    this.fields = updatedFields;
    return fieldValue;
  }

  handleUserContactddl(event) {
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    const fieldName = event.detail.value;
    const lookupField = this.allData.usercontactfieldmap[fieldName];
    const opportunityRecord = this.allData.opportunity[lookupField];

    const roles = [...this.roles];
    const role = roles[index];

    role.fieldName = fieldName || '';
    if (opportunityRecord) {
      role.data = { ...opportunityRecord };
      const participientFields = this.allData.participientFields[lookupField];
      let objectType = participientFields[participientFields.length - 1].replace(/[()]/g, '');
      objectType = objectType.includes('User') ? 'User' : objectType;
      role.data.Type = objectType;
    } else {
      role.data = { Name: '', Email: '', FirstName: '', Id: '', LastName: '', Type: '' };
    }
    this.roles = roles;
  }

  chkQuoteLIChange(event) {
    const isChecked = event.target.checked;
    const index = parseInt(event.target.dataset.id.split('-')[1]);
    this.isChecked(isChecked, index);
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
    const listErrors = [];

    if (!this.expirationDate) {
      listErrors.push('* Expiration date is not provided');
    }

    const ddlUserContacts = this.template.querySelectorAll('[data-id^=ddlUserContact-]');
    const hasUserContactValue = Array.from(ddlUserContacts).some(ddl => ddl.value);
    if (!hasUserContactValue) {
      listErrors.push('* Please select user/contact value in participants');
    }

    if (listErrors.length > 0) {
      this.spinner = false;
      this.showToast('Fix error(s)!', listErrors.join('\n'), 'error');
      return;
    }

    const objFields = {};
    const objFieldsMap = {};
    this.fields.forEach((fieldObj, index) => {
      objFields[fieldObj.field] = fieldObj.fieldValue;
      const chkBox = this.template.querySelector(`[data-id="${fieldObj.chkQuoteLIId}"]`);
      const ddlQuote = this.template.querySelector(`[data-id="${fieldObj.ddlSFQuoteFieldId}"]`);
      const ddlLineItem = this.template.querySelector(`[data-id="${fieldObj.ddlLineItemsId}"]`);
      const ddlQuoteLineItemField = this.template.querySelector(`[data-id="${fieldObj.ddlSFQuoteLineItemFieldId}"]`);
      objFieldsMap[fieldObj.field] = chkBox.checked
        ? { object: 'lineitem', field: ddlQuoteLineItemField.value, lineItemId: ddlLineItem.value }
        : { object: 'opportunity', field: ddlQuote.value };
    });

    const requestParticipants = this.roles
      .filter(role => role.data?.LastName && role.data?.Email)
      .map(role => ({
        firstname: role.data.FirstName,
        middlename: '',
        lastname: role.data.LastName,
        email: role.data.Email,
        type: 0,
        participantRole: role.name,
        staticSignatureEnabled: true,
        scriptedSignatureEnabled: true,
        imageSignatureEnabled: true
      }));

    const rolesMap = {};
    this.roles.forEach((role, index) => {
      rolesMap[role.name] = role.fieldName;
    });

    const finalObj = {
      name: this.allData.opportunity.Name,
      isOrdered: false,
      expirationDate: this.expirationDate ? `${this.expirationDate}T00:00:00.000Z` : '',
      callbackUrl: '##callbackurl##',
      layoutId: this.layoutId,
      fields: objFields,
      participants: requestParticipants
    };

    const mappings = { fieldsMap: objFieldsMap, rolesMap };
    const requestString = JSON.stringify(finalObj);
    const jsonMappings = JSON.stringify(mappings);

    try {
      const result = await fillandSubmit({
        requestString,
        opportunityId: this.allData.opportunity.Id,
        layoutId: this.layoutId,
        mappings: jsonMappings,
        objectName: this.objectName
      });

      if (result) {
        this.showToast('Success', 'Signing submitted successfully.', 'success');
        setTimeout(() => this.handleBack(), 2000);
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