using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.Reports.ChashCollected
{
    public partial class Search : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150080";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.HasRight(ViewFunctionId);
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
    }
}