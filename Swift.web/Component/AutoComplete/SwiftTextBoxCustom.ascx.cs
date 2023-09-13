using System;
using System.Text;
using Swift.web.Library;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.web.Component.AutoCompleteCustom
{
    public partial class SwiftTextBoxCustom : System.Web.UI.UserControl
    {
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        private string _url;
        public string URL
        {
            set { _url = value; }
            get
            {
                if (string.IsNullOrWhiteSpace(_url))
                {
                    return DefaultURL + GetSurfix();
                }

                return _url + GetSurfix();
            }
        }

        public string Width { set; get; }
        public string Value
        {
            set { aValue.Value = value; }
            get
            {
                return aValue.Value;
            }
        }

        public string Text
        {
            set { aText.Text = value; }
            get
            {
                return aText.Text;
            }
        }

        public string Category { set; get; }
        public string Param1 { set; get; }
        public string Param2 { set; get; }
        public string Param3 { set; get; }

        private string DefaultURL = GetStatic.GetUrlRoot() + "/Component/AutoComplete/DataSourceCustom.asmx/GetList";


        protected String GetData()
        {
            var sb = new StringBuilder();

            sb.Append("'category' : '" + Category + "'");

            if (!string.IsNullOrWhiteSpace(Param1))
            {
                var data = ParseParam("param1", Param1);
                sb.Append("," + data);

            }
            if (!string.IsNullOrWhiteSpace(Param2))
            {
                var data = ParseParam("param2", Param2);
                sb.Append("," + data);

            }
            if (!string.IsNullOrWhiteSpace(Param3))
            {
                var data = ParseParam("param3", Param3);
                sb.Append("," + data);

            }

            return sb.ToString();
        }

        string ParseParam(string key, string data)
        {
            if (data.StartsWith("@"))
            {
                return @"'" + key + @"':'"" + " + data.Substring(1) + @" +  ""'";
            }
            else
            {
                return "'" + key + "':'" + data + "'";
            }

        }

        private string GetSurfix()
        {
            string surfix = "";
            if (!string.IsNullOrWhiteSpace(Param1))
            {

                surfix = "1";
            }
            if (!string.IsNullOrWhiteSpace(Param2))
            {

                surfix = "2";
            }
            if (!string.IsNullOrWhiteSpace(Param3))
            {

                surfix = "3";
            }
            return surfix;
        }

        public string InitFunction()
        {
            var sb = new StringBuilder();
            sb.Append("LoadAutoCompleteTextBoxCustom(");
            sb.Append(@"""" + URL + @"""");
            sb.Append(@",""#" + ClientID + @"""");
            //sb.Append(@",""#" + aValue.ClientID + @"""");
            //sb.Append(@",""#" + aText.ClientID + @"""");
            //sb.Append(@",""#" + aSearch.ClientID + @"""");
            sb.Append(@",""" + Width + @"""");
            sb.Append(@",""" + GetData() + @""");");
            return sb.ToString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            getCountry();
        }
        public void getCountry()
        {
            
            _sdd.SetDDL(ref aCustom, "EXEC proc_dropDownLists2 @FLAG='criteriaCountry'", "value", "text", "", "");
        }
    }
}