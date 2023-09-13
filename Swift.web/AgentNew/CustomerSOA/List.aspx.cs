using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.BL.Remit.Administration.Customer;
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

namespace Swift.web.AgentNew.CustomerSOA
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private SendTranIRHDao st = new SendTranIRHDao();
        private readonly CustomersDao obj = new CustomersDao();
        private const string GridName = "CustomerSoa";
        private const string ViewFunctionId = "20308000";
        private string customerId = "";
        private bool flagClearList = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            string reqMethod = Request.Form["MethodName"];
            sl.CheckSession();
            if (!IsPostBack)
            {
                //Authenticate();
                fromDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
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

        private void ManageMessage(string res, string msg)
        {
            GetStatic.CallBackJs1(Page, "Call Back", "alert('" + msg + "');");
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
            LoadGrid();
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

        public void PopulateDdl()
        {
            _sdd.SetDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
            _sdd.AddOptionToDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='addReceiver'", "VALUE", "TEXT", "", "");
        }


        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                //new GridFilter("gl_code", "GL Code", "a", "", "gl_code", true),
                //new GridFilter("CustomerID", "Customer Name", "a", "", "remit-CustomerName", true),
                //new GridFilter("fromDate", "From Date", "D", DateTime.Now.AddDays(-7).ToString("d")),
                //new GridFilter("toDate", "To Date", "D", DateTime.Now.ToString("d")),
                //new GridFilter("controlNumber", "Control Number", "T")
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("ID", "Transaction Id", "", "T"),
                                      new GridColumn("controlNo", "JME No", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "ReceiverName", "", "T"),
                                      new GridColumn("approvedDate", "Send Date", "", "D"),
                                      new GridColumn("paidDate", "Paid Date", "", "D")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.LoadGridOnFilterOnly = false;
            _grid.ShowPagingBar = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = false;
            _grid.AllowDelete = false;
            _grid.RowIdField = "id";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.EnablePdfDownload = true;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.ShowCheckBox = true;
            _grid.IsGridWidthInPercent = true;
            _grid.MultiSelect = true;
            string sql = "";
            string searchType = HiddenSearchType.Value.ToString();
            if (!string.IsNullOrEmpty(customerId))
            {
                sql = "[proc_remitTransaction] @flag='s',@customerId='" + customerId + "',@fromDate='" + GetFromDate()+"',@toDate='" +GetToDate() +"',@searchType= '"+ searchType + "'";
            }
            else
            {
                sql = "[proc_remitTransaction] @flag='s',@customerId = ''" + ",@fromDate='" + GetFromDate() + "',@toDate='" + GetToDate() + "',@searchType= '" + searchType + "'";
            }
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnPrintReceipt_Click(object sender, EventArgs e)
        {
            var trnids = Request.Form["CustomerSoa_rowId"];
            var fDate = DateTime.Parse(fromDate.Text).ToString("yyyy-MM-dd");
            var tDate = DateTime.Parse(toDate.Text).ToString("yyyy-MM-dd");
            var custId = HiddenCustomerId.Value; //should be same present in  grid filter key
            GetStatic.WriteSession("tranIds", trnids);
            GetStatic.WriteSession("custId", custId);

            Response.Redirect("CustomerSoaReceipt.aspx?fromDate=" + fDate + "&toDate=" + tDate);
        }

        protected void postPage_Click(object sender, EventArgs e)
        {
            flagClearList = true;
            fromDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
            toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            SetCustomerID();
        }

        public void GetQueryString()
        {
            customerId = GetStatic.ReadSession("customerId", "");
        }

        protected void searchButton_Click(object sender, EventArgs e)
        {
            SetCustomerID();
            LoadGrid();
        }
        protected string GetFromDate()
        {
            string fDate = "";
            fDate = Request.Form["fromDate"];
            if (string.IsNullOrEmpty(fDate))
            {
                    fDate = fromDate.Text;
            }
      
            return fDate;
        }
        protected string GetToDate()
        {
            string tDate = "";
            tDate = Request.Form["toDate"];
            if (string.IsNullOrEmpty(tDate))
            {
                    tDate = toDate.Text;
            }
            return tDate;
        }
    }
}