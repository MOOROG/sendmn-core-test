using Swift.web.Library;
using System;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class CalculateMargin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadData();
        }

        private void LoadData()
        {
            cRate.InnerHtml = GetStatic.ReadQueryString("cRate", "");
            cMargin.InnerHtml = GetStatic.ReadQueryString("cMargin", "");
            cHoMargin.Text = GetStatic.ReadQueryString("cHoMargin", "");
            cAgentOffer.InnerHtml = GetStatic.ReadQueryString("cAgentOffer", "");
            cAgentMargin.Text = GetStatic.ReadQueryString("cAgentMargin", "");
            cCustomerOffer.InnerHtml = GetStatic.ReadQueryString("cCustomerOffer", "");

            pRate.InnerHtml = GetStatic.ReadQueryString("pRate", "");
            pMargin.InnerHtml = GetStatic.ReadQueryString("pMargin", "");
            pHoMargin.Text = GetStatic.ReadQueryString("pHoMargin", "");
            pAgentOffer.InnerHtml = GetStatic.ReadQueryString("pAgentOffer", "");
            pAgentMargin.Text = GetStatic.ReadQueryString("pAgentMargin", "");
            pCustomerOffer.InnerHtml = GetStatic.ReadQueryString("pCustomerOffer", "");

            toleranceOn.InnerHtml = GetStatic.ReadQueryString("toleranceOn", "");
            customerRate.Text = GetStatic.ReadQueryString("customerRate", "");
            agentCrossRateMargin.Text = GetStatic.ReadQueryString("agentCrossRateMargin", "");

            hddCustomerRate.Value = GetStatic.ReadQueryString("customerRate", "");
            hddAgentRate.Value = GetStatic.ReadQueryString("agentRate", "");
        }
    }
}