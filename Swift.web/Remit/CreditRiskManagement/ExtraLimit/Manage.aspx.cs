using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.CreditRiskManagement.ExtraLimit
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20181520";
        private readonly CreditLimitDao obj = new CreditLimitDao();
        private readonly RemittanceLibrary rl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeAmountTextBox(ref todaysAddedMaxLimit);
                PopulateLimit();
                PopulatePendingRequestList();
            }
        }

        private void PopulateLimit()
        {
            DataRow dr = obj.SelectByIdForExtraLimit(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;
            hdnAgentId.Value = GetAgentId().ToString();
            currency.Text = dr["currencyCode"].ToString();
            maxLimitAmt.Text = GetStatic.FormatDataForForm(dr["maxLimitAmt"].ToString(), "M");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            rl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected string GetAgentName()
        {
            return rl.GetAgentName(GetAgentId().ToString());
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateExtraLimit(GetStatic.GetUser(), GetAgentId().ToString(), todaysAddedMaxLimit.Text);
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

        private void PopulatePendingRequestList()
        {
            var ds = obj.ShowPedningRequest(GetStatic.GetUser(), GetAgentId().ToString());

            if (ds == null)
            {
                rptPendingList.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("");
                str.Append("<fieldset><legend>Pending List For Approval</legend><table class='unpaidACdeposit' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i == 4)
                            str.Append("<td style=\"text-align:center\">" + dr[i].ToString() + "</td>");
                        else if (i == 1)
                            str.Append("<td style=\"text-align:right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</td>");
                        else
                            str.Append("<td align=\"left\">" + dr[i] + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table></fieldset>");
                rptPendingList.InnerHtml = str.ToString();
            }
        }
    }
}