using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.NRBReport
{
    public partial class NrbReportSearch : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            fromDate.Text = DateTime.Now.ToString("d");
            toDate.Text = DateTime.Now.ToString("d");
        }
    }
}