using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Modify
{
    public partial class Modify : Page
    {
        protected const string GridName = "grid_modifytrn";

        private const string ViewFunctionId = "20121500";
        private const string AddEditFunctionId = "20121510";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ModifyTransactionDao mtd = new ModifyTransactionDao();
        private readonly CancelTransactionDao obj = new CancelTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadGrid(string tranId)
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("id", "Tran id", "", "T"),
                                      new GridColumn("controlNo", "Control No.", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("sCountryName", "S. Country", "", "T"),
                                      new GridColumn("sStateName", "S. State", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("rCountryName", "R. Country", "", "T"),
                                      new GridColumn("rStateName", "R. State", "", "T"),
                                      new GridColumn("tranStatus", "Tran Status", "", "T"),
                                      new GridColumn("payStatus", "Pay Status", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.AccountDB;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = "id";
            grid.DisableSorting = true;
            grid.DisableJsFilter = false;
            grid.ShowCheckBox = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;
            grid.EnableCookie = false;
            grid.SelectionCheckBoxList = tranId;
            string sql =
                @"EXEC proc_payTran 
                             @flag = 's'
                            ,@controlNo = " +
                grid.FilterString(controlNo.Text) + @"
                            ,@sFirstName = " +
                grid.FilterString(sFirstName.Text) + @"
                            ,@sMiddleName = " +
                grid.FilterString(sMiddleName.Text) + @"
                            ,@sLastName1 = " +
                grid.FilterString(sLastName1.Text) + @"
                            ,@sLastName2 = " +
                grid.FilterString(sLastName2.Text) + @"
                            ,@sMemId = " +
                grid.FilterString(sMemId.Text) + @"
                            ,@rFirstName = " +
                grid.FilterString(rFirstName.Text) + @"
                            ,@rMiddleName = " +
                grid.FilterString(rMiddleName.Text) + @"
                            ,@rLastName1 = " +
                grid.FilterString(rLastName1.Text) + @"
                            ,@rLastName2 = " +
                grid.FilterString(rLastName2.Text) + @"
                            ,@rMemId = " +
                grid.FilterString(rMemId.Text);

            grd_tran.InnerHtml = grid.CreateGrid(sql);
            divTranDetails.Visible = false;
        }

        private void PopulateDdl()
        {
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //LoadGrid("");
            LoadByControlNo(controlNo.Text);
        }

        protected void btnTranSelect_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId(GridName);
            LoadGrid(id);
            LoadByTranId(id);
        }

        private void LoadByTranId(string id)
        {
        }

        private void LoadByControlNo(string cNo)
        {
            DataSet ds = obj.SelectTransaction(cNo, GetStatic.GetUser());
            DbResult dbResult = obj.ParseDbResult(ds.Tables[0]);
            if (dbResult.ErrorCode != "0")
            {
                ManageMessage(dbResult);
                return;
            }
            DataRow row = ds.Tables[1].Rows[0];
            if (row == null)
            {
                divTranDetails.Visible = false;
                hddTran.Value = "";
                return;
            }
            divTranDetails.Visible = true;
            hddSCustomerId.Value = row["sCustomerId"].ToString();
            hddRCustomerId.Value = row["rCustomerId"].ToString();
            sName.Text = row["senderName"].ToString();
            sAddress.Text = row["sAddress"].ToString();
            sCity.Text = row["sCity"].ToString();
            sState.Text = row["sStateName"].ToString();
            sCountry.Text = row["sCountryName"].ToString();

            rName.Text = row["receiverName"].ToString();
            rAddress.Text = row["rAddress"].ToString();
            rCity.Text = row["rCity"].ToString();
            rState.Text = row["rStateName"].ToString();
            rCountry.Text = row["rCountryName"].ToString();

            pName.Text = row["pBranchName"].ToString();
            pCountry.Text = row["pCountryName"].ToString();
            pSuperAgent.Text = row["pSuperAgentName"].ToString();
            pState.Text = row["pStateName"].ToString();
            pDistrict.Text = row["pDistrictName"].ToString();
            modeOfPayment.Text = row["paymentMethod"].ToString();
            tranStatus.Text = row["tranStatus"].ToString();

            transferAmount.Text = GetStatic.FormatData(row["tAmt"].ToString(), "M");
            serviceCharge.Text = GetStatic.FormatData(row["serviceCharge"].ToString(), "M");
            aHandling.Text = GetStatic.FormatData(row["handlingFee"].ToString(), "M");
            total.Text = GetStatic.FormatData(row["cAmt"].ToString(), "M");
            exchangeRate.Text = "1";
            payoutAmt.Text = GetStatic.FormatData(row["pAmt"].ToString(), "M");

            purpose.Text = row["purpose"].ToString();
            relationship.Text = row["relationship"].ToString();
            sourceOfFund.Text = row["sourceOfFund"].ToString();
            payoutMsg.Text = row["payoutMsg"].ToString();


            hddTran.Value = row["id"].ToString();
            string defCurrency = "";

            string scriptName = "";
            string functionName = "";
            GetStatic.CallBackJs1(Page, scriptName, functionName);

            LoadTranLog();
        }

        private void LoadTranLog()
        {
            DataTable dt = mtd.GetTranLog(GetStatic.GetUser(), hddTran.Value);
            if (dt == null)
                return;
            var html = new StringBuilder();
            html.AppendLine("<table>");
            foreach (DataRow dr in dt.Rows)
            {
                html.AppendLine("<tr>");
                html.AppendLine("<td>" + dr["message"] + "</td>");
                html.AppendLine("<td>Changed By:" + dr["createdBy"] + "</td>");
                html.AppendLine("<td>Changed On:" + dr["createdDate"] + "</td>");
                html.AppendLine("</tr>");
            }
            html.AppendLine("</table>");
            rptLog.InnerHtml = html.ToString();
        }

        private void ManageMessage(DbResult dbResult)
        {
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);

            // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language = \"javascript\">return CallBack('" + mes + "')</script>");
        }
    }
}