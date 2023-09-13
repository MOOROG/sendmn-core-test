using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.StockPosition
{
    public partial class MultiCurrencyClosingRpt : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140300";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                sl.CheckAuthentication(ViewFunctionId);
                asOnDate.Text = DateTime.Now.ToString("yyyy-MM-dd");//08/22/2018
                loadDdl();
            }
        }

        private void loadDdl()
        {
            sl.SetDDL(ref partner, "EXEC PROC_MULTICURRENCYCLOSINGREPORT @flag='ddlAccountNo',@user='" + GetStatic.GetUser() + "'", "id", "text", "", "select");
        }
    }
}