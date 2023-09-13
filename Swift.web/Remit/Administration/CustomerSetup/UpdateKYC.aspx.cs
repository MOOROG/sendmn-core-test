using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace Swift.web.Remit.Administration.CustomerSetup
{
    public partial class UpdateKYC : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly SwiftLibrary _swiftLib = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string ViewFunctionId = "20111300";
        private const string ViewKYCFunctionId = "20111350";
        private const string UpdateKYCFunctionId = "20111360";
        private const string ViewFunctionIdAgent = "40120000";
        private const string ViewKYCFunctionIdAgent = "40120050";
        private const string UpdateKYCFunctionIdAgent = "40120060";

        protected void Page_Load(object sender, EventArgs e)
        {
            _swiftLib.CheckSession();

            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
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
            _swiftLib.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId) + "," + GetFunctionIdByUserType(ViewKYCFunctionIdAgent, ViewKYCFunctionId));
            save.Visible = _swiftLib.HasRight(GetFunctionIdByUserType(UpdateKYCFunctionIdAgent, UpdateKYCFunctionId));
            save.Enabled = _swiftLib.HasRight(GetFunctionIdByUserType(UpdateKYCFunctionIdAgent, UpdateKYCFunctionId));
        }

        public void PopulateDDL()
        {
            var user = GetStatic.GetUser();
            _sl.SetDDL(ref ddlStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7007',@user='" + user + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlMethod, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7008',@user='" + user + "'", "valueId", "detailTitle", "", "Select..");
        }

        protected void save_Click(object sender, EventArgs e)
        {
            DbResult _dbRes = new DbResult();
            if (!_swiftLib.HasRight(GetFunctionIdByUserType(UpdateKYCFunctionIdAgent, UpdateKYCFunctionId)))
            {
                _dbRes.SetError("1", "You are not authorized to Update Data", null);
                GetStatic.AlertMessage(this, _dbRes.Msg);
                return;
            }

            var selecteduserId = GetCustomerId();
            var kycmethod = ddlMethod.SelectedValue;
            var kycstatus = ddlStatus.SelectedValue;
            var selecteddate = startDate.Text;
            var currentuser = GetStatic.GetUser();
            var remarkstext = remarks.Text;
            _dbRes = _cd.InsertCustomerKYC(currentuser, selecteduserId, kycmethod, kycstatus, selecteddate, remarkstext);
            if (_dbRes.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = _dbRes;
                Response.Redirect(Request.RawUrl);
                //GetStatic.AlertMessage(this, res.Msg);
            }
            else
            {
                HttpContext.Current.Session["message"] = _dbRes;
                GetStatic.AlertMessage(this, _dbRes.Msg);
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

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }
    }
}