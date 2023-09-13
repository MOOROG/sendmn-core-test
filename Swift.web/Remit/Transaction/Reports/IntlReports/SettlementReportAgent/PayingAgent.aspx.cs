using Swift.DAL.AccountReport;
using Swift.DAL.Model;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.Reports.IntlReports.SettlementReportAgent
{
    public partial class PayingAgent : System.Web.UI.Page
    {
        private AccountStatementDAO st = new AccountStatementDAO();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private string ViewFunctionId = "20190300";
        protected void Page_Load(object sender, EventArgs e)
        {
            var methodName = GetStatic.ReadFormData("MethodName", "");
            if (methodName.Equals("ViewStatement"))
                GetStatementData();

            Authenticate();
            if (!IsPostBack)
            {
                PopulateDdl();
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                endDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void GetStatementData()
        {
            string fromDate = Request.Form["FromDate"];
            string toDate = Request.Form["ToDate"];
            string accNum = Request.Form["accNum"];
            string accName = Request.Form["accName"];
            string accCurr = Request.Form["accCurr"];
            string type = Request.Form["type"];

            List<StatementModel> result = st.GetACStatementNewAjaxForAgent(accNum, fromDate, toDate, accCurr, type, GetStatic.GetUser());
            GetStatic.JsonResponse(result, this);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            //sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag='sCountry'", "countryId", "countryName", "", "Select");
            //sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list',@param1=" + sdd.FilterString(sCountry.SelectedItem.Text) + ",@param='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "Select");
            //sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list'", "agentId", "agentName", "", "Select");

        }

        //protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (string.IsNullOrWhiteSpace(sCountry.Text))
        //        payoutPartner.Items.Clear();
        //    else
        //        sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='Partneragent',@country=" + sdd.FilterString(sCountry.Text), "agentId", "agentName", "", "Select");
        //}
    }
}