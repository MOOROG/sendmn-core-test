using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.ReferralSchemeReport
{
    public partial class ReferralSchemaReport : System.Web.UI.Page
    {
      private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        //private const string ViewFunctionId = "2021900";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                startDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
                startDate.Attributes.Add("readonly", "readonly");
                toDate.Attributes.Add("readonly", "readonly");
               
            }
        }
       
        private void Authenticate()
        {
           // _sdd.CheckAuthentication(ViewFunctionId);
        }

    }
}