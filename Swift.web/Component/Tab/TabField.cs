namespace Swift.web.Component.Tab
{
    public class TabField
    {
        private string _tabDesc = "";
        private string _refPage = "";
        private bool _isSelected;

        public TabField()
        {
        }

        public TabField(string tabDesc, string refPage, bool isSelected)
        {
            TabDesc = tabDesc;
            RefPage = refPage;
            IsSelected = isSelected;
        }

        public TabField(string tabDesc, string refPage)
        {
            TabDesc = tabDesc;
            RefPage = refPage;
        }

        public string TabDesc
        {
            get { return _tabDesc; }
            set { _tabDesc = value; }
        }

        public string RefPage
        {
            get { return _refPage; }
            set { _refPage = value; }
        }

        public bool IsSelected
        {
            get { return _isSelected; }
            set { _isSelected = value; }
        }
    }
}