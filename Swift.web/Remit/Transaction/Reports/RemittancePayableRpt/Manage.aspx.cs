using System;
using Swift.web.Library;


namespace Swift.web.Remit.Transaction.Reports.RemittancePayableRpt
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20140700";
        protected void Page_Load(object sender, EventArgs e)
        {
            fromDate.ReadOnly = true;
            toDate.ReadOnly = true;
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                PopulateDdl();
            }
        }

        private void PopulateDdl()
        {
            sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownListsAC @flag ='sAgent'", "map_code", "agent_name", "", "All");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}