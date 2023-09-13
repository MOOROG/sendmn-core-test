using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.SettlementDetailReport
{
    public partial class DetailTxtReport : System.Web.UI.Page
    {
        private SwiftLibrary _swiftLib = new SwiftLibrary();
        private const string ViewFunctionId = "20140500";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _swiftLib.CheckAuthentication(ViewFunctionId);
                fromDate.Text = DateTime.Now.ToString("d");
                fromDate.Attributes.Add("readonly", "readonly");
                toDate.Text = DateTime.Now.ToString("d");
                toDate.Attributes.Add("readonly", "readonly");
            }
        }
    }
}