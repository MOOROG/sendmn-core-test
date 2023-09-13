using Swift.DAL.Remittance.Transaction;
using Swift.web.Library;
using System;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.International.SendOnBehalf
{
    public partial class Calculator : System.Web.UI.Page
    {
        private TranCalculator st = new TranCalculator();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                populateCollCurr();
                PopulateDdl();
                //Misc.MakeNumericTextbox(ref txtCollAmt);
                Misc.MakeNumericTextbox(ref txtPayAmt);
            }
        }

        private void populateCollCurr()
        {
            string currencyCode = st.GetCollCurrency(GetStatic.GetUser(), GetStatic.GetCountryId());
            lblCollCurr.Text = currencyCode;
            lblSendCurr.Text = currencyCode;
            lblServiceChargeCurr.Text = currencyCode;
        }

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("pCountry", "");
        }

        private string GetMode()
        {
            return GetStatic.ReadQueryString("pMode", "");
        }

        private string GetAgent()
        {
            return GetStatic.ReadQueryString("pAgent", "");
        }

        private void PopulateDdl()
        {
            LoadRecCountry(ref pCountry, GetCountry(), "Select");
            LoadReceivingMode(GetMode());
            LoadReceivingAgent(GetAgent());
        }

        private void LoadRecCountry(ref DropDownList ddl, string defaultValue, string label)
        {
            var sql = "EXEC proc_sendPageLoadData @flag='pCountry', @countryId='" + GetStatic.GetCountryId() + "', @agentid='" + GetStatic.GetAgentId() + "'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
        }

        protected void Calculate()
        {
            string pAgentFv = Request.Form["pAgent"];
            var calculateBy = "";
            if (txtPayAmt.Enabled)
                calculateBy = "pAmt";
            else if (txtCollAmt.Enabled)
                calculateBy = "cAmt";

            string currencyCode = st.GetCollCurrency(GetStatic.GetUser(), GetStatic.GetCountryId());
            var dt = st.GetExRate(GetStatic.GetUser(), GetStatic.GetSuperAgent(), GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch(),
                                 currencyCode, pCountry.Text, pAgentFv, "", pMode.Text, txtCollAmt.Text, txtPayAmt.Text, calculateBy);
            var dr = dt.Rows[0];
            lblPayCurr.Text = "";
            lblSendAmt.Text = "0.00";
            lblServiceChargeAmt.Text = "0.00";
            lblExRate.Text = "0.00";
            if (dr["ErrCode"].ToString() == "1")
            {
                GetStatic.AlertMessage(Page, dr["Msg"].ToString());
                return;
            }

            txtCollAmt.Text = dr["CollAmt"].ToString();
            //txtCollAmt.Text = txtCollAmt.Text.Substring(0, txtCollAmt.Text.Length - cDecimal);
            txtPayAmt.Text = dr["pAmt"].ToString();
            txtPayAmt.Text = txtPayAmt.Text.Substring(0, txtPayAmt.Text.Length - 2);
            lblPayCurr.Text = dr["pCurr"].ToString();
            lblExCurr.Text = dr["pCurr"].ToString();
            lblSendAmt.Text = dr["sAmt"].ToString();
            lblServiceChargeAmt.Text = GetStatic.ShowDecimal(dr["scCharge"].ToString());
            lblExRate.Text = dr["exRate"].ToString();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(pCountry.Text))
            {
                pMode.Items.Clear();
                return;
            }
            var sql = "EXEC proc_sendPageLoadData @flag ='recModeByCountry'";
            sql += ", @countryId = " + _sdd.FilterString(GetStatic.GetCountryId());
            sql += ", @pCountryId = " + _sdd.FilterString(pCountry.Text);
            sql += ", @param = " + _sdd.FilterString("");
            sql += ", @agentId = " + _sdd.FilterString(GetStatic.GetAgentId());
            sql += ", @user = " + _sdd.FilterString(GetStatic.GetUser());

            _sdd.SetDDL(ref pMode, sql, "serviceTypeId", "typeTitle", "", "Select");
        }

        protected void pMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(pMode.Text))
            {
                pAgent.Items.Clear();
                return;
            }
            string pCountry = Request.Form["pCountry"];
            var sql = "EXEC proc_sendPageLoadData @flag ='recAgentByRecModeAjaxagent'";
            sql += ", @countryId = " + _sdd.FilterString(GetStatic.GetCountryId());
            sql += ", @pCountryId = " + _sdd.FilterString(pCountry);
            sql += ", @param = " + _sdd.FilterString(pMode.SelectedItem.Text);
            sql += ", @agentId = " + _sdd.FilterString(GetStatic.GetAgentId());
            sql += ", @user = " + _sdd.FilterString(GetStatic.GetUser());

            _sdd.SetDDL(ref pAgent, sql, "bankId", "AGENTNAME", "", "");
        }

        private void LoadReceivingMode(string p_Mode)
        {
            var sql = "EXEC proc_sendPageLoadData @flag ='recModeByCountry'";
            sql += ", @countryId = " + _sdd.FilterString(GetStatic.GetCountryId());
            sql += ", @pCountryId = " + _sdd.FilterString(pCountry.Text);
            sql += ", @param = " + _sdd.FilterString("");
            sql += ", @agentId = " + _sdd.FilterString(GetStatic.GetAgentId());
            sql += ", @user = " + _sdd.FilterString(GetStatic.GetUser());

            _sdd.SetDDL(ref pMode, sql, "serviceTypeId", "typeTitle", p_Mode, "Select");
        }

        private void LoadReceivingAgent(string p_agent)
        {
            var sql = "EXEC proc_sendPageLoadData @flag ='recAgentByRecModeAjaxagent'";
            sql += ", @countryId = " + _sdd.FilterString(GetStatic.GetCountryId());
            sql += ", @pCountryId = " + _sdd.FilterString(pCountry.Text);
            sql += ", @param = " + _sdd.FilterString(pMode.SelectedItem.Text);
            sql += ", @agentId = " + _sdd.FilterString(GetStatic.GetAgentId());
            sql += ", @user = " + _sdd.FilterString(GetStatic.GetUser());

            _sdd.SetDDL(ref pAgent, sql, "bankId", "AGENTNAME", p_agent, "");
        }

        protected void btnCalculate_Click(object sender, EventArgs e)
        {
            lblErr.Text = "";
            if (byPayOutAmt.Checked && txtPayAmt.Text == "")
            {
                GetStatic.AlertMessage(Page, "Please, Enter the Payout Amount !");
                lblErr.Text = "Please, Enter the Payout Amount !";
                return;
            }
            if (bySendAmt.Checked && txtCollAmt.Text == "")
            {
                GetStatic.AlertMessage(Page, "Please, Enter the Collection Amount !");
                lblErr.Text = "Please, Enter the Collection Amount !";
                return;
            }

            if (!string.IsNullOrWhiteSpace(txtCollAmt.Text) && Convert.ToDouble(txtCollAmt.Text) > 0)
                Calculate();
            else if (!string.IsNullOrWhiteSpace(txtPayAmt.Text) && Convert.ToDouble(txtPayAmt.Text) > 0)
                Calculate();
            else
            {
                lblPayCurr.Text = "0.00";
                lblSendAmt.Text = "0.00";
                lblServiceChargeAmt.Text = "0.00";
                lblExRate.Text = "0.00";
                GetStatic.AlertMessage(Page, "Need Collection Amount or Payout Amount For Calculation");
            }
        }

        protected void bySendAmt_CheckedChanged(object sender, EventArgs e)
        {
            txtCollAmt.Enabled = true;
            txtPayAmt.Enabled = false;
            txtPayAmt.Text = "";
        }

        protected void byPayOutAmt_CheckedChanged(object sender, EventArgs e)
        {
            txtCollAmt.Enabled = false;
            txtPayAmt.Enabled = true;
            txtCollAmt.Text = "";
        }
    }
}