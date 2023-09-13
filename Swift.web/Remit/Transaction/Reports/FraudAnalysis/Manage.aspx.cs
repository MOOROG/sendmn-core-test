using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.FraudAnalysis
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        private readonly string ViewFunctionId = "10122100";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            PopulateDDl();
            Misc.MakeIntegerTextbox(ref count, true, true);
            Misc.MakeIntegerTextbox(ref ipcount, true, true);
            SetDate();
        }
        private void PopulateDDl()
        {
            sdd.SetDDL3(ref country, "EXEC proc_countryMaster 'ocl'", "countryId", "countryName", "", "All");
            sdd.SetDDL3(ref sTxnCountry, "EXEC proc_countryMaster 'ocl'", "countryName", "countryName", "", "All");
            sdd.SetDDL3(ref rTxnCountry, "EXEC proc_countryMaster 'ocl'", "countryName", "countryName", "", "All");
        }
        private void Authenticate()
        { 
            var swiftLibrary = new SwiftLibrary(); 
            swiftLibrary.CheckAuthentication(ViewFunctionId);            
        }

        public void SetDate()
        {
            var curDate = DateTime.Now;
            var dateString = curDate.ToString("yyyy-MM-dd");
            fromDate.Text = dateString;
            toDate.Text = dateString;
            fromTxnDate.Text = dateString;
            toTxnDate.Text = dateString;
        }
    }
}