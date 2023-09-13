using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class Manage : System.Web.UI.Page
    {
        private ExRateTreasuryDao obj = new ExRateTreasuryDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string ViewFunctionId = "30012300";
        private const string AddEditFunctionId = "30012310";
        private const string DeleteFunctionId = "30012320";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDdl();
                LoadTab();
                SetDefaultValue();
            }
            agentTolMax.Attributes.Add("onblur", "CalcRate()");
        }

        protected string GetIsFw()
        {
            return GetStatic.ReadQueryString("isFw", "");
        }

        private void LoadTab()
        {
            var isFw = GetIsFw();

            var queryStrings = "?isFw=" + isFw;
            _tab.NoOfTabPerRow = 8;
            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Treasury Rate", "List.aspx" + queryStrings),
                                   new TabField("Add New", "", true),
                                   new TabField("Approve", "ApproveList.aspx" + queryStrings),
                                   new TabField("Reject", "RejectList.aspx" + queryStrings),
                                   new TabField("My changes", "MyChangeList.aspx" + queryStrings),
                                   new TabField("Copy Rate", "CopyAgentWiseRate.aspx" + queryStrings),
                               };

            divTab.InnerHtml = _tab.CreateTab();
        }

        #region Method

        private void SetDefaultValue()
        {
            cHoMargin.Text = "0";
            cAgentMargin.Text = "0";
            pHoMargin.Text = "0";
            pAgentMargin.Text = "0";

            agentTolMin.Text = "0";
            agentTolMax.Text = "0";
            customerTolMin.Text = "0";
            customerTolMax.Text = "0";
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref agentTolMin);
            Misc.MakeNumericTextbox(ref agentTolMax);
            Misc.MakeNumericTextbox(ref customerTolMin);
            Misc.MakeNumericTextbox(ref customerTolMax);
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("exRateTreasuryId");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        #region PopulateDropDown

        private void PopulateDdl()
        {
            LoadSendingCountry(ref cCountry);
            LoadReceivingCountry(ref pCountry);
            LoadAgent(ref cAgent, cCountry.Text);
            LoadAgent(ref pAgent, pCountry.Text);
            LoadCurrency(ref cCurrency, cCountry.Text);
            LoadCurrency(ref pCurrency, pCountry.Text);
        }

        #endregion PopulateDropDown

        private void Update()
        {
            //var effectiveFrom = GetDateTime(effectiveFromDate.Text, effectiveFromTime.Text);
            //var effectiveTo = GetDateTime(effectiveToDate.Text, effectiveToTime.Text);

            var dbResult = obj.Insert(GetStatic.GetUser(), tranType.Text, cCurrency.Text, cCountry.Text, cAgent.Text, pCurrency.Text,
                                      pCountry.Text, pAgent.Text, agentTolMax.Text,
                                      cHoMargin.Text, cAgentMargin.Text, pHoMargin.Text, pAgentMargin.Text, sharingType.Text, sharingValue.Text,
                                      toleranceOn.Text, agentTolMin.Text, agentTolMax.Text, customerTolMin.Text, customerTolMax.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            GetStatic.WriteSession("exRateTreasuryIds", dbResult.Id);
            Response.Redirect("ModifySummary.aspx");
            /*
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.AlertMessage(Page);
            }
             * */
        }

        private void LoadSendingCountry(ref DropDownList ddl)
        {
            var sql = "EXEC proc_countryMaster @flag = 'scl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", "", "Select");
        }

        private void LoadReceivingCountry(ref DropDownList ddl)
        {
            var sql = "EXEC proc_countryMaster @flag = 'rclNepalOnly'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", "", "Select");
        }

        private void LoadCurrency(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_countryCurrency @flag='cl', @countryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", "", "Select");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        private void LoadTranType(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + _sdd.FilterString(pCountry.Text);
            _sdd.SetDDL(ref tranType, sql, "serviceTypeId", "typeTitle", "", "Any");
        }

        private void LoadCurrencyRate(string currencyCode, string countryId, string agentId, string rateType)
        {
            var dr = obj.SelectCurrencyRate(GetStatic.GetUser(), currencyCode, countryId, agentId, rateType);
            if (dr == null)
            {
                switch (rateType)
                {
                    case "C":
                        cRate.Text = "";
                        cMargin.Text = "";
                        cOffer.Text = "";
                        cRateFactor.Value = "";
                        lblCRateFactor.Text = "";
                        break;

                    case "P":
                        pRate.Text = "";
                        pMargin.Text = "";
                        pOffer.Text = "";
                        pRateFactor.Value = "";
                        lblPRateFactor.Text = "";
                        break;
                }
                return;
            }
            var costRate = 0.0;
            var margin = 0.0;
            switch (rateType)
            {
                case "C":
                    cRate.Text = dr["costRate"].ToString();
                    cMargin.Text = dr["margin"].ToString();
                    costRate = Convert.ToDouble(dr["costRate"]);
                    margin = Convert.ToDouble(dr["margin"]);
                    cRateFactor.Value = dr["factor"].ToString();
                    lblCRateFactor.Text = dr["factorName"].ToString();
                    switch (cRateFactor.Value)
                    {
                        case "M":
                            {
                                var offer = costRate + margin;
                                cOffer.Text = offer.ToString();
                            }
                            break;

                        case "D":
                            {
                                var offer = costRate - margin;
                                cOffer.Text = offer.ToString();
                            }
                            break;
                    }
                    break;

                case "P":
                    pRate.Text = dr["costRate"].ToString();
                    pMargin.Text = dr["margin"].ToString();
                    costRate = Convert.ToDouble(dr["costRate"]);
                    margin = Convert.ToDouble(dr["margin"]);
                    pRateFactor.Value = dr["factor"].ToString();
                    lblPRateFactor.Text = dr["factorName"].ToString();
                    switch (cRateFactor.Value)
                    {
                        case "M":
                            {
                                var offer = costRate - margin;
                                pOffer.Text = offer.ToString();
                            }
                            break;

                        case "D":
                            {
                                var offer = costRate + margin;
                                pOffer.Text = offer.ToString();
                            }
                            break;
                    }
                    break;
            }
        }

        #endregion Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void cCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref cAgent, cCountry.Text);
            LoadCurrency(ref cCurrency, cCountry.Text);
            cCountry.Focus();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTranType(ref tranType, pCountry.Text);
            LoadAgent(ref pAgent, pCountry.Text);
            LoadCurrency(ref pCurrency, pCountry.Text);
            pCountry.Focus();
        }

        protected void cAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCurrencyRate(cCurrency.SelectedItem.Text, cCountry.Text, cAgent.Text, "C");
            CalcCrossRates();
            cAgent.Focus();
        }

        protected void pAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCurrencyRate(pCurrency.SelectedItem.Text, pCountry.Text, pAgent.Text, "P");
            CalcCrossRates();
            pAgent.Focus();
        }

        protected void cCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCurrencyRate(cCurrency.SelectedItem.Text, cCountry.Text, cAgent.Text, "C");
            GetCollRateMask();
            GetCrossRateMask();
            CalcCrossRates();
            cCurrency.Focus();
        }

        protected void pCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCurrencyRate(pCurrency.SelectedItem.Text, pCountry.Text, pAgent.Text, "P");
            GetCrossRateMask();
            CalcCrossRates();
            pCurrency.Focus();
        }

        private void CalcCrossRates()
        {
            if (!string.IsNullOrEmpty(cCurrency.Text) && !string.IsNullOrEmpty(pCurrency.Text))
                GetStatic.CallBackJs1(Page, "Calc Cross Rate", "CalcRate();");
        }

        private void GetCrossRateMask()
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'crdm', @cCurrency = " + _sdd.FilterString(cCurrency.Text) +
                      ", @pCurrency = " + _sdd.FilterString(pCurrency.Text);
            rateMaskAd.Value = obj.GetSingleResult(sql);
        }

        protected void btnViewCrossRate_Click(object sender, EventArgs e)
        {
            CalculateCrossRate();
            //MakeNumericTextBox();
        }

        private void CalculateCrossRate()
        {
            pnlCrossRate.Visible = true;
            var cRateVal = Convert.ToDouble(cRate.Text);
            var cOfferVal = Convert.ToDouble(cOffer.Text);
            var cAgentOfferVal = Convert.ToDouble(Convert.ToDecimal(cOfferVal) + Convert.ToDecimal(cHoMargin.Text));
            var cCustomerOfferVal = Convert.ToDouble(Convert.ToDecimal(cOfferVal) + Convert.ToDecimal(cHoMargin.Text) + Convert.ToDecimal(cAgentMargin.Text));

            var pRateVal = Convert.ToDouble(pRate.Text);
            var pOfferVal = Convert.ToDouble(pOffer.Text);
            var pAgentOfferVal = Convert.ToDouble(Convert.ToDecimal(pOfferVal) - Convert.ToDecimal(pHoMargin.Text));
            var pCustomerOfferVal = Convert.ToDouble(Convert.ToDecimal(pOfferVal) - Convert.ToDecimal(pHoMargin.Text) - Convert.ToDecimal(pAgentMargin.Text));

            var afterDecimalValue = string.IsNullOrEmpty(rateMaskAd.Value) ? 0 : Convert.ToInt16(rateMaskAd.Value);
            var cRateBeforeDecimalValue = string.IsNullOrEmpty(maskColBD.Value) ? 0 : Convert.ToInt16(maskColBD.Value);
            var cRateAfterDecimalValue = string.IsNullOrEmpty(maskColAD.Value) ? 0 : Convert.ToInt16(maskColAD.Value);
            var maxCrossRateVal = 0.0;
            var crossRateVal = 0.0;
            var customerRateVal = 0.0;
            var toleranceVal = string.IsNullOrEmpty(agentTolMax.Text) ? 0.0 : Convert.ToDouble(agentTolMax.Text);
            var costVal = 0.0;
            Decimal marginVal = 0;

            maxCrossRateVal = pRateVal / cRateVal;
            maxCrossRateVal = GetStatic.RoundOff(maxCrossRateVal, 0, afterDecimalValue);
            crossRateVal = pAgentOfferVal / cAgentOfferVal;
            crossRateVal = GetStatic.RoundOff(crossRateVal, 0, afterDecimalValue);
            customerRateVal = pCustomerOfferVal / cCustomerOfferVal;
            customerRateVal = GetStatic.RoundOff(customerRateVal, 0, afterDecimalValue);
            costVal = pRateVal / (crossRateVal + toleranceVal);
            costVal = GetStatic.RoundOff(costVal, cRateBeforeDecimalValue, cRateAfterDecimalValue);
            marginVal = Convert.ToDecimal(costVal) - Convert.ToDecimal(cRateVal);

            maxCrossRate.Text = maxCrossRateVal.ToString();
            crossRate.Text = crossRateVal.ToString();
            customerRate.Text = customerRateVal.ToString();
            cost.Text = costVal.ToString();
            margin.Text = marginVal.ToString();
            if (marginVal < 0)
                margin.ForeColor = System.Drawing.Color.Red;
            else
                margin.ForeColor = System.Drawing.Color.Green;

            GetStatic.ResizeFrame(Page);
        }

        private void GetCollRateMask()
        {
            var obj = new DefExRateDao();
            DataRow dr = obj.SelectRateMask(GetStatic.GetUser(), cCurrency.Text, cRateFactor.Value);
            if (dr == null)
                return;

            maskColBD.Value = dr["maskBD"].ToString();
            maskColAD.Value = dr["maskAD"].ToString();
        }

        /*
        private void getPayRateMask()
        {
            DataRow dr = obj.SelectRateMask(GetStatic.GetUser(), pCurrency.Text, pRateFactor.Value);
            if (dr == null)
                return;

            maskPayBD.Value = dr["maskBD"].ToString();
            maskPayAD.Value = dr["maskAD"].ToString();
            pCurrHOMargin.Attributes.Add("onblur", "CalcPaymentOfferMask(this," + maskPayBD.Value + "," + maskPayAD.Value + ")");
            pCurrAgentMargin.Attributes.Add("onblur", "CalcPaymentOfferMask(this," + maskPayBD.Value + "," + maskPayAD.Value + ")");
        }
         * */
    }
}