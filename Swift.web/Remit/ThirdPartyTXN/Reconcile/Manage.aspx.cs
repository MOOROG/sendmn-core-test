using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ThirdPartyTXN.Reconcile
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionID = "20173000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
           _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.ReadOnly = true;
                fromDate.ReadOnly = true;
                loadDDL();
            }
            ShowHideDate();
        }
        private void loadDDL()
        {
            _sdd.SetDDL(ref thirdPartyAgent, "EXEC [proc_dropDownLists2] @flag = 'reconcile'", "value", "text", "", "ALL");
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionID);
        }

        protected void thirdPartyAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
        }
        void ShowHideDate()
        {
            var showToDate = !(thirdPartyAgent.Text.Equals(DAL.BL.System.Utility.Utility.GetgblAgentId()) || thirdPartyAgent.Text.Equals(DAL.BL.System.Utility.Utility.GetkumariAgentId()) || thirdPartyAgent.Text.Equals(DAL.BL.System.Utility.Utility.GetMaxMoneyAgentId()));

            lblFromDate.Text = showToDate ? "From Date:" : "Date:";
            tDate.Visible = showToDate;
            if (GetPartnerIdArr(thirdPartyAgent.Text).Equals(DAL.BL.System.Utility.Utility.GetkumariAgentId()))
            {
                tAgent.Visible = false;
                tDate.Visible = true;
                rptType.Visible = true;
            }
            else
            {
                tAgent.Visible = false;
                rptType.Visible = false;
            }

        }
        protected string GetPartnerIdArr(string partnerAndSubPartner)
        {
            if (!string.IsNullOrEmpty(partnerAndSubPartner))
            {
                return partnerAndSubPartner.Split('|')[0];
            }
            else
            {
                return "";
            }
        }
    }
}