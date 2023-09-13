using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.InternationalTranReport.TxnReport
{
    public partial class View : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140900";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckAuthentication(ViewFunctionId);
            sfromDate.Text = DateTime.Now.ToString("d");
            stoDate.Text = DateTime.Now.ToString("d");
            rfromDate.Text = DateTime.Now.ToString("d");
            rtoDate.Text = DateTime.Now.ToString("d");
            mtodate.Text = DateTime.Now.ToString("d");
            mfromdate.Text = DateTime.Now.ToString("d");
        }
    }
}