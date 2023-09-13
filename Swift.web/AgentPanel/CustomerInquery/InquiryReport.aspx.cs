using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.CustomerInquery
{
    public partial class InquiryReport : System.Web.UI.Page
    {
        private RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                startDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }
    }
}