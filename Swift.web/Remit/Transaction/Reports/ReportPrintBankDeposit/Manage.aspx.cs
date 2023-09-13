using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.ReportPrintBankDeposit
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20163000";
        private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                _sdd.SetDDL(ref bankName, "EXEC [proc_agentMaster] @flag = 'banklist2'", "agentId", "agentName","", "Select");
                _sdd.SetDDL(ref payoutBankName, "EXEC [proc_agentMaster] @flag = 'banklist2'", "agentId", "agentName", "", "All");
                _sdd.SetDDL(ref sendingAgent, "EXEC [proc_agentMaster] @flag = 'al5'", "agentId", "agentName", "", "All");
            }
            fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");

            fromDate1.Text = DateTime.Now.ToString("MM/dd/yyyy");
            toDate1.Text = DateTime.Now.ToString("MM/dd/yyyy");
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}