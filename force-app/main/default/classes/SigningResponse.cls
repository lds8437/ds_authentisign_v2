public with sharing class SigningResponse
{
    public string id { get; set; }
    public string name { get; set; }
    public string accountId { get; set; }
    public integer statusId { get; set; }
    public boolean isOrdered { get; set; }
    public DateTime dateCreated { get; set; }
    public DateTime lastModified { get; set; }
    public DateTime expirationDate { get; set; }
    public integer idPosition { get; set; }
    public string reminderDay { get; set; }
    public string reminderHour { get; set; }
    public string transactionId { get; set; }
    public string technologyProvider { get; set; }
    public string callbackUrl { get; set; }
}