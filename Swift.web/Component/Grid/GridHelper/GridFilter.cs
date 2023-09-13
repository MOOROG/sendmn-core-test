namespace Swift.web.Component.Grid.gridHelper
{
    public class GridFilter
    {
        public GridFilter()
        {
        }

        public GridFilter(string key, string description, string type)
        {
            Key = key;
            Description = description;
            Type = type;
        }

        public GridFilter(string key, string description, string type, string defaultValue)
        {
            Key = key;
            Description = description;
            Type = type;
            DefaultValue = defaultValue;
        }

        public GridFilter(string key, string description, string type, string defaultValue, string category, bool value)
        {
            Key = key;
            Description = description;
            Type = type;
            DefaultValue = defaultValue;
            Category = category;
            Value = value;
        }

        public GridFilter(string key, string description, string type, string defaultValue, string category, bool value, string param1)
        {
            Key = key;
            Description = description;
            Type = type;
            DefaultValue = defaultValue;
            Category = category;
            Value = value;
            Param1 = param1;
        }

        public GridFilter(string key, string description, string type, string defaultValue, string category, bool value, string param1, string param2)
        {
            Key = key;
            Description = description;
            Type = type;
            DefaultValue = defaultValue;
            Category = category;
            Value = value;
            Param1 = param1;
            Param2 = param2;
        }

        public GridFilter(string key, string description, string type, string defaultValue, string category, bool value, string param1, string param2, string param3)
        {
            Key = key;
            Description = description;
            Type = type;
            DefaultValue = defaultValue;
            Category = category;
            Value = value;
            Param1 = param1;
            Param2 = param2;
            Param3 = param3;
        }

        private string _key = "";
        private string _description = "";
        private string _type = "";
        private string _defaultValue = "";

        public string Key
        {
            set { _key = value; }
            get { return _key; }
        }

        public string Description
        {
            set { _description = value; }
            get { return _description; }
        }

        public string Type
        {
            set { _type = value; }
            get { return _type; }
        }

        public string DefaultValue
        {
            set { _defaultValue = value; }
            get { return _defaultValue; }
        }

        private string _category;

        public string Category
        {
            set { _category = value; }
            get { return _category; }
        }

        private bool _value;

        public bool Value
        {
            set { _value = value; }
            get { return _value; }
        }

        public string Param1 { set; get; }
        public string Param2 { set; get; }
        public string Param3 { set; get; }
    }
}