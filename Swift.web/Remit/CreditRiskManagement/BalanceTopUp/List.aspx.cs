using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.BalanceTopUp
{
    public partial class List : Page
    {
        private const string GridName = "gridBalTopUp";
        private const string ViewFunctionId = "20181500";
        private const string AddEditFunctionId = "20181510";
        private const string ApproveFunctionId = "20181530";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CreditLimitDao obj = new CreditLimitDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadCreditLimitAuthority();
            }

            LoadGrid();
        }

        #region method

        private void LoadCreditLimitAuthority()
        {
            var ds = obj.SelectCreditLimitAuthority(GetStatic.GetUser());
            if (ds == null)
                return;
            if (ds.Tables[0].Rows.Count > 0)
            {
                var dr = ds.Tables[0].Rows[0];
                dlimit.Text = GetStatic.FormatData(dr["limitPerDay"].ToString(), "M");
                dperTopUpLimit.Text = GetStatic.FormatData(dr["perTopUpLimit"].ToString(), "M");
            }
            if (ds.Tables[1].Rows.Count > 0)
            {
                var dr = ds.Tables[1].Rows[0];
                ilimit.Text = GetStatic.FormatData(dr["limitPerDay"].ToString(), "M");
                iperTopUpLimit.Text = GetStatic.FormatData(dr["perTopUpLimit"].ToString(), "M");
            }
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status", "2"),
                                      new GridFilter("agentName", "Agent Name", "a"),
                                      new GridFilter("agentCountry", "Country","LT"),
                                      new GridFilter("agentDistrict", "District","1:EXEC proc_zoneDistrictMap @flag = 'dl'"),
                                      new GridFilter("riskyAgent", "Show Risky Agent", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent", "", "T"),
                                      new GridColumn("agentCountry", "Country", "", "T"),
                                      new GridColumn("currency", "Currency", "", "T"),
                                      new GridColumn("limitAmt", "Base Limit", "", "M"),
                                      new GridColumn("limitToppedUp", "Limit Topped Up", "", "M"),
                                      new GridColumn("currentBalance", "Current Balance", "", "M"),
                                      new GridColumn("availableLimit", "Available Limit", "", "M"),
                                      new GridColumn("todaysSent", "<span style=\"background: #909090;\">Todays Sent <span style=\"color: red;\">*</span></span>", "", "M"),
                                      new GridColumn("todaysPaid", "<span style=\"background: #909090;\">Todays Paid <span style=\"color: red;\">*</span></span>", "", "M"),
                                      new GridColumn("topUp", "Top Up", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.LoadGridOnFilterOnly = true;
            grid.EnableFilterCookie = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "agentName";
            grid.RowIdField = "agentId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 3;
            grid.AllowApprove = false;
            grid.AllowCustomLink = allowAddEdit;
            var customLinkText = new StringBuilder();
            if (sl.HasRight(AddEditFunctionId))
                customLinkText.Append("<input id=\"btnTopUp_@agentId\" type=\"button\" value=\"Top Up\" onclick=\"TopUp(@agentId);\"></a>&nbsp;");
            customLinkText.Append(
                "<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/CreditRiskManagement/BalanceTopUp/History.aspx?agentId=@agentId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" border=0 title = \"View History\" /></a>&nbsp;");
            customLinkText.Append(
                "<a href = '#' onclick=\"PopUpWindow('" + GetStatic.GetUrlRoot() + "/Remit/CreditRiskManagement/ExtraLimit/Manage.aspx?agentId=@agentId','')\">Extra Limit</a>");
            grid.CustomLinkText = customLinkText.ToString();
            grid.CustomLinkVariables = "agentId,crLimitId";
            grid.AllowCustomLink1 = true;
            grid.CustomLinkText1 = "<img id=\"showSlab_@agentId\" border=\"0\" title=\"View Other Detail\" class=\"showHand\" src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail.gif\" onclick=\"ShowSlab(@agentId);\"/>";
            grid.GridMinWidth = 1000;
            grid.GridWidth = 100;
            grid.IsGridWidthInPercent = true;

            string sql = "[proc_balanceTopUp] @flag = 's'";

            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method

        protected void btnTopUp_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                var obj2 = new BalanceTopUpDao();
                var dbResult = obj2.Update(GetStatic.GetUser(), "0", hdnAgentId.Value, hdnAmount.Value, "");
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #region Browser Refresh

        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion Browser Refresh
    }
}