using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.ReferralReport
{
    public partial class SearchReferralReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "21100000";
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateDdl();
                Authenticate();
            }

        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(GetFunctionIdByUserType(null, ViewFunctionId));
        }
        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }
        private void PopulateDdl()
        {
            _sl.SetDDL(ref ddlReferralName, "EXEC PROC_REFERRAL_REPORT @flag='referralName'", "valueId", "detailTitle", "", "All");
        }
    }
}