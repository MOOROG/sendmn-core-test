using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.InternationalTranReport.ReconciliationReport
{
    public partial class View : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140800";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckAuthentication(ViewFunctionId);
            end_date.Text = DateTime.Now.ToShortDateString();
            start_date.Text = DateTime.Now.ToShortDateString();
        }
    }
}