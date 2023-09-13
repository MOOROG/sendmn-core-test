using System;
using Swift.web.Library;
using Swift.API.Common;
using Swift.DAL.RiskBasedAssessment;
using Swift.API.TPAPIs.CancelTPTxn;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Dynamic;

namespace Swift.web.Remit.Transaction.CancelTPTxn
{
    public partial class CancelTPTxn : System.Web.UI.Page
    {
        GetStatusResponse getStatus = new GetStatusResponse();
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        RiskBasedAssessmentDao _rbaDao = new RiskBasedAssessmentDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDDL();
            }
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref Provider, "EXEC proc_CancelTPTxn @FLAG='provider'", "value", "text", "", "");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            WingApiService wingService = new WingApiService();
            
            getStatus = wingService.GetStatusWing(ControlNo.Text, Provider.SelectedValue);

            string result = GetStatic.SerializeToJson(getStatus, true);
            if (!string.IsNullOrEmpty(result))
            {
                rptGrid.Visible = true;
                rptGrid.InnerText = result;
            }
        }
    }
}