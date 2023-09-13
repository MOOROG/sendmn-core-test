using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
namespace Swift.web.Remit.Transaction.Modify
{
    public partial class ModifyTran : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20121500";
        private const string ProcessFunctionId = "20121510";
        readonly StaticDataDdl sd = new StaticDataDdl();
        private readonly ModifyTransactionDao _obj = new ModifyTransactionDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
          //  GetStatic.ResizeFrame(Page);
            //GetStatic.Process(ref btnSearchDetail);
            if (Request.QueryString["tranNo"] != null) {
        LoadByControlNo(Request.QueryString["tranNo"]);
      }
        }

        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        protected void btnSearchDetail_Click(object sender, EventArgs e)
        {
            LoadByControlNo(controlNo.Text);
        }

        private void LoadByControlNo(string cNo)
        {
            if (sd.HasRight(ProcessFunctionId))
                ucTran.SearchData("", cNo, "u", "", "MODIFY", "ADM: MODIFY TXN");
            else
                ucTran.SearchData("", cNo, "", "", "MODIFY", "ADM: MODIFY TXN");
            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }

            if (ucTran.TranStatus != "Payment")
            {
                string status = ucTran.TranStatus;
                divTranDetails.Visible = false;
                PrintMessage("Transaction not authorised for modification; Status:" + status + "!");
                return;
            }
            divTranDetails.Visible = ucTran.TranFound;
            divSearch.Visible = ucTran.TranFound;      //! thiyo agadi...
        }
        private void PrintMessage(string msg)
        {
               GetStatic.CallBackJs1(Page, "Msg", "RemoveProcessDivWithMsg('" + msg + "');");

        }

        protected void btnReloadDetail_Click(object sender, EventArgs e)
        {
            LoadByControlNo(ucTran.CtrlNo);
        }
    }
}