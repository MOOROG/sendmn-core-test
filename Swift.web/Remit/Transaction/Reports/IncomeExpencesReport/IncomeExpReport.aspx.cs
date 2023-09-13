using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.CustomerReport
{
    public partial class IncomeExpReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "2023000";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateDDL()
        {
            _sdd.SetDDL(ref branchDDL, "EXEC [proc_dropDownLists] @flag='partner-list'", "agentId", "agentName", "", "All");
        }
    }
}