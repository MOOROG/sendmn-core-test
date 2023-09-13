using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.AccountReport
{
    public partial class EOD : System.Web.UI.Page
    {
        private string ViewFunctionId = "20180000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private AccountStatementDAO cavDao = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void Transfer_Click(object sender, EventArgs e)
        {
            DbResult _dbRes = cavDao.PerformEOD(GetStatic.GetUser());
            GetStatic.AlertMessage(this, _dbRes.Msg);
        }
    }
}