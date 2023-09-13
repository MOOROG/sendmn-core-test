using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CustomerSetup.Benificiar
{
    public partial class List : System.Web.UI.Page
    {
        //private readonly ReceiverInformationDAO _receiver = new ReceiverInformationDAO();
        private const string GridName = "grid_Beneficiarylist";

        private const string ViewFunctionId = "20206000";
        private const string AddFunctionId = "20206010";
        private const string EditFunctionId = "20206020";
        private const string ApproveFunctionId = "20206040";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                HideSearchDiv1();
                PopulateDDL();
                GetStatic.PrintMessage(Page);
                Authnticate();
            }
            if (getCustomerId() != "")
            {
                LoadGrid();
            }
            DeleteRow();
        }
        protected string HideSearchDiv1()
        {
            string hide = GetStatic.ReadQueryString("hideSearchDiv", "").ToString();
            if (hide == "true")
            {
                displayOnlyOnEdit.Visible = false;
                hideSearchDiv.Value = "true";
            }
            return hide;
        }

        private void Authnticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string customerId = getCustomerId();
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
                                      new GridColumn("FullName", "Name", "", "T"),
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
            _grid.ShowAddButton = swiftLibrary.HasRight(AddFunctionId);
            _grid.AllowEdit = false;
            _grid.AllowDelete = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "receiverId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "Manage.aspx?customerId=" + customerId + "&hideSearchDiv=" + hideSearchDiv.Value + "";
            _grid.AllowCustomLink = true;
            //_grid.AllowApprove = swiftLibrary.HasRight(ApproveFunctionId);

            var editLink = swiftLibrary.HasRight(EditFunctionId) ? "<span class=\"action-icon\"> <btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <a href =\"Manage.aspx?receiverId=@receiverId&customerId=@customerId&hideSearchDiv=" + hideSearchDiv.Value + "\"><i class=\"fa fa-edit\" ></i></a></btn></span>" : "";
            var printLink = "<span class=\"action-icon\"> <btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Print Details\"> <a href =\"ReceiverDetails.aspx?receiverId=@receiverId\"><i class=\"fa fa-print\" ></i></a></btn></span>";

            _grid.CustomLinkText = editLink + printLink;
            _grid.CustomLinkVariables = "receiverId,customerId";
            string sql = "EXEC [proc_online_receiverSetup] @flag = 's',@customerId=" + customerId + " ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void PopulateDDL()
        {
            swiftLibrary.SetDDL(ref ddlSearchBy, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        protected string getCustomerId()
        {
            var qCustomerId = GetStatic.ReadQueryString("customerId", "");
            if (hideCustomerId.Value != "")
            {
                qCustomerId = hideCustomerId.Value;
            }
            else
            {
                hideCustomerId.Value = qCustomerId;
            }
            if (qCustomerId != "")
            {
                string custoInfo = qCustomerId + "," + GetCustomerName(qCustomerId);
                GetStatic.CallBackJs1(Page, "Populate Autocomplete", "PopulateAutocomplete('" + custoInfo + "');");
            }

            return hideCustomerId.Value;
        }

        protected void clickBtnForGetCustomerDetails_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
        protected string GetCustomerName(string custId)
        {
            OnlineCustomerDao _cd1 = new OnlineCustomerDao();
            DataRow res = _cd1.GetCustomerDetails(custId, GetStatic.GetUser());
            if (res != null)
            {
                string fullName = res["fullName"].ToString();
                return fullName;
            }
            else
            {
                return "";
            }

        }
        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;
            var user = GetStatic.GetUser();
            DbResult dbResult = _cd.DeleteReceiver(id, user);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
            else
            {
                HttpContext.Current.Session["message"] = dbResult;
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }
    }
}