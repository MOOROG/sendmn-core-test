using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.PaidReport
{
    public partial class PaidTxnReport : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140300";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                sl.CheckAuthentication(ViewFunctionId);
                fromDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
            }
        }
    }
}