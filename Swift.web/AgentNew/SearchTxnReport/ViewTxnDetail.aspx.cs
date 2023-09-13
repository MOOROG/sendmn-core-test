using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.AgentNew.SearchTxnReport
{
    public partial class ViewTxnDetail : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40101700";
        private readonly StaticDataDdl sd = new StaticDataDdl();    
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                if (GetStatic.ReadQueryString("controlNo", "") != "")
                {
                    var contNo = GetStatic.ReadQueryString("controlNo", "").Split('|');
                    LoadByControlNo(contNo[0], contNo[1]);
                }
            }
        }
        protected void btnClick_Click(object sender, EventArgs e)
        {
            LoadByControlNo(hdnControlNo.Value, hdnStatus.Value);
            //LoadGrid();
        }

        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId);
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

        private void LoadByControlNo(string cNo, string tranStatus)
        {
            ucTran.SearchData("", cNo, "", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");

            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }

            divTranDetails.Visible = ucTran.TranFound;
            divSearch.Visible = !ucTran.TranFound;
            ShowQuestionaireLink();
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }
    }
}