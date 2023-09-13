using System;

namespace Swift.web.KJBank
{
    public partial class AutoDebitTransaction : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            startDate.Text = DateTime.Today.ToString("d");
            toDate.Text = DateTime.Today.ToString("d");
        }
    }
}