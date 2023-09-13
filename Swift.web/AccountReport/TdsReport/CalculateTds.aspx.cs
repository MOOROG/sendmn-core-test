using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.TdsReport
{
    public partial class CalculateTds : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150600";
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
                voucherDate.Text = DateTime.Now.ToString("d");
                //fromDate.ReadOnly = true;
                //toDate.ReadOnly = true;
                //voucherDate.ReadOnly = true;
            }
            sqlMsg.InnerHtml = "";
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnTds_Click(object sender, EventArgs e)
        {
            VoucherGeneration Dao = new VoucherGeneration();
            var fDate = fromDate.Text;
            var tDate = toDate.Text;
            var vDate = voucherDate.Text;
            var result = Dao.CalculateTdsAgent(fDate, tDate, vDate, GetStatic.GetUser());

            sqlMsg.Visible = true;
            sqlMsg.InnerHtml = result.Msg;
        }
    }
}