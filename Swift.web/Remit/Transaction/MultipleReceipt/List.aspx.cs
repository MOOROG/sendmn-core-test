using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.Remittance;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.MultipleReceipt
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        public const string GridName = "RemitTransaction";
        private const string ViewFunctionId = "20191000";
        private const string PrintFunctionId = "20191010";

        private const string ViewFunctionIdAgent = "40112000";
        private const string PrintFunctionIdAgent = "40112010";
        private readonly CustomersDao obj = new CustomersDao();
        private string customerId = "";
        private bool flagClearList = false;
        private string sql = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            string reqMethod = Request.Form["MethodName"];
            sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                switch (reqMethod)
                {
                    case "GetCustomerName":
                        SearchCustomerName();
                        break;
                }
            }
            PopulateDdl();
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                //new GridFilter("gl_code", "GL Code", "a", "", "gl_code", true),
                //new GridFilter("CustomerID", "Customer Name", "a", "", "remit-CustomerName", true),
                //new GridFilter("fromDate", "From Date", "D"),
                //new GridFilter("toDate", "To Date", "D"),
                //new GridFilter("controlNumber", "Control Number", "T")
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("ID", "Transaction Id", "", "T"),
                                      new GridColumn("controlNo", "Control No", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "ReceiverName", "", "T"),
                                      new GridColumn("approvedDate", "Send Date", "", "D"),
                                      new GridColumn("paidDate", "Paid Date", "", "D")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = false;
            _grid.AllowDelete = false;
            _grid.RowIdField = "id";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.ShowCheckBox = true;
            _grid.IsGridWidthInPercent = true;
            _grid.MultiSelect = true;
            if (!string.IsNullOrEmpty(controlNumber.Text))
            {
                sql = "[proc_remitTransaction] @flag='s',@customerId='" + customerId + "',@fromDate='" + Request.Form["fromDate"] + "',@toDate='" + Request.Form["toDate"] + "',@controlNumber='" + Request.Form["controlNumber"] + "'";
            }
            else
            {
                sql = "[proc_remitTransaction] @flag='s',@customerId='" + customerId + "',@fromDate='" + Request.Form["fromDate"] + "',@toDate='" + Request.Form["toDate"] + "'";
            }
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public void CheckTransaction(string sql)
        {
            var RemitGridDao = new RemittanceGridDao();
            var a = RemitGridDao.GetGridDataSource(sql, false, false);
            if (a[0].ToString() == "0")
            {
                GetStatic.AlertMessage(this, "No Receipt Found");
            }
        }

        public void PopulateDdl()
        {
            _sdd.SetDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));

            var hasRight = sl.HasRight(GetFunctionIdByUserType(PrintFunctionIdAgent, PrintFunctionId));
            btnPrintReceipt.Enabled = hasRight;
            btnPrintReceipt.Visible = hasRight;
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        protected void btnPrintReceipt_Click(object sender, EventArgs e)
        {
            var trnids = Request.Form["RemitTransaction_rowId"];

            //string[] trnids = a.Split(',');
            GetStatic.WriteSession("tranIds", trnids);
            Response.Redirect("MultipleReceipt.aspx");
        }

        protected void postPage_Click(object sender, EventArgs e)
        {
            flagClearList = true;
            SetCustomerID();
        }

        private void SetCustomerID()
        {
            customerId = HiddenCustomerId.Value.ToString();
            if (flagClearList == false)
            {
                if (customerId == "")
                {
                    GetStatic.AlertMessage(this, "Please select customer first");
                    return;
                }
            }
            //CheckTransaction(sql);
            LoadGrid();
        }

        protected void searchButton_Click(object sender, EventArgs e)
        {
            SetCustomerID();
            LoadGrid();
        }

        public void SearchCustomerName()
        {
            customerId = Request.Form["id"];
            DataTable dt = obj.GetCustomerSoaData(GetStatic.GetUser(), "", customerId);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();

            //DataRow a = dt.Rows[0];
            //var test = a["fullName"];
            //Response.ContentType = "text/plain";
            //Response.Write(test);
            //Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }
    }
}