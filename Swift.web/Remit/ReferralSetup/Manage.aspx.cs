using Swift.DAL.Remittance.ReferralSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.ReferralSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20201700";
        private string AddEditFunctionId = "20201710";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly ReferralSetupDao _refDao = new ReferralSetupDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeNumericTextbox(ref referralMobile);
                Misc.MakeNumericTextbox(ref cashHoldLimit);
                PopulateDDL();
                if (GetId() != "")
                {
                    PopulateData();
                }
            }
        }

        private void PopulateDDL()
        {
            _sl.SetDDL(ref ddlBranchList, "EXEC PROC_REFERALSETUP @flag ='branchList'", "agentId", "agentName", "", "Select Branch");
            // _sl.SetDDL(ref partnerDDL, "EXEC PROC_API_ROUTE_PARTNERS @flag='partner'", "agentId",
            // "agentName", "", "Select Partner");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
            if (!_sl.HasRight(AddEditFunctionId))
            {
                btnSave.Enabled = false;
                btnSave.Visible = false;
            }
        }

        protected void PopulateData()
        {
            DataRow dr = _refDao.GetData(GetId(), GetStatic.GetUser());
            if (dr == null)
            {
                Response.Redirect("List.aspx");
            }
            var a = dr["IS_ACTIVE"].ToString();
            isActiveDDL.SelectedValue = dr["IS_ACTIVE"].ToString() == "False" ? "0" : "1";
            //ddlAgentId.SelectedValue = dr["AGENT_ID"].ToString();
            referralName.Text = dr["REFERRAL_NAME"].ToString();
            referralAddress.Text = dr["REFERRAL_ADDRESS"].ToString();
            referralEmail.Text = dr["REFERRAL_EMAIL"].ToString();
            referralMobile.Text = dr["REFERRAL_MOBILE"].ToString();
            ddlBranchList.SelectedValue = dr["BRANCH_ID"].ToString();
            ddlReferraltype.SelectedValue = dr["REFERRAL_TYPE_CODE"].ToString();
            ddlruleType.SelectedValue = dr["RULE_TYPE"].ToString();
            cashHoldLimit.Text = GetStatic.ShowDecimal(dr["REFERRAL_LIMIT"].ToString());
            //deductTaxOnSc.SelectedValue = (bool.Parse(dr["DEDUCT_TAX_ON_SC"].ToString()) == false) ? "0" : "1";

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string flag = string.IsNullOrEmpty(GetId()) ? "i" : "u";
            var fname = Request.Form["referralName"].ToString();
            var raddress = Request.Form["referralAddress"].ToString();
            var rEmailAddress = Request.Form["referralEmail"].ToString();
            var rMobile = Request.Form["referralMobile"].ToString();
            var isActive = Request.Form["isActiveDDL"].ToString();
            var branchId = Request.Form["ddlBranchList"].ToString();
            var referralTypeCode = Request.Form["ddlReferraltype"].ToString();
            var referralType = ddlReferraltype.SelectedItem.ToString();
            var ruleType = ddlruleType.SelectedItem.ToString();
            var cashHoldLimitAmount = Request.Form["cashHoldLimit"].ToString();
            //var deductTaxOnServiceCharge = Request.Form["deductTaxOnSc"].ToString();

            DbResult _dbRes = _refDao.InsertReferral(flag, GetStatic.GetUser()
                                , fname, raddress
                                , rEmailAddress
                                , isActive
                                , rMobile, branchId, GetId(), referralTypeCode, referralType
                                , ruleType, cashHoldLimitAmount);

            if (_dbRes.ErrorCode != "0")
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
            GetStatic.SetMessage(_dbRes);
            Response.Redirect("List.aspx");
        }

        protected string GetId()
        {
            return GetStatic.ReadQueryString("ROW_ID", "");
        }
    }
}