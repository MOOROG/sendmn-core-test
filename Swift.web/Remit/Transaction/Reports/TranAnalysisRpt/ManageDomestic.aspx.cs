using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.TranAnalysisRpt
{
    public partial class ManageDomestic : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20162300";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            fromDate.ReadOnly = true;
            toDate.ReadOnly = true;
            _sl.CheckSession();
            Authenticate();
            if (!IsPostBack) 
            {
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        public void PopulateDdl() 
        {
            _sdd.SetDDL(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "typeTitle", "typeTitle", "", "All");
            _sdd.SetDDL(ref remitProduct, "EXEC [proc_dropDownLists] @flag='remitProduct'", "value", "text", "", "All");
            _sdd.SetDDL(ref sAgentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All");
            _sdd.SetDDL(ref rAgentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All"); 
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}