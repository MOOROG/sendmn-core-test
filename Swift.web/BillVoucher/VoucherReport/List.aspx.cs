using Swift.web.Library;
using System;

namespace Swift.web.BillVoucher.VoucherReport
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101600";
        private RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref vNum);
                Authenticate();
                PopulateDDL();
            }
        }

        private void PopulateDDL()
        {
            _sl.SetDDL(ref typeDDL, "EXEC Proc_dropdown_remit @FLAG='voucherDDL'", "value", "functionName", "", "");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}