using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.Agent.FundTransfer
{
    public partial class Report : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string VViewReportFunctionId = "20181930";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDdl();
                fromDate.ReadOnly = true;
                toDate.ReadOnly = true;
            }
        }

        private void PopulateDdl()
        {
            sdd.SetDDL(ref ddlAgent, "EXEC proc_fundDeposit @flag = 'agent'", "agentId", "agentName", "", "Select");
            sdd.SetDDL(ref ddlBank, "EXEC proc_fundDeposit @flag = 'bank'", "agentId", "agentName", "", "Select");
        }
    }
}