using Swift.DAL.BL.System.Utilities;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace Swift.web.Remit.Administration.AgentCustomerSetup.UploadVoucher
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "gridVoucher";
        private const string ViewFunctionId = "40122100";
        private const string AddEditFunctionId = "40122110";
        private const string ExportToExcelFunctionId = "40122110";
        private readonly ScannerSetupDao _scanner = new ScannerSetupDao();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(this);
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.PrintMessage(Page);
                string reqMethod = Request.Form["MethodName"];
                if (reqMethod == "docCheck")
                {
                    CheckDocument();
                }
            }
            var sc = _scanner.GetUserScanner(GetStatic.GetUser());
            hdnscanner.Value = sc;

            LoadGrid();
        }

        private void CheckDocument()
        {
            string agentId = Request.Form["agentId"];
            string icn = Request.Form["icn"];
            string tranId = Request.Form["tranId"];
            string vouType = Request.Form["vouType"];
            DataTable dt = _scanner.CheckDocument(agentId, tranId, icn, vouType);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        #region Method

        private void LoadGrid()
        {
            string ddlSql = "EXEC proc_txnDocumentsForAgent @flag = 'at'";
            string ddlSql1 = "EXEC proc_txnDocumentsForAgent @flag = 'status'";
            string ddlSql2 = "EXEC proc_txnDocumentsForAgent @flag = 'isDoc'";
            grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("controlNo", "BRN ", "t"),
                                     new GridFilter("fromDate", "From Date", "z"),
                                     new GridFilter("toDate", "To Date", "z"),
                                     new GridFilter("txnType", "Type", "1:" + ddlSql),
                                     new GridFilter("status", "Status", "1:" + ddlSql1),
                                     new GridFilter("isDocUpload", "Is Doc Upload", "1:" + ddlSql2)
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("controlNo", "BRN", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("tranAmt", "Tran Amt", "", "T"),
                                      new GridColumn("txnType", "TXN Type", "", "T"),
                                      new GridColumn("status", "Status", "", "T"),
                                      new GridColumn("createdDate", "Txn Date", "", "T"),
                                      new GridColumn("isDocUpload", "Is Doc Upload", "", "T"),
                                      new GridColumn("link", "", "150", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridWidth = 800;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";
            grid.InputPerRow = 3;
            grid.EditText = "Upload Document";
            grid.LoadGridOnFilterOnly = true;
            //grid.AllowCustomLink = false;
            //grid.CustomLinkVariables = "txnType1,id,controlNo";
            //grid.CustomLinkText = "<a class='button' style='text-decoration:none;color:white; !important' href='BrowseDoc.aspx?txnType=@txnType1&id=@id'>Browse Doc</a><input type='button' value='Scan' onclick=\"ScanDocument('@id', '@controlNo','@txnType1');\"/>";

            string sql = "[proc_txnDocumentsForAgent] @flag='s'" + ",@agent=" + grid.FilterString(GetStatic.GetAgent());
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion Method

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", GetStatic.GetAgentId());
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }
    }
}