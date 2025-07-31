/*
*********************************************************
@Apex Class Name    : HttpHexFormBuilder
@Created Date       : Unknown
@description        : Utility class to build multipart form data for HTTP requests
@author             : FFD Developer
@Modification Log   : 
  - Updated July 31, 2025: Added TestVisible to form variable. Added documentation for consistency with Opportunity-based codebase. Confirmed no CPQ dependencies.
*********************************************************
*/
public class HttpHexFormBuilder {
    private final static String BOUNDARY = '----sfdc-multi-form';
    @TestVisible
    private String form;

    /*
    *********************************************************
    @Method Name    : HttpHexFormBuilder
    @description    : Constructor
    ********************************************************
    */
    public HttpHexFormBuilder() {
        form = '';
    }

    /*
    *********************************************************
    @Method Name    : build
    @description    : Create a new form builder instance
    @return         : HttpHexFormBuilder
    ********************************************************
    */
    public static HttpHexFormBuilder build() {
        return new HttpHexFormBuilder();
    }

    /*
    *********************************************************
    @Method Name    : getBoundary
    @description    : Get the boundary string for multipart form
    @return         : String
    ********************************************************
    */
    public static String getBoundary() {
        return BOUNDARY;
    }

    /*
    *********************************************************
    @Method Name    : GetContentType
    @description    : Get the content type for multipart form
    @return         : String
    ********************************************************
    */
    public static String GetContentType() {
        return 'multipart/form-data; boundary="' + BOUNDARY + '"';
    }

    /*
    *********************************************************
    @Method Name    : writeFooter
    @description    : Append the form boundary footer
    @return         : HttpHexFormBuilder
    ********************************************************
    */
    private HttpHexFormBuilder writeFooter() {
        this.form += EncodingUtil.convertToHex(Blob.valueOf('--' + BOUNDARY + '--'));
        return this;
    }

    /*
    *********************************************************
    @Method Name    : writeParam
    @description    : Add a form parameter
    @param          : String key, String value
    @return         : HttpHexFormBuilder
    ********************************************************
    */
    public HttpHexFormBuilder writeParam(String key, String value) {
        String body = '--' + BOUNDARY;
        body += '\r\nContent-Disposition: form-data; name="' + key + '"\r\n\r\n' + value + '\r\n';
        this.form += EncodingUtil.convertToHex(Blob.valueOf(body));
        return this;
    }

    /*
    *********************************************************
    @Method Name    : writeFile
    @description    : Add a file to the form
    @param          : String key, String fileName, String fileContent
    @return         : HttpHexFormBuilder
    ********************************************************
    */
    public HttpHexFormBuilder writeFile(String key, String fileName, String fileContent) {
        String mimeType = resolveMimeType(fileName);
        String content = '--' + BOUNDARY;
        content += '\r\nContent-Disposition: form-data; name="' + key + '"; filename="' + fileName + '"\r\nContent-Type: ' + mimeType + '\r\n\r\n';
        content = EncodingUtil.convertToHex(Blob.valueOf(content));
        content += EncodingUtil.convertToHex(EncodingUtil.base64Decode(fileContent));
        content += EncodingUtil.convertToHex(Blob.valueOf('\r\n'));
        this.form += content;
        return this;
    }

    /*
    *********************************************************
    @Method Name    : getFormAsString
    @description    : Get the form as a hex string
    @return         : String
    ********************************************************
    */
    public String getFormAsString() {
        this.writeFooter();
        return this.form;
    }

    /*
    *********************************************************
    @Method Name    : getFormAsBlob
    @description    : Get the form as a Blob
    @return         : Blob
    ********************************************************
    */
    public Blob getFormAsBlob() {
        return EncodingUtil.convertFromHex(this.getFormAsString());
    }

    /*
    *********************************************************
    @Method Name    : resolveMimeType
    @description    : Determine MIME type based on file extension
    @param          : String fileName
    @return         : String
    ********************************************************
    */
    @TestVisible
    private static String resolveMimeType(String fileName) {
        String fileType = fileName.substringAfterLast('.').toLowerCase();
        String mimeType = 'application/pdf'; // Default for PDFs
        if (fileType == 'png') {
            mimeType = 'image/png';
        } else if (fileType == 'jpeg' || fileType == 'jpg') {
            mimeType = 'image/jpg';
        } else if (fileType == 'pgm') {
            mimeType = 'image/x-portable-graymap';
        } else if (fileType == 'ppm') {
            mimeType = 'image/x-portable-pixmap';
        }
        return mimeType;
    }
}