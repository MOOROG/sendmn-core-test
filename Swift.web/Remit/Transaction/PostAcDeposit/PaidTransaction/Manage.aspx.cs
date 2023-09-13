using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.PostAcDeposit.PaidTransaction
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private const string ViewFunctionId = "20122500";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //Response.Redirect("Pending.aspx?fromDate=" + fromDate.Text + "&fromTime=" + fromTime.Text + "&toDate=" + toDate.Text + "&toTime=" + toTime.Text + "");
      Response.Redirect("PendingIntl.aspx?fromDate=" + fromDate.Text + "&fromTime=" + fromTime.Text + "&toDate=" + toDate.Text + "&toTime=" + toTime.Text + "");
    }

        protected void BtnSearchAll_Click(object sender, EventArgs e)
        {
            //Response.Redirect("Pending.aspx");
      Response.Redirect("PendingIntl.aspx");
    }
    }
}