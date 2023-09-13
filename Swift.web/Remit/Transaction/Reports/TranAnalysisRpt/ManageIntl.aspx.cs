using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.TranAnalysisRpt
{
    public partial class ManageIntl : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20162300";
        private const string ViewNewRptFunctionId = "20162310";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {  
            _sl.CheckSession();
            Authenticate();
            if (!IsPostBack)
            {
                if (_sl.HasRight(ViewNewRptFunctionId))
                    btnNew.Visible = true;
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        public void PopulateDdl()
        {
            _sdd.SetDDL(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "typeTitle", "typeTitle", "", "All"); 
            _sdd.SetDDL(ref sAgentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All");
            _sdd.SetDDL(ref rAgentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All"); 
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}