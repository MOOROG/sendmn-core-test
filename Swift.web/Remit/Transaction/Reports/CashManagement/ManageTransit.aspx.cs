using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.Reports.CashManagement
{
    public partial class ManageTransit : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "21110000";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                asOfDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateDdl();
                Authenticate();
            }
        }
        private void PopulateDdl()
        {
            _sl.SetDDL(ref ddlBranch, "EXEC PROC_REFERRAL_REPORT @flag='referralName'", "valueId", "detailTitle", "", "All");
            _sl.SetDDL(ref ddlUser, "EXEC PROC_REFERRAL_REPORT @flag='referralName'", "valueId", "detailTitle", "", "All");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}