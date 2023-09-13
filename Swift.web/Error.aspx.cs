using Swift.web.Library;
using System;

namespace Swift.web
{
    public partial class Error : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            errLogId.Text = GetStatic.ReadNumericDataFromQueryString("id").ToString();
        }
    }
}