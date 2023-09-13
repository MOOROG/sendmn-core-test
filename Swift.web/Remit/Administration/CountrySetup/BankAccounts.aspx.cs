using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class BankAccounts : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";

        protected const string GridName = "grd_cb";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CountryDao cb = new CountryDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetCountryId() > 0)
                {
                    //PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
            }
            else
            {
                DeleteRow();
            }

            LoadGrid();
        }

        #region Method

        protected string GetCountryName()
        {
            return "Country : " + swiftLibrary.GetCountryName(GetCountryId().ToString());
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("bankName", "Bank", "200", "T"),
                                      new GridColumn("accountNumber", "Account", "150", "T"),
                                      new GridColumn("isActive", "Active", "30", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 400;
            grid.GridMinWidth = 400;

            grid.RowIdField = "countryBankId";
            grid.ThisPage = "BankAccounts.aspx";
            grid.AddPage = "BankAccounts.aspx";
            //grid.AllowCustomLink = true;
            //var icon = Misc.GetIcon("edit", "OpenInEditMode(@countryBankId)");
            //grid.CustomLinkText = icon;
            //grid.CustomLinkVariables = "countryBankId";
            //grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = true;
            grid.EditCallBackFunction = "OpenInEditMode";
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            grid.PageNumber = 1;
            grid.PageSize = -1;
            string sql = "EXEC proc_countryBanks @flag = 's', @countryId = " + GetCountryId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            var obj = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.CBDelete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        #endregion Method

        #region Element Method

        private void PopulateDataById(string id)
        {
            DataRow dr = cb.CBSelectById(GetStatic.GetUser(), id);
            if (dr == null)
                return;

            bankName.Text = dr["bankName"].ToString();
            accountNumber.Text = dr["accountNumber"].ToString();
            remarks.Text = dr["remarks"].ToString();
            isActive.Checked = GetStatic.GetCharToBool(dr["isActive"].ToString());
            lblMsg.Text = "";
        }

        private void Update()
        {
            var countryId = GetCountryId().ToString();
            var countryBankId = hddCountryBankId.Value;
            var dbResult = cb.CBUpdate(GetStatic.GetUser(), countryBankId, countryId, bankName.Text, accountNumber.Text, remarks.Text, GetStatic.GetBoolToChar(isActive.Checked));
            ManageMessage(dbResult);
        }

        #endregion Element Method

        private void ManageMessage(DbResult dbResult)
        {
            if (dbResult.ErrorCode == "0")
            {
                hddCountryBankId.Value = "";
                accountNumber.Text = "";
                bankName.Text = "";
                remarks.Text = "";
                isActive.Checked = false;
                LoadGrid();
            }

            GetStatic.AlertMessage(Page, dbResult.Msg);
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            string id = hddCountryBankId.Value;
            PopulateDataById(id);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}