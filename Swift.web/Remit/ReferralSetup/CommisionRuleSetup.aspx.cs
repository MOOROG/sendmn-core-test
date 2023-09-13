using Swift.DAL.Model;
using Swift.DAL.Remittance.ReferralSetup;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ReferralSetup
{
    public partial class CommisionRuleSetup : System.Web.UI.Page
    {
        RemittanceLibrary rl = new RemittanceLibrary();
        SwiftLibrary sl = new SwiftLibrary();
        private readonly ReferralSetupDao _refDao = new ReferralSetupDao();
        private string ViewFunctionId = "20201700";
        protected void Page_Load(object sender, EventArgs e)
        {
            rl.CheckSession();
            Authenticate();

            if (!IsPostBack)
            {
                effectiveFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                Misc.MakeNumericTextbox(ref commPercent);
                Misc.MakeNumericTextbox(ref fxPercent);
                Misc.MakeNumericTextbox(ref flatTxnWise);
                Misc.MakeNumericTextbox(ref newCustomer);
                PopulateDdl();
                if(EditOrNot() == "true")
                {
                    partnerDDL.Enabled = false;
                }
                if(GetRefId() != "")
                {
                    PopulateData();
                }
            }

        }
        private void PopulateData()
        {
            try
            {
                DataRow res = _refDao.GetCommissionData(GetStatic.GetUser(), GetRefId(),GetPartnerId(), GetRowId());
                partnerDDL.SelectedValue = res["PARTNER_ID"].ToString();
                commPercent.Text = res["COMM_PCNT"].ToString();
                fxPercent.Text = res["FX_PCNT"].ToString();
                flatTxnWise.Text = res["FLAT_TXN_WISE"].ToString();
                newCustomer.Text = res["NEW_CUSTOMER"].ToString();
                effectiveFrom.Text = res["EFFECTIVE_FROM"].ToString();
                isActive.SelectedValue = res["IS_ACTIVE"].ToString();
                deductPCommOnSc.SelectedValue = (bool.Parse(res["DEDUCT_P_COMM_ON_SC"].ToString()) == false) ? "0" : "1";
                deductTaxOnSc.SelectedValue = (bool.Parse(res["DEDUCT_TAX_ON_SC"].ToString()) == false) ? "0" : "1";
            }
            catch (Exception ex)
            {
                GetStatic.AlertMessage(this.Page, ex.Message);
            }


        }
        private void Authenticate()
        {
            sl.HasRight(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            rl.SetDDL(ref partnerDDL, "EXEC PROC_API_ROUTE_PARTNERS @flag='partner'", "agentId", "agentName", "", "Select Partner");
            //sl.SetDDL(ref partner,"Exec ")
        }
        private string GetRefId()
        {
            return GetStatic.ReadQueryString("referral_id", "");
        }
        public string GetRefCode()
        {
            hdnReferralCode.Value = GetStatic.ReadQueryString("referralCode", "");
            return hdnReferralCode.Value;
        }
        private string GetPartnerId()
        {
            return GetStatic.ReadQueryString("partnerId", "");
        }
        private string EditOrNot()
        {
            return GetStatic.ReadQueryString("edit", "");
        }

        protected void save_Click(object sender, EventArgs e)
        {
            try
            {
                string partner = partnerDDL.SelectedValue;
                string commissionPercent = commPercent.Text;
                string forexPercent = fxPercent.Text;
                string flatTransactionWise = flatTxnWise.Text;
                string nCustomer = newCustomer.Text;
                string efrom = effectiveFrom.Text;
                string active = isActive.SelectedValue;
                string deductTaxOnSC = deductTaxOnSc.SelectedValue;
                string deductPCommOnSC = deductPCommOnSc.SelectedValue;
                //int a = GetRefId().ToString().ToInt();
                CommissionModel cm = new CommissionModel() {
                    PartnerId = partnerDDL.SelectedValue.ToInt(),
                    CommissionPercent = commPercent.Text.ToDecimal(),
                    ForexPercent = fxPercent.Text.ToDecimal(),
                    FlatTxnWise = flatTxnWise.Text.ToDecimal(),
                    NewCustomer = newCustomer.Text.ToDecimal(),
                    EffectiveFrom = DateTime.Parse(effectiveFrom.Text),
                    isActive = bool.Parse(isActive.SelectedValue.ToString() == "0" ? "false" : "true"),
                    ReferralId = GetRefId(),
                    ReferralCode = GetRefCode(),
                    ROW_ID = GetRowId(),
                    deductTaxOnSC = deductTaxOnSC,
                    deductPCommOnSC = deductPCommOnSC
                };
                var res = _refDao.SaveCommissionData(GetStatic.GetUser(), cm,EditOrNot());
                GetStatic.SetMessage(res);
                string url = "CommissionRuleList.aspx?referralCode=" + GetRefCode() + "";
                Response.Redirect(url);
            }
            catch (Exception ex)
            {
                GetStatic.AlertMessage(this.Page, ex.Message);
            }



            
        }

        private string GetRowId()
        {
            return GetStatic.ReadQueryString("row_id", "");
        }
    }
}