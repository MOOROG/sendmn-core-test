using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.TdsReport
{
    public partial class TdsReportSearch : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20101700";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckAuthentication();
                fromDate.Text = DateTime.Now.ToString("d");
            }
        }

        private void CheckAuthentication()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}