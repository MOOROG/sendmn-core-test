using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.CountrySetup.ReceivingMode
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101000";
        protected const string GridName = "gCrm";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly CountryDao obj = new CountryDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadTab();
                PopulateDdl();
            }
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetCountryName()
        {
            return "Country : " + _sl.GetCountryName(GetCountryId().ToString());
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        #endregion QueryString

        #region method

        private void LoadTab()
        {
            var countryId = GetCountryId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "../Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "../StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "../CountryCurrency.aspx" + queryStrings),
                                   new TabField("Mobile Format", "../MobileFormat.aspx" + queryStrings),
                                   new TabField("Valid ID Setup", "../CountryIdSetup.aspx" + queryStrings),
                               };
            switch (opType)
            {
                case "B":
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    _tab.TabList.Add(new TabField("Receiving Mode", "", true));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "", true));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "../EventSetup/List.aspx" + queryStrings));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("receivingMode", "Receiving Mode", "", "T"),
                                      new GridColumn("receivingModeDesc", "Description", "", "T"),
                                      new GridColumn("applicableFor", "Applicable For", "", "T"),
                                      new GridColumn("agentSelection", "Agent Selection", "", "T"),
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = "crmId";
            grid.ThisPage = "List.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.DisableSorting = true;
            grid.DisableJsFilter = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowDelete = true;

            string sql = "[proc_countryReceivingMode] @flag = 's', @countryId=" + GetCountryId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref receivingMode, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle", "", "Select");
        }

        private void PopulateDataById()
        {
            var dr = obj.SelectByIdCrm(GetStatic.GetUser(), hdnCrmId.Value);
            if (dr == null)
                return;
            receivingMode.Text = dr["receivingMode"].ToString();
            applicableFor.Text = dr["applicableFor"].ToString();
            agentSelection.Text = dr["agentSelection"].ToString();
        }

        private void DeleteRow()
        {
            var obj = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteCrm(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
            }
        }

        #endregion method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateCrm(GetStatic.GetUser(), hdnCrmId.Value, GetCountryId().ToString(), receivingMode.Text, applicableFor.Text, agentSelection.Text);
            ManageMessage(dbResult);
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId();
            hdnCrmId.Value = id;
            PopulateDataById();
        }
    }
}