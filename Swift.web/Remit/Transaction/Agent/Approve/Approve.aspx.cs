using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.Approve
{
    public partial class Approve : Page
    {
        protected const string GridName = "grid_approvetrn";

        private const string ViewFunctionId = "40101100";
        private const string ProcessFunctionId = "40101110";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ApproveTransactionDao obj = new ApproveTransactionDao();

        private static string _showHideSearchFlag = "show";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                LoadGrid("");
                MakeNumericTextBox();
            }
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref cAmt);
        }

        private void LoadGrid(string cNo)
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("id", "Tran id", "", "T"),
                                      new GridColumn("controlNo", GetStatic.GetTranNoName(), "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("sAddress", "S. Address", "", "T"),
                                      new GridColumn("sStateName", "S. Zone", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("rAddress", "R. Address", "", "T"),
                                      new GridColumn("rStateName", "R. Zone", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = "controlNo";
            grid.DisableSorting = true;
            grid.DisableJsFilter = false;
            grid.ShowCheckBox = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;
            grid.EnableCookie = false;
            grid.SelectionCheckBoxList = cNo;
            string sql =
                @"EXEC proc_approveTran 
                             @flag = 's'
                            ,@controlNo = " +
                grid.FilterString(controlNoForSearch.Text) + @"
                            ,@sFirstName = " +
                grid.FilterString(sFirstName.Text) + @"
                            ,@sMiddleName = " +
                grid.FilterString(sMiddleName.Text) + @"
                            ,@sLastName1 = " +
                grid.FilterString(sLastName1.Text) + @"
                            ,@sLastName2 = " +
                grid.FilterString(sLastName2.Text) + @"
                            ,@rFirstName = " +
                grid.FilterString(rFirstName.Text) + @"
                            ,@rMiddleName = " +
                grid.FilterString(rMiddleName.Text) + @"
                            ,@rLastName1 = " +
                grid.FilterString(rLastName1.Text) + @"
                            ,@rLastName2 = " +
                grid.FilterString(rLastName2.Text);

            grd_tran.InnerHtml = grid.CreateGrid(sql);
            divTranDetails.Visible = false;
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
            btnApprove.Visible = _sdd.HasRight(ProcessFunctionId);
        }

        private void LoadByControlNo(string cNo)
        {
            //if (string.IsNullOrEmpty(cNo))
            //{
            //    cNo = grid.GetRowId(GridName);
            //}
            DataSet ds = obj.SelectTransaction(cNo, GetStatic.GetUser());
            DbResult dbResult = obj.ParseDbResult(ds.Tables[0]);
            if (dbResult.ErrorCode != "0")
            {
                ManageMessage(dbResult);
                if(dbResult.ErrorCode == "1000")
                    _sdd.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            if (ds.Tables[1].Rows.Count < 1)
                return;
            DataRow row = ds.Tables[1].Rows[0];
            if (row == null)
            {
                divTranDetails.Visible = false;
                hddTran.Value = "";
                return;
            }
            divTranDetails.Visible = true;
            tblSearch.Visible = false;
            pnlShowBankDetail.Visible = false;
            _sdd.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
            tranNoName.Text = GetStatic.GetTranNoName();
            lblControlNo.Text = row["controlNo"].ToString();
            lblStatus.Text = row["tranStatus"].ToString();
            createdBy.Text = row["createdBy"].ToString();
            createdDate.Text = row["createdDate"].ToString();

            sName.Text = row["senderName"].ToString();
            sAddress.Text = row["sAddress"].ToString();
            sCountry.Text = row["sCountryName"].ToString();
            sContactNo.Text = row["sContactNo"].ToString();
            sIdType.Text = row["sIdType"].ToString();
            sIdNo.Text = row["sIdNo"].ToString();
            sEmail.Text = row["sEmail"].ToString();

            rName.Text = row["receiverName"].ToString();
            rAddress.Text = row["rAddress"].ToString();
            rCountry.Text = row["rCountryName"].ToString();
            rContactNo.Text = row["rContactNo"].ToString();
            rIdType.Text = row["rIdType"].ToString();
            rIdNo.Text = row["rIdNo"].ToString();

            sAgentName.Text = row["sAgentName"].ToString();
            sBranchName.Text = row["sBranchName"].ToString();
            sAgentCountry.Text = row["sAgentCountry"].ToString();
            sAgentCity.Text = row["sAgentCity"].ToString();
            sAgentDistrict.Text = row["sAgentDistrict"].ToString();
            sAgentLocation.Text = row["sAgentLocation"].ToString();

            pAgentName.Text = row["pAgentName"].ToString();
            pBranchName.Text = row["pBranchName"].ToString();
            pAgentCountry.Text = row["pAgentCountry"].ToString();
            pAgentCity.Text = row["pAgentCity"].ToString();
            pAgentDistrict.Text = row["pAgentDistrict"].ToString();
            pAgentLocation.Text = row["pAgentLocation"].ToString();

            total.Text = GetStatic.FormatData(row["cAmt"].ToString(), "M");
            totalCurr.Text = row["collCurr"].ToString();
            serviceCharge.Text = GetStatic.FormatData(row["serviceCharge"].ToString(), "M");
            scCurr.Text = row["collCurr"].ToString();
            transferAmount.Text = GetStatic.FormatData(row["tAmt"].ToString(), "M");
            tAmtCurr.Text = row["collCurr"].ToString();
            payoutAmt.Text = GetStatic.FormatData(row["pAmt"].ToString(), "M");
            pAmtCurr.Text = row["payoutCurr"].ToString();

            tranStatus.Text = row["tranStatus"].ToString();
            modeOfPayment.Text = row["paymentMethod"].ToString();
            if(row["paymentMethod"].ToString() == "Bank Deposit")
            {
                pnlShowBankDetail.Visible = true;
                bankName.Text = row["BankName"].ToString();
                branchName.Text = row["BranchName"].ToString();
                accountNo.Text = row["accountNo"].ToString();
            }
            payoutMsg.Text = row["payoutMsg"].ToString();

            hddRCustomerId.Value = row["rCustomerId"].ToString();
            

            hddTran.Value = row["id"].ToString();
        }

        private void ApproveTranAPI()          //API
        {
            DataRow dr = obj.ApproveAPI(GetStatic.GetUser(), hddTran.Value, lblControlNo.Text, Session.SessionID);
            if (dr["code"].ToString() != "0")
            {
                GetStatic.CallBackJs1(Page, "Result", "alert('" + dr["message"] + "');");
                return;
            }
            DbResult dbResult = obj.ApproveTranAPI(GetStatic.GetUser(), hddTran.Value, lblControlNo.Text, Session.SessionID);
            ManageMessage(dbResult);
        }

        private void ApproveTranLocal()     //Local
        {
            DbResult dbResult = obj.ApproveTran(GetStatic.GetUser(), hddTran.Value, lblControlNo.Text, Session.SessionID);
            ManageMessage(dbResult);
        }   

        private void RejectTran()
        {
            DbResult dbResult = obj.Reject(GetStatic.GetUser(), hddTran.Value,"","");
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            string url = "../../ReprintVoucher/SendReceipt.aspx?controlNo=" + lblControlNo.Text;
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "','" + url + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        #region Element Method
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadGrid("");
        }

        protected void btnTranSelect_Click(object sender, EventArgs e)
        {
            string cNo = grid.GetRowId(GridName);
            LoadGrid(cNo);
            cAmt.Focus();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            RejectTran();
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            if(GetStatic.GetIsApiFlag() == "Y")
                ApproveTranAPI();
            else
                ApproveTranLocal();
        }

        protected void btnSearchTran_Click(object sender, EventArgs e)
        {
            string cNo = grid.GetRowId(GridName);
            var dbResult = obj.VerifyForApprove(GetStatic.GetUser(), cNo, cAmt.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.CallBackJs1(Page, "PrintMessage", "alert('" + dbResult.Msg + "');");
                return;
            }
            LoadByControlNo(cNo);
        }

        protected void btnSearchDetail_Click(object sender, EventArgs e)
        {
            string cNo = controlNo.Text;
            var dbResult = obj.VerifyForApprove(GetStatic.GetUser(), cNo, collectAmt.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.CallBackJs1(Page, "PrintMessage", "alert('" + dbResult.Msg + "');");
                return;
            }
            LoadByControlNo(cNo);
        }

        protected void ibtnShowHideSearch_Click(object sender, ImageClickEventArgs e)
        {
            if(_showHideSearchFlag == "show")
            {
                _showHideSearchFlag = "hide";
                ibtnShowHideSearch.ImageUrl = "../../../../Images/icon_hide.gif";
                tblAdvanceSearch.Visible = true;
            }
            else if(_showHideSearchFlag == "hide")
            {
                _showHideSearchFlag = "show";
                ibtnShowHideSearch.ImageUrl = "../../../../Images/icon_show.gif";
                tblAdvanceSearch.Visible = false;
            }
        }

        #endregion
    }
}