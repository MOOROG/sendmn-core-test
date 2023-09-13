﻿using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;

namespace Swift.web.Remit.InternationalOperation.CreditLimit
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grdCrLimitsInt";
        private const string ViewFunctionId = "30011000";
        private const string AddEditFunctionId = "30011010";
        private const string ApproveFunctionId = "30011020";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CreditLimitIntDao obj = new CreditLimitIntDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
            DeleteRow();
        }

        #region method
        protected string GetAgentName()
        {
            return "Agent Name : " + sl.GetAgentName(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status", "2"),
                                      new GridFilter("agentName", "Agent Name", "a"),
                                      new GridFilter("agentCountry", "Country","LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent", "", "T"),
                                      new GridColumn("agentCountry", "Country", "", "T"),
                                      new GridColumn("currency", "Currency", "", "T"),
                                      new GridColumn("limitAmt", "Base Limit", "", "M"),
                                      new GridColumn("maxLimitAmt", "Max Limit", "", "M"),
                                      new GridColumn("perTopUpAmt", "Per Top Up Limit", "", "M")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.LoadGridOnFilterOnly = !IsPostBack;
            grid.AlwaysShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "agentName";
            grid.RowIdField = "crLimitId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.AllowCustomLink = allowAddEdit;

            var customLinkText = new StringBuilder();
            if (sl.HasRight(AddEditFunctionId))
                customLinkText.Append("<a href = '#' onclick = \"OpenLink('" + GetStatic.GetUrlRoot() + "/Remit/InternationalOperation/CreditLimit/Manage.aspx?agentId=@agentId&crLimitId=@crLimitId&countryId=@agentCountryId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\" border=0 title = \"Edit\"/></a>");
            customLinkText.Append(
                "<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/InternationalOperation/CreditLimit/History.aspx?agentId=@agentId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" border=0 title = \"View History\" /></a>");
            grid.CustomLinkText = customLinkText.ToString();
            grid.CustomLinkText = "<a href = '#' onclick = \"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/InternationalOperation/CreditLimit/Manage.aspx?agentId=@agentId&crLimitId=@crLimitId&countryId=@agentCountryId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\" border=0 title = \"Edit\"/></a>";
            grid.CustomLinkVariables = "agentId,crLimitId,agentCountryId";
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.GridMinWidth = 850;
            grid.GridWidth = 100;
            grid.IsGridWidthInPercent = true;

            string sql = "[proc_creditLimitInt] @flag = 's',@parentAgentId=" + sl.FilterString(GetStatic.ReadWebConfig("IntlSuperAgentId", "0"));
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            PrintMessage(dbResult);
        }

        private void PrintMessage(DbResult dbResult)
        {
            string data = GetStatic.ParseResultJsPrint(dbResult);
            string function = "printMessage('" + data + "')";
            GetStatic.CallBackJs1(this, "print", function);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion

        protected void btnTopUp_Click(object sender, EventArgs e)
        {
            var obj2 = new BalanceTopUpDao();
            var dbResult = obj2.Update(GetStatic.GetUser(), "0", hdnAgentId.Value, hdnAmount.Value, "");
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx");
            }
        }
        protected void btnCallBack_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}