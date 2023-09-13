using Swift.web.Library;
using System;

namespace Swift.web.RemittanceSystem.RemittanceReports.UntransactedReport
{
    public partial class UntransactedList : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20197000";
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                swiftLibrary.CheckAuthentication(ViewFunctionId);
            }
            fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
    }
}