/**
@Apex Class Name    : LayoutParticipant
@Created Date       : Dec 12, 2023
@description        : Wrapper class used in LayoutWrapper class
@author             : FFD Developer
@Modification Log   : 
*/
public with sharing class LayoutParticipant
{
    /**
     * @description id
     * @return string
     */
    @AuraEnabled
    public string id { get; set; }
    /**
     * @description layouintegertId
     * @return string
     */
    @AuraEnabled
    public string layoutId { get; set; }
    /**
     * @description role
     * @return string
     */
    @AuraEnabled
    public string role { get; set; }
    /**
     * @description order
     * @return integer
     */
    @AuraEnabled
    public integer order { get; set; }
    /**
     * @description dateCreated
     * @return DateTime
     */
    @AuraEnabled
    public DateTime dateCreated { get; set; }
    /**
     * @description layout
     * @return string
     */
    @AuraEnabled
    public string layout { get; set; }
}