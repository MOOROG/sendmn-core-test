using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.LiquidityReport
{
    public partial class LiquidityReportSearch : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private string viewFunctionId = "20330000";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            Authenticate();
            fromDate.Text = DateTime.Now.ToString("d");
        }

        private void Authenticate()
        {
            sl.HasRight(viewFunctionId);
        }
    }
}