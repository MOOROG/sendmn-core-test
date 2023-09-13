using Swift.DAL.Remittance.APIPartner;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.Transaction.PromotionalCampaign
{
    public partial class Manage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20320000";
        private string AddEditFunctionId = "20320020";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly APIPartnerDao _apiDao = new APIPartnerDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref promotionAmount);
                startDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                endDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
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
            _sdd.SetStaticDdl(ref ddlPromotionType, "8102", "", "Select Promotion Type");
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
            DataRow dr = _apiDao.GetDataPromotion(GetId(), GetStatic.GetUser());

            if (dr == null)
            {
                Response.Redirect("List.aspx");
            }

            countryDDL.SelectedValue = dr["COUNTRY_ID"].ToString();
            isActiveDDL.SelectedValue = (dr["IS_ACTIVE"].ToString() == "True" || dr["IS_ACTIVE"].ToString() == "1") ? "1" : "0";
            ddlPromotionType.SelectedValue = dr["PROMOTION_TYPE"].ToString();
            promotionCode.Text = dr["PROMOTIONAL_CODE"].ToString();
            promotionMsg.Text = dr["PROMOTIONAL_MSG"].ToString();
            promotionAmount.Text = GetStatic.ShowDecimal(dr["PROMOTION_VALUE"].ToString());
            startDate.Text = dr["START_DATE"].ToString();
            endDate.Text = dr["END_DATE"].ToString();
            PopulatePayoutModeDDL(dr["PAYMENT_METHOD"].ToString());
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string flag = string.IsNullOrEmpty(GetId()) ? "i" : "u";

            DbResult _dbRes = _apiDao.InsertUpdatePromotion(GetStatic.GetUser(), flag, GetId(), promotionCode.Text, promotionMsg.Text,
                                ddlPromotionType.SelectedValue, countryDDL.SelectedValue, payoutMethodDDL.SelectedValue, isActiveDDL.SelectedValue,
                                startDate.Text, endDate.Text, promotionAmount.Text);

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

        protected void countryDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulatePayoutModeDDL();
        }

        private void PopulatePayoutModeDDL(string selectedValue = "")
        {
            string sql = "PROC_API_ROUTE_PARTNERS @flag='payout-method', @countryId = " + _sl.FilterString(countryDDL.SelectedValue);
            _sl.SetDDL(ref payoutMethodDDL, sql, "serviceTypeId", "typeTitle", selectedValue, "All");
        }
    }
}