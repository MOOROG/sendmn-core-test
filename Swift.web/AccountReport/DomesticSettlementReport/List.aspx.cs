using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.DomesticRemittanceSettlementReport
{
    public partial class domestic_settelment_search : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140000";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                sl.CheckAuthentication(ViewFunctionId);
                fromDate.Text = DateTime.Now.ToString("d");
            }
        }
    }
}