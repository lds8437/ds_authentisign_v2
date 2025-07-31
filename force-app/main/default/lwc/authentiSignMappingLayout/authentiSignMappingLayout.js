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
    @track fieldValues = {};

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        this.spinner = true;
        try {
            const layouts = JSON.parse(this.layouts || '[]');
            this.selectedLayout = layouts.find(x => x.id === this.layoutId);
            this.fields = this.selectedLayout?.fields || [];
            this.roles = this.selectedLayout?.layoutParticipants?.map(p => ({ name: p.role, value: p.role, data: {} })) || [];

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
        const liCheckboxes = this.template.querySelectorAll('[data-name^="chkQuoteLI-"]');
        const ddlQuoteFields = this.template.querySelectorAll('[data-name^="ddlSFQuoteField-"]');
        const ddlLineItems = this.template.querySelectorAll('[data-name^="ddlLineItems-"]');
        const ddlQuoteLineItemFields = this.template.querySelectorAll('[data-name^="ddlSFQuoteLineItemField-"]');
        const txtFields = this.template.querySelectorAll('[data-name^="txtquotefieldvalue-"]');

        liCheckboxes.forEach((chk, index) => {
            const forWhich = chk.title;
            const mapping = objMappings.fieldsMap?.[forWhich];
            if (mapping) {
                if (mapping.object === 'lineitem') {
                    chk.checked = true;
                    ddlLineItems[index].value = mapping.lineItemId;
                    ddlQuoteLineItemFields[index].value = mapping.field;
                    this.isChecked(true, index);
                    this.lineItemField = mapping.field;
                    this.handleChangeQuoteLineItemddl({ detail: { value: mapping.lineItemId, name: `ddlLineItems-${index}` } });
                } else {
                    ddlQuoteFields[index].value = mapping.field;
                    this.isChecked(false, index);
                    this.handleChangeQuoteddl({ detail: { value: mapping.field, name: `ddlSFQuoteField-${index}` } });
                }
            }
        });

        const ddlUserContacts = this.template.querySelectorAll('[data-name^="ddlUserContact-"]');
        Object.keys(objMappings.rolesMap || {}).forEach(key => {
            const ddl = Array.from(ddlUserContacts).find(d => d.title === key);
            if (ddl) {
                ddl.value = objMappings.rolesMap[key];
                this.handleUserContactddl({ detail: { value: objMappings.rolesMap[key], name: ddl.name } });
            }
        });
    }

    isChecked(isChecked, index) {
        const ddlQuotes = this.template.querySelector(`[data-name="ddlSFQuoteField-${index}"]`);
        const ddlLineItems = this.template.querySelector(`[data-name="ddlLineItems-${index}"]`);
        const ddlQuoteLineItems = this.template.querySelector(`[data-name="ddlSFQuoteLineItemField-${index}"]`);
        const txtField = this.template.querySelector(`[data-name="txtquotefieldvalue-${index}"]`);

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
    }

    handleChangeQuoteddl(event) {
        const nameSplit = event.detail.name.split('-');
        const index = nameSplit[1];
        const value = event.detail.value;
        const txtControl = this.template.querySelector(`[data-name="txtquotefieldvalue-${index}"]`);
        const txtControlValue = this.allData.opportunity[value] || (this.allData.opportunity[value]?.Name || '');
        this.fieldValues = { ...this.fieldValues, [this.fields[index]]: txtControlValue };
        txtControl.value = txtControlValue;
    }

    handleChangeQuoteLineItemddl(event) {
        const index = event.detail.name.split('-')[1];
        const txtControl = this.template.querySelector(`[data-name="txtquotefieldvalue-${index}"]`);
        const name = event.detail.name;

        if (name.includes('ddlLineItems')) {
            this.lineItemId = event.detail.value;
        } else if (name.includes('ddlSFQuoteLineItemField')) {
            this.lineItemField = event.detail.value;
        }

        if (this.lineItemField && this.lineItemId) {
            const lineItemRecord = this.allData.opportunityLineItems.find(x => x.Id === this.lineItemId);
            const txtControlValue = lineItemRecord?.[this.lineItemField] || (lineItemRecord?.[this.lineItemField]?.Name || '');
            this.fieldValues = { ...this.fieldValues, [this.fields[index]]: txtControlValue };
            txtControl.value = txtControlValue;
        } else {
            this.fieldValues = { ...this.fieldValues, [this.fields[index]]: '' };
            txtControl.value = '';
        }
    }

    handleUserContactddl(event) {
        const index = parseInt(event.detail.name.split('-')[1]);
        const fieldName = event.detail.value;
        const lookupField = this.allData.usercontactfieldmap[fieldName];
        const opportunityRecord = this.allData.opportunity[lookupField];

        const roles = [...this.roles];
        const role = roles[index];

        if (opportunityRecord) {
            role.data = { ...opportunityRecord, fieldName };
            const participientFields = this.allData.participientFields[lookupField];
            let objectType = participientFields[participientFields.length - 1].replace(/[()]/g, '');
            objectType = objectType.includes('User') ? 'User' : objectType;
            role.data.Type = objectType;
        } else {
            role.data = { Name: '', Email: '', FirstName: '', Id: '', LastName: '', Type: '', fieldName };
        }
        this.roles = roles;
    }

    chkQuoteLIChange(event) {
        const isChecked = event.target.checked;
        const index = event.target.name.split('-')[1];
        this.isChecked(isChecked, index);
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

        const ddlUserContacts = this.template.querySelectorAll('[data-name^="ddlUserContact-"]');
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
        this.fields.forEach((field, index) => {
            const txtField = this.template.querySelector(`[data-name="txtquotefieldvalue-${index}"]`);
            const chkBox = this.template.querySelector(`[data-name="chkQuoteLI-${index}"]`);
            const ddlQuote = this.template.querySelector(`[data-name="ddlSFQuoteField-${index}"]`);
            const ddlLineItem = this.template.querySelector(`[data-name="ddlLineItems-${index}"]`);
            const ddlQuoteLineItemField = this.template.querySelector(`[data-name="ddlSFQuoteLineItemField-${index}"]`);

            objFields[field] = txtField.value;
            objFieldsMap[field] = chkBox.checked
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
            const ddl = this.template.querySelector(`[data-name="ddlUserContact-${index}"]`);
            rolesMap[role.name] = ddl.value;
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

    getLineItemClass(index) {
        return this.template.querySelector(`[data-name="chkQuoteLI-${index}"]`)?.checked ? 'slds-show' : 'slds-hide';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}