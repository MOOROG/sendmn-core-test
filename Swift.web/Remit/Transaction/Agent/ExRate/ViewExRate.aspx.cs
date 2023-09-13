using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ExRate
{
    public partial class ViewExRate : Page
    {
        private const string ViewFunctionId = "40131000";

        private SwiftLibrary swiftLibrary = new SwiftLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly ExRateDao _dao = new ExRateDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                result.Visible = false;
                PopulateDdl();

            }
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
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
            DataRow dr = _dao.View(GetStatic.GetUser(), GetStatic.GetAgentId(), collCurrency.SelectedItem.Text,
                             payCountry.Text, payCurrency.SelectedItem.Text, txnType.Text);
            if (dr == null)
                return;

            result.Visible = true;
            cCurrency.Text = dr["cCurrency"].ToString();
            pCountry.Text = dr["pCountry"].ToString();
            pCurrency.Text = dr["pCurrency"].ToString();
            tranType.Text = dr["tranType"].ToString();
            customerRate.Text = dr["customerCrossRate"].ToString();
        }


        protected void sendCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if(collCurrency.Text!="")

        }

        protected void payCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (payCountry.Text != "")
                sdd.SetDDL(ref payCurrency, "EXEC proc_countryCurrency @flag = 'lByName', @countryName = '" + payCountry.SelectedItem.Text + "'", "currencyId", "currencyCode", "", "Select");
        }
    }
}