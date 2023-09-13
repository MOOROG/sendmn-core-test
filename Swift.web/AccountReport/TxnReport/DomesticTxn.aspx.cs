using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.TxnReport
{
    public partial class DomesticTxn : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140100";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckAuthentication(ViewFunctionId);
            if (!IsPostBack)
            {
                sl.CheckSession();
                fromDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
                rFromDate.Text = DateTime.Now.ToString("d");
                rToDate.Text = DateTime.Now.ToString("d");
            }
        }
    }
}