using Swift.DAL.AccountReport;
using Swift.DAL.Model;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.AccountReport.AccountStatement
{
    public partial class List : System.Web.UI.Page
    {
        private AccountStatementDAO st = new AccountStatementDAO();
        private const string ViewFunctionId = "20101100";
        private const string ReversalId = "20101110";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            //check session
            _sl.CheckSession();
            var methodName = GetStatic.ReadFormData("MethodName", "");
            if (methodName.Equals("ViewStatement"))
                GetStatementData();

            if (!IsPostBack)
            {
                startDate.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
                startDate2.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
                endDate.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
                endDate2.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
                Authenticate();
            }
            PopulateDDL();
        }
        private void GetStatementData()
        {
            string fromDate = Request.Form["FromDate"];
            string toDate = Request.Form["ToDate"];
            string accNum = Request.Form["accNum"];
            string accName = Request.Form["accName"];
            string accCurr = Request.Form["accCurr"];
            string type = Request.Form["type"];
            bool hasRightReverse = _sl.HasRight(ReversalId);

            List <StatementModel> result = st.GetACStatementNewAjax(accNum, fromDate, toDate, accCurr, type, hasRightReverse);
            GetStatic.JsonResponse(result, this);
        }

        private void PopulateDDL()
        {
            RemittanceLibrary r = new RemittanceLibrary();
            r.SetDDL(ref ddlCurrency, "EXEC Proc_dropdown_remit @FLAG='Currency'", "val", "Name", "", "Select FCY");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            DataTable dt = st.GetACStatement(acInfo.Value, startDate.Text, endDate.Text, ddlCurrency.Text, "a",GetStatic.GetUser());

            GetStatic.DataTable2ExcelDownload(ref dt, "AccountStatement");
        } 
    }
}