using Swift.DAL.Remittance.CashAndVault;
using Swift.web.Library;
using System;
using System.Data;
using System.Web;

namespace Swift.web.Remit.CashAndVault
{
    public partial class ManageUserWiseLimit1 : System.Web.UI.Page
    {
        protected const string GridName = "cashAndVault";
        private string ViewFunctionId = "20178000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Misc.MakeNumericTextbox(ref cashHoldLimit);
                Misc.MakeNumericTextbox(ref perTopUpLimit);
                PopulateData();
                headerPart.InnerText = "User limit Set up : (" + GetSelectedUserName() + ")";
            }
        }

        private void PopulateData()
        {
            string branchRuleId = GetBranchRuleId();
            var dt = cavDao.GetUserDetails(GetStatic.GetUser(), GetBranchRuleId(), GetUserRuleId(), GetAgentId(), GetUserId());
            foreach (DataRow dr in dt.Rows)
            {
                UserName.Text = dr["userName"].ToString();
                decimal cashHoldLimitDecVal = Convert.ToDecimal(dr["cashHoldLimit"].ToString());
                cashHoldLimit.Text = cashHoldLimitDecVal.ToString("#,0.00");
                ddlRuleType.SelectedValue = dr["ruleType"].ToString();
            }
        }

        protected string GetBranchRuleId()
        {
            return GetStatic.ReadQueryString("cashHoldLimitId", "");
        }

        protected string GetUserRuleId()
        {
            return GetStatic.ReadQueryString("cashHoldLimitUserId", "");
        }

        protected string GetSelectedUserName()
        {
            return GetStatic.ReadQueryString("selectedUserName", "");
        }

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        protected string GetUserId()
        {
            return GetStatic.ReadQueryString("userId", "");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void Save_Click(object sender, EventArgs e)
        {
            var agentId = Request.Form["UserName"];
            var cashLimit = Request.Form["cashHoldLimit"];
            var perTopUpLimitVal = "0";
            var ruleType = Request.Form["ddlruleType"];
            //var agentId = ddlAgentBranch.SelectedValue;
            //var cashLimit = cashHoldLimit.Text;
            //var perTopUpLimitVal = perTopUpLimit.Text;
            //var ruleType = ddlruleType.SelectedValue;
            var res = cavDao.SaveUserCashAndVault(GetStatic.GetUser(), GetAgentId(), cashLimit, perTopUpLimitVal, ruleType, GetBranchRuleId(), GetUserRuleId(), GetUserId());
            if (res.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = res;
                Response.Redirect("UserWiseLimitList.aspx?cashHoldLimitId=" + GetBranchRuleId() + "&agentId=" + GetAgentId() + "");
                GetStatic.AlertMessage(this, res.Msg);
            }
            else
            {
                HttpContext.Current.Session["message"] = res;
                Response.Redirect("UserWiseLimitList.aspx?cashHoldLimitId=" + GetBranchRuleId() + "&agentId=" + GetAgentId() + "");
                GetStatic.AlertMessage(this, res.Msg);
            }
        }
    }
}