using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.Administration.ReceiverInformation;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.CustomerSetup.Benificiar
{
    public partial class List : System.Web.UI.Page
    {
        //private readonly ReceiverInformationDAO _receiver = new ReceiverInformationDAO();
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20111300";
        private const string AddEditFunctionId = "20111310";
        private const string ApproveFunctionId = "20111330";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                swiftLibrary.CheckAuthentication(ViewFunctionId);
            }
            LoadGrid();
        }
        private void LoadGrid()
        {
            string customerId = GetStatic.ReadQueryString("customerId", "");
            hideCustomerId.Value = customerId;
            var result = _cd.GetCustomerDetails(customerId, GetStatic.GetUser());
            if (result != null)
            {
                txtMembershipId.InnerText = result["membershipId"].ToString();
                customerName.InnerText = result["firstName"].ToString() + ' ' + result["middleName"].ToString() + ' ' + result["lastName1"].ToString();
            }
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("receiverId", "Receiver Name", "a", "", "remit-ReceiverName", true),
                new GridFilter("fromDate", "Registered From", "d"),
                new GridFilter("toDate", "Registered To", "d"),
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("firstName", "Name", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("createdDate","Created Date","","D"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "Manage.aspx?customerId=" + customerId;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <a href =\"Manage.aspx?receiverId=@receiverId&customerId=@customerId\"><i class=\"fa fa-edit\" ></i></a></btn></span>";
            _grid.CustomLinkVariables = "receiverId,customerId";
            string sql = "EXEC [proc_online_receiverSetup] @flag = 's',@customerId=" + customerId + " ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}