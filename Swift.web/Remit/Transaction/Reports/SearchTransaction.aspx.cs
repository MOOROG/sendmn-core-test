using System;
using System.Collections.Generic;
using System.Data;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports
{
    public partial class SearchTransaction : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20121800";
        private readonly SwiftGrid _grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                controlNoName.Text = GetStatic.GetTranNoName();
                string txnId = GetStatic.ReadQueryString("tranId", "");
                string cntNo = GetStatic.ReadQueryString("controlNo", "");
                if (!string.IsNullOrEmpty(txnId) || !string.IsNullOrEmpty(cntNo))
                {
                    ShowTxnDetail(txnId, cntNo);
                }
            }
            GetStatic.ResizeFrame(Page);
            GetStatic.Process(ref btnSearch);
            Misc.MakeNumericTextbox(ref txnNo, true);
        }

        private void Authenticate()
        {
            obj.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            searchTxnDiv.Visible = false;
      //string oldCtrl = controlNo.Text;
      //string upperControl = oldCtrl[0].ToString().ToUpper() + oldCtrl[1].ToString().ToUpper() + oldCtrl[2].ToString().ToUpper() + oldCtrl.Substring(3);
            ShowTxnDetail(txnNo.Text, controlNo.Text);
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }
        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") == "Y");
        }

        private void ShowTxnDetail(string txnId, string cntNo)
        {
            if (string.IsNullOrEmpty(txnId) && string.IsNullOrEmpty(cntNo))
            {
                GetStatic.AlertMessage(Page, "Sorry, Invalid Input.");
                return;
            }

            ucTran.ShowCommentBlock = ShowCommentFlag();
            ucTran.ShowBankDetail = ShowBankDetail();
            ucTran.ShowOfac = true;
            ucTran.ShowCompliance = true;
            ucTran.ShowApproveButton = true;

            ucTran.ShowCompliance = true;
            ucTran.ShowCommentBlock = ShowCommentFlag();
            ucTran.ShowBankDetail = ShowBankDetail();
            ucTran.SearchData(txnId, cntNo, "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");
            ucTran.ShowComplianceList();
            ucTran.ShowOFACList();
            if (!ucTran.TranFound)
            {
                GetStatic.AlertMessage(Page, "Sorry, Transaction Not Found.");
                return;
            }
            divTranDetails.Visible = ucTran.TranFound;
            ShowQuestionaireLink();
            LoadGrid();
            divControlno.Visible = !ucTran.TranFound;
        }
        public void ShowQuestionaireLink()
        {
            var obj = new TranViewDao();
            DataTable res = obj.QuestionaireExists(GetStatic.GetUser(), ucTran.HoldTranId);
            if (res.Rows.Count > 0)
            {
                questionaireDiv.Visible = true;
            }
            else
            {
                questionaireDiv.Visible = false;
            }
        }
        private void LoadGrid()
        {
            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("QUES_ID", "SN", "", "T"),
                                      new GridColumn("QSN", "Name", "Question", "T"),
                                      new GridColumn("ANSWER_TEXT", "Answer", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.AllowEdit = false;
            _grid.DisableSorting = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "QUES_ID";
            _grid.ThisPage = "ModifyTran.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            //_grid.AllowApprove = swiftLibrary.HasRight(ApproveFunctionId);
            string sql = "EXEC [proc_transactionView] @flag = 's-QuestionaireAnswer',@tranId='" + ucTran.HoldTranId + "'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}