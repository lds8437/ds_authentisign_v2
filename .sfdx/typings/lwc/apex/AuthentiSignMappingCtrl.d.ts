declare module "@salesforce/apex/AuthentiSignMappingCtrl.getAllData" {
  export default function getAllData(param: {recordId: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthentiSignMappingCtrl.fillandSubmit" {
  export default function fillandSubmit(param: {requestString: any, recordId: any, layoutId: any, mappings: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthentiSignMappingCtrl.savePDFasAttachment" {
  export default function savePDFasAttachment(param: {recordId: any, signingId: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthentiSignMappingCtrl.savePDFasAttachmentDocument" {
  export default function savePDFasAttachmentDocument(param: {recordId: any, signingId: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthentiSignMappingCtrl.submitDocumentRequest" {
  export default function submitDocumentRequest(param: {requestString: any, recordId: any, recordName: any, documentId: any, documentName: any, objectName: any}): Promise<any>;
}
