using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.RemitCalculator
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "40131000";

        private RemittanceLibrary remitLibrary = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemitCalculatorDao calDao=new RemitCalculatorDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeNumericTextbox(ref amount);
                Misc.MakeNumericTextbox(ref amountRec);
                result.Visible = false;
                PopulateDdl();
                
            }
        }
        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            sdd.SetDDL(ref collCurrency, "EXEC proc_remitCalculator @flag='a',@agentId='" + GetStatic.GetAgentId() + "',@user='" + GetStatic.GetUser() + "'", "currencyId", "currencyCode", "", "Select");
            sdd.SetDDL(ref payCountry, "EXEC proc_rsList1 @flag = 'pcl', @agentId = '" + GetStatic.GetAgentId() + "'", "countryId", "countryName", "", "Select");
            sdd.SetDDL(ref txnType, "EXEC proc_serviceTypeMaster 'l2'", "serviceTypeId", "typeTitle", "", "Select");
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            ShowDetail();
        }

        private void ShowDetail()
        {
            DataRow dr = calDao.Calculate(GetStatic.GetUser(), GetStatic.GetAgentId(), collCurrency.SelectedItem.Text,
                             payCountry.Text, payCurrency.SelectedItem.Text, txnType.Text, amount.Text,amountRec.Text);
            if (dr == null)
                return;

            result.Visible = true;
            cCurrency.Text = dr["collCurr"].ToString();
            pCountry.Text = dr["countryName"].ToString();
            pCurrency.Text = dr["payCurr"].ToString();
            tranType.Text=dr["tranType"].ToString();
            rate.Text = dr["rate"].ToString();
            amountToSend.Text = dr["sendAmt"].ToString();
            amountToReceive.Text = dr["recAmount"].ToString();
            fee.Text = dr["Fee"].ToString();

        }


        protected void sendCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if(collCurrency.Text!="")
                
        }
        
        protected void payCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(payCountry.Text!="")
                sdd.SetDDL(ref payCurrency, "EXEC proc_countryCurrency @flag = 'lByName', @countryName = '" + payCountry.SelectedItem.Text + "'", "currencyId", "currencyCode", "", "Select");
        }

        protected void amount_TextChanged(object sender, EventArgs e)
        {
            if (amount.Text != "" )
            {
                amountRec.Enabled = false;
                RequiredFieldValidator5.Enabled = false;
            }
            if (amount.Text == "0")
            {
                amountRec.Enabled = true;
                RequiredFieldValidator5.Enabled = true;
            }
        }

        protected void amountRec_TextChanged(object sender, EventArgs e)
        {
            if (amountRec.Text != "")
            {
                amount.Enabled = false;
                RequiredFieldValidator3.Enabled = false;
            }
            if (amountRec.Text == "0")
            {
                amount.Enabled = true;
                RequiredFieldValidator3.Enabled = true;
            }
        }

    }
}