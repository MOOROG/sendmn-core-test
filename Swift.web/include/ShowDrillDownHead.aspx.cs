using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.include
{
    public partial class ShowDrillDownHead : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private StringBuilder _str = new StringBuilder();
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            LoadHeader();
        }

        private void LoadHeader()
        {
            string type = GetReportType();
            var dt = _obj.GetLedgerHeader(type);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            _str.Append("<div class=\"row\">");
            foreach (DataRow dr in dt.Rows)
            {
                _str.Append("<div class=\"col-md-12\">");
                _str.Append("<i class=\"fa fa-folder-open\" alt=\"click\" style='font-size:14; color:#FFC300; padding:0 5px;'></i>");
                _str.Append("<label style=\"cursor:pointer;\" onclick=\"ShowReportGL('r" + dr["reportid"] + "','td" + dr["reportid"] + "')\">" + dr["lable"] + "</label>");
                _str.Append("</div>");
                _str.Append("<div class=\"col-md-12\" style=\"color:#\">");
                _str.Append("<div id=" + "td" + dr["reportid"] + ">");
                _str.Append("</div>"); _str.Append("</div>");
            }

            _str.Append("</div>");
            getDetails.InnerHtml = _str.ToString();
        }

        private string GetReportType()
        {
            return GetStatic.ReadQueryString("q", "");
        }
    }
}