using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.AgentRateSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private DefExRateDao obj = new DefExRateDao();
        private StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "30012400";
        private const string AddEditFunctionId = "30012410";
        private const string DeleteFunctionId = "30012420";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        #region Method

        private void MakeNumericTextBox()
        {
            cMargin.Text = "0";
            pMargin.Text = "0";
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("defExRateId");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        #region PopulateDropDown

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetDDL(ref baseCurrency, "EXEC proc_currencyMaster 'bc'", "currencyId", "currencyCode", GetStatic.GetRowData(dr, "baseCurrency"), "");
            _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'ocl'", "countryId", "countryName", "", "Select");
            LoadAgent(ref agent, country.Text);
            LoadCurrency(ref currency, country.Text);
        }

        #endregion PopulateDropDown

        private void PopulateDataById()
        {
        }

        private void Update()
        {
            var dbResult = obj.Update(GetStatic.GetUser()
                                    , GetId().ToString()
                                    , "AG"
                                    , currency.SelectedItem.Text
                                    , country.Text
                                    , agent.Text
                                    , baseCurrency.SelectedItem.Text
                                    , factor.Text
                                    , cRate.Text
                                    , cMargin.Text
                                    , ""
                                    , ""
                                    , pRate.Text
                                    , pMargin.Text
                                    , ""
                                    , ""
                                    , "Y");
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        private void LoadAgent(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        private void LoadCurrency(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_countryCurrency @flag='cl', @countryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", "", "Select");
        }

        private string GetOperationType(string countryId)
        {
            var sql = "EXEC proc_countryMaster @flag = 'ot', @countryId = " + _sdd.FilterString(countryId);
            return obj.GetSingleResult(sql);
        }

        private void ShowHidePanel(string countryId)
        {
            switch (GetOperationType(countryId))
            {
                case "B":
                    panelCollectionRate.Visible = true;
                    panelPaymentRate.Visible = true;
                    break;

                case "S":
                    panelCollectionRate.Visible = true;
                    break;

                case "R":
                    panelPaymentRate.Visible = true;
                    break;

                default:
                    panelCollectionRate.Visible = false;
                    panelPaymentRate.Visible = false;
                    break;
            }
        }

        #endregion Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref agent, country.Text);
            LoadCurrency(ref currency, country.Text);
            ShowHidePanel(country.Text);
            country.Focus();
        }

        protected void currency_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetRateMask();
            currency.Focus();
        }

        private void GetRateMask()
        {
            DataRow dr = obj.SelectRateMask(GetStatic.GetUser(), currency.Text, factor.Text);
            if (dr == null)
                return;

            maskBD.Value = dr["maskBD"].ToString();
            maskAD.Value = dr["maskAD"].ToString();
            hddTolCMin.Value = dr["cMin"].ToString();
            hddTolCMax.Value = dr["cMax"].ToString();
            hddTolPMin.Value = dr["pMin"].ToString();
            hddTolPMax.Value = dr["pMax"].ToString();
            cRate.Attributes.Add("onblur", "CalcCollectionOfferMask(this," + maskBD.Value + "," + maskAD.Value + ")");
            pRate.Attributes.Add("onblur", "CalcPaymentOfferMask(this," + maskBD.Value + "," + maskAD.Value + ")");
            cMargin.Attributes.Add("onblur", "CalcCollectionOfferMask(this," + maskBD.Value + "," + maskAD.Value + ")");
            pMargin.Attributes.Add("onblur", "CalcPaymentOfferMask(this," + maskBD.Value + "," + maskAD.Value + ")");
        }
    }
}