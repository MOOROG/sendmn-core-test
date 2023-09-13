using System;

namespace Swift.web.AccountReport.DailySettlemetReport
{
    public partial class DailySettlementRpt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                startDate.Attributes.Add("readonly", "readonly");
                startDate.Text = DateTime.Now.ToString("d");
                toDate.Attributes.Add("readonly", "readonly");
                toDate.Text = DateTime.Now.ToString("d");
            }
        }
    }
}