//using Swift.DAL.OnlineAgent;
//using Swift.DAL.Remittance.Amendment;
//using Swift.web.Component.Grid;
//using Swift.web.Component.Grid.gridHelper;
//using Swift.web.Library;
//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.Linq;
//using System.Text;
//using System.Web;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace Swift.web.RemittanceSystem.RemittanceReports.AmendmentReport
//{
//    public partial class List : System.Web.UI.Page
//    {
//        private readonly SwiftGrid _grid = new SwiftGrid();
//        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
//        private readonly AmendmentDao _ado = new AmendmentDao();
//        private const string GridName = "grid_AmendmentList";
//        protected void Page_Load(object sender, EventArgs e)
//        {
//            //GetAmendmentList();
//            LoadGrid();
//        }
//        private void GetAmendmentList()
//        {
//        //    //DataTable dt = _ado.GetAmendmentReport(GetStatic.GetUser(), getCustomerId(), GetFromDate(), GetToDate());
//        //    if (dt.Rows.Count > 0)
//        //    {
//        //        StringBuilder sb = new StringBuilder();

//        //        sb.Append("<table class=\"table table-responsive\" border=1>");
//        //        sb.Append("<tr>");
//        //        sb.Append("<th>Modified Date</th>");
//        //        sb.Append("<th>Receiver Name</th>");
//        //        sb.Append("</tr>");
//        //        foreach (DataRow items in dt.Rows)
//        //        {
//        //            sb.Append("<tr>");
//        //            sb.Append("<td onclick=test()>"+items[0].ToString()+"");
//        //            sb.Append("</td>");
//        //            sb.Append("<td>" + items[3].ToString() + "");
//        //            sb.Append("</td>");
//        //            sb.Append("</tr>");
//        //        }
//        //        sb.Append("</table>");
//        //        //rpt_grid.InnerHtml = sb.ToString();
//            }

//        }
//        private void LoadGrid()
//        {
//            string customerId = getCustomerId();
//            hideCustomerId.Value = customerId;
//            var result = _cd.GetCustomerDetails(customerId, GetStatic.GetUser());
//            if (result != null)
//            {
//            //    txtMembershipId.InnerText = result["membershipId"].ToString();
//            //    customerName.InnerText = result["firstName"].ToString() + ' ' + result["middleName"].ToString() + ' ' + result["lastName1"].ToString();
//            }

//            _grid.ColumnList = new List<GridColumn>
//                                  {
//                                      new GridColumn("modifiedDate", "Modified Date", "", "D"),
//                                      new GridColumn("receicerName", "Receicer Name", "", "T")
//                                  };

//            _grid.GridType = 1;
//            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
//            _grid.GridName = GridName;
//            _grid.ShowPagingBar = true;
//            _grid.AllowEdit = false;
//            _grid.AlwaysShowFilterForm = true;
//            _grid.ShowFilterForm = false;
//            _grid.SortOrder = "ASC";
//            _grid.RowIdField = "customerId";
//            _grid.ThisPage = "List.aspx";
//            _grid.InputPerRow = 4;
//            _grid.GridMinWidth = 700;
//            _grid.GridWidth = 100;
//            _grid.IsGridWidthInPercent = true;
//            _grid.AddPage = "Manage.aspx?customerId=" + customerId;
//            _grid.AllowCustomLink = true;
//            _grid.CustomLinkText = "<input type=\"button\" value=\"test\" onclick=\"test()\"/>";
//            _grid.CustomLinkVariables = "modifiedDate,amendmentId,customerId";

//            string sql = "EXEC [PROC_AMENDMENTLIST] @flag = 's',@customerId='" + customerId + "',@fromDate='" + GetFromDate() + "',@toDate='" + GetToDate() + "'";
//            _grid.SetComma();

//            //rpt_grid.InnerHtml = _grid.CreateGrid(sql);
//        }
//        private string getCustomerId()
//        {
//            var qCustomerId = GetStatic.ReadQueryString("customerId", "");
//            return qCustomerId;
//        }
//        private string GetFromDate()
//        {
//            return GetStatic.ReadQueryString("from", "");
//        }
//        private string GetToDate()
//        {
//            return GetStatic.ReadQueryString("to", "");
//        }
//    }
//}