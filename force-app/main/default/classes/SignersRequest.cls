public class SignersRequest {

    public Data data { get; set; }
    
    public class Data
    {
        public string Name { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Role { get; set; }
    }
}