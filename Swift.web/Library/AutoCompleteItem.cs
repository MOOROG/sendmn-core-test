namespace Swift.web.Library
{
    public class AutoCompleteItem
    {
        public string Key { get; set; }
        public string Value { get; set; }

        public AutoCompleteItem(string key, string value)
        {
            Key = key;
            Value = value;
        }
    }
}