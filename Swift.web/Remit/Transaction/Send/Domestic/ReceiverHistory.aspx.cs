using System;
using System.Collections.Generic;
using System.Data;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.DAL.BL.Remit.Administration.Customer;


namespace Swift.web.Remit.Transaction.Send.Domestic
{
    public partial class ReceiverHistory : System.Web.UI.Page
    {
        private const string GridName = "grdRec";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CustomersDao obj = new CustomersDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        #region Method
        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("rMembershipId", "Receiver Membership Id", "T"),
                                      new GridFilter("rFullName", "Receiver Name", "LT"),
                                      new GridFilter("rMobile", "Receiver Mobile", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("rMembershipId", "Membership Id", "", "T"),
                                      new GridColumn("rFullName", "Full Name", "", "T"),
                                      new GridColumn("rMobile", "Mobile", "", "T"),
                                      new GridColumn("rIdType", "Id Type", "", "T"),
                                      new GridColumn("rIdNumber", "Id Number", "", "T"),
                                      new GridColumn("rAddress", "Address", "", "T")
                                  };
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridWidth = 700;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";
            grid.InputPerRow = 4;
            grid.ShowCheckBox = true;

            string sql = "[proc_customerMaster] @flag='viewHistory',@sMembershipId="+grid.FilterString(GetSenderCustomerCardNo())+""
            +",@sFirstName="+grid.FilterString(GetSenderFirstName())+",@sMiddleName="+grid.FilterString(GetSenderMiddleName())+""
            +",@sLastName="+grid.FilterString(GetSenderLastName())+",@sContactNo="+grid.FilterString(GetSenderContactNo())+"";

            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private string GetSenderCustomerCardNo()
        {
            return GetStatic.ReadQueryString("sMembershipId", "");
        }

        private string GetSenderFirstName()
        {
            return GetStatic.ReadQueryString("sFirstName", "");
        }

        private string GetSenderMiddleName()
        {
            return GetStatic.ReadQueryString("sMiddleName", "");
        }

        private string GetSenderLastName()
        {
            return GetStatic.ReadQueryString("sLastName", "");
        }

        private string GetSenderContactNo()
        {
            return GetStatic.ReadQueryString("sContactNo", "");
        }

        #endregion

        protected void btnSelect_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId(GridName);
            string data = "";
            DataSet ds = obj.GetReceiverById(GetStatic.GetUser(), id);
            if (ds.Tables.Count > 1)
            {
                var dbResult = obj.ParseDbResult(ds.Tables[0]);
                if (dbResult.ErrorCode != "0")
                {
                    data = dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id;
                    GetStatic.CallBackJs1(Page, "ReturnRateAndClose", "ReturnRateAndClose('" + data + "')");
                    return;
                }
                var dr = ds.Tables[1].Rows[0];
                data = "0" + "|" +
                               dr["membershipId"] + "|" +
                               dr["customerId"] + "|" +
                               dr["firstName"] + "|" +
                               dr["middleName"] + "|" +
                               dr["lastName1"] + "|" +
                               dr["mobile"] + "|" +
                               dr["idType"] + "|" +
                               dr["idNumber"] + "|" +
                               dr["address"];
            }

            var scriptName = "CallBack";
            var functionName = "CallBack('" + data + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }
    }
}