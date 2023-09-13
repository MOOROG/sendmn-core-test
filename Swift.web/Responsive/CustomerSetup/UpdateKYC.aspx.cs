using Swift.DAL.BL.Remit.Administration.Customer;
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

namespace Swift.web.Responsive.CustomerSetup
{
    public partial class UpdateKYC : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly SwiftLibrary _swiftLib = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string ViewFunctionId = "20150500";
        protected void Page_Load(object sender, EventArgs e)
        {
            _swiftLib.CheckSession();
          
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
                startDate.Text = DateTime.Now.ToString("d");
                startDate.Attributes.Add("readonly", "readonly");
                PopulateDDL();
                PopulateCustomerData();
                var a = GetCustomerId();
          }
            DeleteRow();
            LoadGrid();



        }

        private void PopulateCustomerData()
        {
            DataRow dr = _cd.GetCustomerData(GetStatic.GetUser(), GetCustomerId());
            if (dr != null)
            {
                string Name = dr["fullname"].ToString();
                string address = dr["address"].ToString();
                string mobile = dr["mobile"].ToString();
                customerName.Text = Name;
                customerAddress.Text = address;
                mobileNo.Text = mobile;
            }
        }

        private void Authenticate()
        {
            _swiftLib.CheckAuthentication(ViewFunctionId);
        }
        public void PopulateDDL()
        {
            var user = GetStatic.GetUser();
            _sl.SetDDL(ref ddlStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7007',@user='" + user + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlMethod, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7008',@user='" + user + "'", "valueId", "detailTitle", "", "Select..");
        }

        protected void save_Click(object sender, EventArgs e)
        {

            var selecteduserId = GetCustomerId();
            var kycmethod = ddlMethod.SelectedValue;
            var kycstatus = ddlStatus.SelectedValue;
            var selecteddate = startDate.Text;
            var currentuser = GetStatic.GetUser();
            var remarkstext = remarks.Text;
            var res = _cd.InsertCustomerKYC(currentuser, selecteduserId, kycmethod, kycstatus, selecteddate, remarkstext);
            if (res.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = res;
                Response.Redirect(Request.RawUrl);
                //GetStatic.AlertMessage(this, res.Msg);
                
            }
            else
            {
                HttpContext.Current.Session["message"] = res;
                GetStatic.AlertMessage(this, res.Msg);
            }

        }
        public void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                    new GridFilter("detailTitle", "KYC Method", "1:EXEC proc_customerKYC @flag='dropdownListMethod'"),
                                    new GridFilter("detailTitle", "KYC Status", "1:EXEC proc_customerKYC @flag='dropdownListStatus'"),
                                     //new GridFilter("detailTitle", "KYC Method", "1:EXEC proc_customerKYC @flag='dropdownList'", "", "", true),
                                     //new GridFilter("kycStatus", "kycStatus", "1:" + "EXEC [proc_customerKYC] @flag = 's'"),
                                     ////new GridFilter("fromDate", "Registered From", "d"),
                                     //new GridFilter("toDate", "Registered To", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("kycStatus", "KYC Status", "", "T"),
                                      new GridColumn("createdDate", "Date", "", "D"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("kycMethod", "Method", "", "T"),
                                      new GridColumn("remarks", "Remarks", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = false;
            _grid.AllowDelete = true;
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "Manage.aspx";


            string sql = "EXEC [proc_customerKYC] @flag = 's', @customerId =" + _sl.FilterString(GetCustomerId());
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);

        }

        protected string GetCustomerId()
        {
            return GetStatic.ReadQueryString("customerId", "");
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;
            var user = GetStatic.GetUser();
            DbResult dbResult = _cd.DeleteCustomerKYC(id, user);
            if (dbResult.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = dbResult;
                Response.Redirect(Request.RawUrl);
            }
            else
            {
                HttpContext.Current.Session["message"] = dbResult;
                GetStatic.AlertMessage(this, dbResult.Msg);
            }

        }
    }
}