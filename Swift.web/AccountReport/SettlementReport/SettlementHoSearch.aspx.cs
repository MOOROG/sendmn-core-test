using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.SettlementReport
{
    public partial class SettlementHoSearch : System.Web.UI.Page
    {
        private SwiftLibrary _swiftLib = new SwiftLibrary();
        private const string ViewFunctionId = "20140400";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _swiftLib.CheckAuthentication(ViewFunctionId);
                fromDate.Text = DateTime.Now.ToString("d");
                fromDate.Attributes.Add("readonly", "readonly");
                toDate.Text = DateTime.Now.ToString("d");
                toDate.Attributes.Add("readonly", "readonly");
            }
        }

        protected void populateDDL_Click(object sender, EventArgs e)
        {
            PopulateDDL();
        }

        private void PopulateDDL()
        {
            _swiftLib.SetDDL(ref branchDDL, "EXEC Proc_MistakelyPostViewAdd @flag = 'bDisp',@agentId= '" + acInfo.Value + "'", "map_code", "agent_name", "", "Select Branch");
        }
    }
}