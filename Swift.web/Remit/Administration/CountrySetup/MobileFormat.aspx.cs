using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class MobileFormat : Page
    {
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";

        protected const string GridName = "grd_Operators";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly MobileFormatDao obj = new MobileFormatDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                if (GetCountryId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        #region Method

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref ISDCountryCode);
            Misc.MakeNumericTextbox(ref mobileLen);
            Misc.MakeNumericTextbox(ref prefix);
        }

        protected string GetCountryName()
        {
            return "Country : " + sdd.GetCountryName(GetCountryId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("mobileFormatId");
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadTab()
        {
            var countryId = GetCountryId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "CountryCurrency.aspx" + queryStrings),
                                   new TabField("Mobile Format", "", true),
                                   new TabField("Valid ID Setup", "CountryIdSetup.aspx" + queryStrings),
                               };
            switch (opType)
            {
                case "B":
                    _tab.TabList.Add(new TabField("Collection Mode", "CollectionMode/List.aspx" + queryStrings));
                    _tab.TabList.Add(new TabField("Receiving Mode", "ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "CollectionMode/List.aspx" + queryStrings));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "EventSetup/List.aspx" + queryStrings));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdMblFormat(GetStatic.GetUser(), GetCountryId().ToString());
            if (dr == null)
                return;

            ISDCountryCode.Text = dr["ISDCountryCode"].ToString();
            mobileLen.Text = dr["mobileLen"].ToString();
        }

        private void PopulateDataByIdMblOperator()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), mobileOperatorId.Value);
            if (dr == null)
                return;

            mblOperator.Text = dr["operator"].ToString();
            prefix.Text = dr["prefix"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateMblFormat(GetStatic.GetUser(), GetId().ToString(), GetCountryId().ToString(),
                                                    ISDCountryCode.Text, mobileLen.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("operator", "Operator", "", "T"),
                                      new GridColumn("mobileLen", "Mobile Len", "", "T"),
                                      new GridColumn("prefix", "Prefix", "", "T")
                                  };

            bool allowAddEdit = sdd.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 450;
            grid.RowIdField = "mobileOperatorId";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "MobileFormat.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = sdd.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_mobileOperator @flag = 's', @countryId = " + GetCountryId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            var obj = new MobileFormatDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteMblOperator(GetStatic.GetUser(), id);
            MessageDiv.Visible = true;
            lblMsg.Text = dbResult.Msg;
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            mobileOperatorId.Value = id;
            PopulateDataByIdMblOperator();
        }

        #endregion Method

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DbResult dbResult = obj.UpdateMblOperator(GetStatic.GetUser(), mobileOperatorId.Value,
                                                      GetCountryId().ToString(), mblOperator.Text, prefix.Text, mobileLen.Text);
            MessageDiv.Visible = true;
            lblMsg.Text = dbResult.Msg;
            LoadGrid();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        #endregion Element Method
    }
}