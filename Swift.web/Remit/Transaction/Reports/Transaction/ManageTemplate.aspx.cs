using System;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.Transaction
{
    public partial class ManageTemplate : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly TranReportDao _rptDao = new TranReportDao();
        private string tranInfo = "";
        private string tranInfoAlias = "";
        private const string ViewFunctionId = "20163520";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                sdd.SetDDL(ref ddlTranInfo, "EXEC proc_manageTranRptTemplete @flag='TRANINFO'", "VALUE", "FIELD", "", "");
                sdd.SetDDL(ref ddlSendingAgent, "EXEC proc_manageTranRptTemplete @flag='SENDING_AGENT_INFO'", "VALUE", "FIELD", "", "");
                sdd.SetDDL(ref ddlSenderInfo, "EXEC proc_manageTranRptTemplete @flag='SENDER_INFO'", "VALUE", "FIELD", "", "");
                sdd.SetDDL(ref ddlRecAgent, "EXEC proc_manageTranRptTemplete @flag='REC_AGENT_INFO'", "VALUE", "FIELD", "", "");
                sdd.SetDDL(ref ddlRecInfo, "EXEC proc_manageTranRptTemplete @flag='REC_INFO'", "VALUE", "FIELD", "", "");
            }
            tranInfo = Request.Form["ddlTranInfoSelected"];
            tranInfoAlias = MakeAlias(tranInfo, "Transaction Information");
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private static string MakeAlias(string val, string prefix)
        {
            var aliasList = new StringBuilder();
            if (val != null)
            {
                var list = val.Split(',');
                var comma = "";
                foreach (var itm in list)
                {
                    if (itm == "[Collected Amount]" || itm == "[Sevice Charge]" || itm == "[Sevice Charge]" || itm == "[Exchange Rate]" ||
                        itm == "[Sending Amount]" || itm == "[Sender Commission]" || itm == "[Receiving Amount]" ||
                        itm == "[Settlement Rate]" || itm == "[Exchange Rate Premium]" || itm == "[Service Charge Discount]")
                    {
                        aliasList.Append(comma + "dbo.ShowDecimal(" + itm + ") as " + itm);
                    }
                    else
                    {
                        aliasList.Append(comma + itm);
                    }
                    comma = ", ";
                }
            }
            return aliasList.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Save();
        }

        private void Save()
        {
            var dbResult = _rptDao.MakeTransactionTemplate(
                                          GetStatic.GetUser()
                                        , tranInfo
                                        , tranInfoAlias
                                        , templateName.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }
    }
}