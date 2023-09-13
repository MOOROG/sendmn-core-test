using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;

namespace Swift.web.KJBank.CustomerSetup
{
    public partial class FundStatement_Customer : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                _sdd.SetDDL(ref ddlSearchType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
                //_sl.SetDDL(ref SearchType, "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'", "value", "text", "", "");
            }
        }
    }
}