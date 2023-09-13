using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.DayBook
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101200";
        private RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                startDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                startDate2.Text = DateTime.Today.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                toDate2.Text = DateTime.Today.ToString("yyyy-MM-dd");
                populateDdl();
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void populateDdl()
        {
            _sl.SetDDL(ref userName, "EXEC Proc_dropdown_remit @flag='AdminName'", "userId", "name", "", "All");
        }
    }
}