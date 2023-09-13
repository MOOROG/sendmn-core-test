using Swift.web.Library;
using System;

namespace Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer
{
    public partial class Report : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20111400";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GetStatic.PrintMessage(Page);
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sdd.SetDDL(ref agentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All");
        }
    }
}