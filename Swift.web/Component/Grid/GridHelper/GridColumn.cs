namespace Swift.web.Component.Grid.gridHelper
{
    public class GridColumn : GridFilter
    {
        public GridColumn(string key, string description, string width, string type)
        {
            Key = key;
            Description = description;
            Width = width;
            Type = type;
        }

        public GridColumn(string key, string description, string width, string type, string columnDataType)
        {
            Key = key;
            Description = description;
            Width = width;
            Type = type;
            ColumnDataType = columnDataType;
        }

        private string _width;

        public string Width
        {
            set { _width = value; }
            get { return _width; }
        }

        private string _columnDataType;

        public string ColumnDataType
        {
            set { _columnDataType = value; }
            get { return _columnDataType; }
        }
    }
}