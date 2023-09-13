using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.CashCollectedReport
{
    public partial class Search : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private const string ViewFunctionID = "20202600";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.HasRight(ViewFunctionID);
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
    }
}