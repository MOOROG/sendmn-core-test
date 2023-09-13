using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.AgentSummary
{
    public partial class AgentSummeryReport : System.Web.UI.Page
    {
        private RemittanceLibrary _remitLib = new RemittanceLibrary();
        private const string ViewFunctionId = "20140200";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _remitLib.CheckAuthentication(ViewFunctionId);
                agentGroupDDL.Attributes["onchange"] = "SetValue();";
                asOnDate.Text = DateTime.Now.ToString("d");
                asOnDate.Attributes.Add("readonly", "readonly");
                PopulateDDL();
            }
        }

        private void PopulateDDL()
        {
            _remitLib.SetDDL(ref agentGroupDDL, "EXEC Proc_dropdown_remit @flag='AGroup'", "valueId", "detailTitle", "", "");
        }
    }
}