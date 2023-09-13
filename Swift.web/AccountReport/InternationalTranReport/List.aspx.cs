using System;

namespace Swift.web.AccountReport.InternationalTranReport
{
    public partial class List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            sfromDate.Text = DateTime.Now.ToString("d");
            stoDate.Text = DateTime.Now.ToString("d");
            rfromDate.Text = DateTime.Now.ToString("d");
            rtoDate.Text = DateTime.Now.ToString("d");
            mtodate.Text = DateTime.Now.ToString("d");
            mfromdate.Text = DateTime.Now.ToString("d");
        }
    }
}