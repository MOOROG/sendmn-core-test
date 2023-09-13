using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports
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