using Swift.DAL.Remittance.APIPartner;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.APIPartners
{
    public partial class AddApiPartner : System.Web.UI.Page
    {
        private string ViewFunctionId = "20191200";
        private string AddEditFunctionId = "20191210";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly APIPartnerDao _apiDao = new APIPartnerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref minTxnLimit);
                Misc.MakeNumericTextbox(ref maxTxnLimit);
                Authenticate();
                PopulateDDL();
                if (GetId() != "")
                {
                    PopulateData();
                }
            }
        }

        private void PopulateDDL()
        {
            _sl.SetDDL(ref countryDDL, "EXEC proc_sendPageLoadData @flag='pCountry'", "countryId", "countryName", "", "Select Country");
            _sl.SetDDL(ref partnerDDL, "EXEC PROC_API_ROUTE_PARTNERS @flag='partner'", "agentId", "agentName", "", "Select Partner");
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
            DataRow dr = _apiDao.GetData(GetId(), GetStatic.GetUser());

            if (dr == null)
            {
                Response.Redirect("RouteApiPartners.aspx");
            }

            partnerDDL.SelectedValue = dr["AgentId"].ToString();
            countryDDL.SelectedValue = dr["CountryId"].ToString();
            PopulateLimtCurrency();
            isActiveDDL.SelectedValue = (dr["IsActive"].ToString() == "True" || dr["IsActive"].ToString() == "1") ? "1" : "0";
            IsRealTimeDDL.SelectedValue = (dr["isRealTime"].ToString() == "True" || dr["isRealTime"].ToString() == "1") ? "1" : "0";
            minTxnLimit.Text = GetStatic.ShowDecimal(dr["minTxnLimit"].ToString());
            maxTxnLimit.Text = GetStatic.ShowDecimal(dr["maxTxnLimit"].ToString());
            ddlLimitCurrency.SelectedValue = dr["LimitCurrency"].ToString();
            exRateCalcByPartner.SelectedValue = (dr["exRateCalByPartner"].ToString() == "True" || dr["exRateCalByPartner"].ToString() == "1") ? "1" : "0";
            isACValidateSupport.SelectedValue = (dr["isACValidateSupport"].ToString() == "True" || dr["isACValidateSupport"].ToString() == "1") ? "1" : "0";
            PopulatePayoutModeDDL(dr["PaymentMethod"].ToString());
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var tst1 = maxTxnLimit.Text.ToString();
            string flag = string.IsNullOrEmpty(GetId()) ? "i" : "u";

            var tst = minTxnLimit.Text;
            DbResult _dbRes = _apiDao.InsertUpdate(flag, partnerDDL.SelectedValue, countryDDL.SelectedValue, payoutMethodDDL.SelectedValue,
                                                            isActiveDDL.SelectedValue, GetStatic.GetUser(), GetId(), IsRealTimeDDL.SelectedValue, minTxnLimit.Text.ToString(), maxTxnLimit.Text.ToString(), ddlLimitCurrency.SelectedValue, exRateCalcByPartner.SelectedValue, isACValidateSupport.SelectedValue);

            if (_dbRes.ErrorCode != "0")
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
            GetStatic.SetMessage(_dbRes);
            Response.Redirect("RouteApiPartners.aspx");
        }

        protected string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        protected void countryDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulatePayoutModeDDL();
            PopulateLimtCurrency();
        }

        private void PopulatePayoutModeDDL(string selectedValue = "")
        {
            string sql = "PROC_API_ROUTE_PARTNERS @flag='payout-method', @countryId = " + _sl.FilterString(countryDDL.SelectedValue);
            _sl.SetDDL(ref payoutMethodDDL, sql, "serviceTypeId", "typeTitle", selectedValue, "All");
        }

        private void PopulateLimtCurrency(string selectedValue = "")
        {
            string sql = "EXEC PROC_API_ROUTE_PARTNERS @flag='limit-currency', @countryId = " + _sl.FilterString(countryDDL.SelectedValue);
            _sl.SetDDL(ref ddlLimitCurrency, sql, "currencyCode", "currencyCode", selectedValue, "Select Limit Currency");
        }
    }
}