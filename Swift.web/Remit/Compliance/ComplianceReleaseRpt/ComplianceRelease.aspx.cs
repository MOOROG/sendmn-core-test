using Swift.web.Library;
using System;

namespace Swift.web.Remit.Compliance.ComplianceReleaseRpt
{
    public partial class ComplianceRelease : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20194001";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                Authenticate();
                LoadDdl();
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadDdl()
        {
            sl.SetDDL(ref holdReaseon, "EXEC proc_complianceReleaseReport @flag = 'ddl', @user = " + sl.FilterString(GetStatic.GetUser()), "Value", "Reason", "", "All");
        }

        protected void reportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (reportType.Text.ToUpper().Equals("DETAIL-REPORT"))
            {
                optBlock_id.Visible = true;
                optBlock_reason.Visible = true;
                optBlock_name.Visible = true;
            }
            else
            {
                optBlock_id.Visible = false;
                optBlock_reason.Visible = false;
                optBlock_name.Visible = false;
                customerName.Text = "";
                holdReaseon.Text = "";
                idNumber.Text = "";
            }
        }
    }
}