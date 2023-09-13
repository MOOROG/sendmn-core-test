using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;

namespace Swift.web.include
{
    public partial class DeleteLedger : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            DoDelete();
        }

        private void DoDelete()
        {
            if (GetDeleteTran() == "y")
            {
                var dbResult = _obj.DeleteLedger(GetId(), GetStatic.GetUser());
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
            else
            {
                var dbResult = _obj.DeleteAccount(GetId(), GetStatic.GetUser());
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }

        private string GetId()
        {
            return GetStatic.ReadQueryString("delrowid", "");
        }

        private string GetDeleteTran()
        {
            return GetStatic.ReadQueryString("deltrn", "");
        }
    }
}