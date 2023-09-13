﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class CustomerList : Page
    {
        private const string ViewFunctionId = "10111500";
        private const string AddEditFunctionId = "10111510";
        private const string DeleteFunctionId = "10111520";
        protected const string GridName = "grd_CustomerContact";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ContactCategory obj = new ContactCategory();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                
            }
            lblCategoryName.Text = GetCatName();
            DeleteRow();
            LoadGrid();

        }

        private long GetCatId()
        {
            return (Request.QueryString["id"] != null ? long.Parse(Request.QueryString["id"]) : 0);
        }

        private string GetCatName()
        {
            return (Request.QueryString["categoryName"] != null ? Request.QueryString["categoryName"].ToString() :"");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }
        private void PopulateDataById()
        {
            DataRow dr = obj.SelectCustomerById(GetStatic.GetUser(), hdnId.Value);
            if (dr == null)
                return;

            customerName.Text = dr["customerName"].ToString();
            customerAddress.Text = dr["customerAddress"].ToString();
            email.Text = dr["email"].ToString();
            mobile.Text = dr["mobile"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateCustomer(GetStatic.GetUser(), hdnId.Value, GetCatId().ToString() ,customerName.Text, customerAddress.Text, mobile.Text, email.Text);

            ManageMessage(dbResult);
            LoadGrid();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("customerName", "Customer Name", "", "T"),
                                      new GridColumn("customerAddress", "Customer Address", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 800;
            grid.RowIdField = "id";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "CustomerList.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_categoryContact @flag = 'sc',@catId='"+GetCatId()+"'";

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteCustomer(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            hdnId.Value = id;
            PopulateDataById();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            Update();
        }

    }
}