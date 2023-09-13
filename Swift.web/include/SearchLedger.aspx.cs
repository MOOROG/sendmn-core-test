using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.include
{
    public partial class SearchLedger : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private StringBuilder _str = new StringBuilder();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            LoadSearchData();
        }

        private void LoadSearchData()
        {
            var dt = _obj.SearchLedger(GetAccountNum(), GetSearchBy());
            if (dt == null || dt.Rows.Count == 0)
                return;
            _str.Append("<table>");
            _str.Append("<tr>");
            _str.Append("<td>");
            _str.Append("<strong> Item in tree structure </strong>");
            _str.Append("</td>");
            _str.Append("</tr>");
            _str.Append("</table>");
            _str.Append("<table border=\"1px\">");
            foreach (DataRow dr in dt.Rows)
            {
                _str.Append("<tr>");
                _str.Append("<td>");
                _str.Append("" + dr["Name"] + "");
                _str.Append("</td>");
                _str.Append("</tr>");
            }
            _str.Append("</table>");
            filterList.InnerHtml = _str.ToString();
        }

        private string GetAccountNum()
        {
            return GetStatic.ReadQueryString("accNumber", "");
        }

        private string GetSearchBy()
        {
            return GetStatic.ReadQueryString("searchBy", "");
        }
    }
}