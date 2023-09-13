using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.CustomerDeposits;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Transaction.JPBankDetails
{
    public partial class List : System.Web.UI.Page
    {

        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly CustomerDepositDao _dao = new CustomerDepositDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20305000";
        private const string ViewFunctionIdAgent = "20305000";
        private const string MapFunctionId = "20305010";
        private const string MapFunctionIdAgent = "20305010";
        private const string UnMapFunctionId = "20305020";
        private const string UnMapFunctionIdAgent = "20305020";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "MapCustomerDeposits")
            {
                MapCustomerDeposit();
            }
            else if (MethodName == "UnMapCustomerDeposits")
            {
                UnMapCustomerDeposit();
            }
            else if (MethodName == "RefundCustomerDeposits")
            {
                RefundCustomerDeposits();
            }
            else if (MethodName == "SkipCustomerDeposits")
            {
                SkipCustomerDeposits();
            }
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDDL();
            }
            PopulateData();
        }

        private void PopulateDDL()
        {
            _sdd.SetStaticDdl(ref bankList, "7010", "", "SELECT BANK");
        }

        public void MapCustomerDeposit()
        {
            string tranId = Request.Form["rowId"];
            string customerId = Request.Form["customerId"];
            DbResult _dbRes = _dao.SaveCustomerDeposit(GetStatic.GetUser(), tranId, customerId, "");
            GetStatic.JsonResponse(_dbRes, Page);
        }
        public void UnMapCustomerDeposit()
        {
            string tranId = Request.Form["rowId"];
            string customerId = Request.Form["customerId"];
            DbResult _dbRes = _dao.UnMapCustomerDeposit2(GetStatic.GetUser(), tranId);
            GetStatic.JsonResponse(_dbRes, Page);
        }
        public void RefundCustomerDeposits()
        {
            string tranId = Request.Form["rowId"];
            string customerId = Request.Form["customerId"];
            DbResult _dbRes = _dao.RefundCustomerDeposit(GetStatic.GetUser(), tranId, customerId);
            GetStatic.JsonResponse(_dbRes, Page);
        }
        public void SkipCustomerDeposits()
        {
            string tranId = Request.Form["rowId"];
            string customerId = Request.Form["customerId"];
            DbResult _dbRes = _dao.SkipCustomerDeposits(GetStatic.GetUser(), tranId, customerId);
            GetStatic.JsonResponse(_dbRes, Page);
        }

        private void PopulateData()
        {
            try
            {
                DataTable dt = _dao.GetDepositDetail(GetStatic.GetUser(), GetFromDate(), GetToDate(), GetStatus());
                StringBuilder sb = new StringBuilder();

                int sNo = 1;

                if (null == dt || dt.Rows.Count == 0)
                {
                    sb.AppendLine("<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>");
                    mappedDeposits.InnerHtml = sb.ToString();
                    return;
                }
                foreach (DataRow item in dt.Rows)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + sNo + "</td>");
                    sb.AppendLine("<td>" + item["particulars"].ToString() + "</td>");
                    sb.AppendLine("<td>" + item["tranDate"].ToString() + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["depositAmount"].ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["paymentAmount"].ToString()) + "</td>");
                    sb.AppendLine("<td>" + item["TransactionId"].ToString() + "</td>");
                    if (item["processedBy"].ToString() != "")
                    {
                        sb.AppendLine("<td>" + item["fullName"].ToString() + "</td>");
                    }
                    else
                    {
                        sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["tranId"].ToString(), "'category' : 'remit-CustomerName'") + "</td>");
                    }


                    sb.AppendLine("<td>" + GetLinkText(item["tranId"].ToString(), item["processedBy"].ToString(), item["approvedBy"].ToString()) + "</td>");
                    sb.AppendLine("</tr>");
                    sb.AppendLine("<tr id=\"addModel" + item["tranId"].ToString() + "\"></tr>");
                    sNo++;
                }
                mappedDeposits.InnerHtml = sb.ToString();
            }
            catch (Exception ex)
            {

            }
        }

        private string GetLinkText(string rowId, string processedBy, string approvedBy)
        {
            var hasMapRole = sl.HasRight(MapFunctionId);
            var hasUnMapRole = sl.HasRight(UnMapFunctionId);

            string map = (hasMapRole == true) ? "" : "style=\"display: none;\"";
            string unmap = (hasUnMapRole == true) ? "" : "style=\"display: none;\"";
            string linkText = "";
            if (approvedBy.ToString() == "")
            {
                linkText = "<a title=\"Edit\" href=\"javascript:void(0);\" " + map + ">"
                             + "<span class=\"action-icon\">"
                                 + "<btn class=\"btn btn-xs btn-primary\" onclick=\"return ProcessData('" + rowId + "','refund')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Refund Deposit\">"
                                     + "<i class=\"fa fa-pencil\"></i>"
                                 + "</btn>"
                             + "</span>"
                         + "</a>";
                linkText += "&nbsp;<a title=\"Edit\" href=\"javascript:void(0);\" " + map + ">"
                   + "<span class=\"action-icon\">"
                       + "<btn class=\"btn btn-xs btn-primary\" onclick=\"return ProcessData('" + rowId + "','skip')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Skip Deposit\">"
                           + "<i class=\"fa fa-times\"></i>"
                       + "</btn>"
                   + "</span>"
               + "</a>";
            }

            if (processedBy == "")
            {
                return linkText += "&nbsp;<a title=\"View\" href=\"javascript:void(0);\" " + map + ">"
                         + "<span class=\"action-icon\">"
                             + "<btn class=\"btn btn-xs btn-success\" onclick=\"return ProcessData('" + rowId + "','map')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Map Deposit\">"
                                 + "<i class=\"fa fa-check - circle\"></i>"
                             + "</btn>"
                         + "</span>"
                     + "</a>&nbsp;";
            }
            else
            {
                if (approvedBy.ToString() == "")
                {
                    return linkText += "&nbsp;<a title=\"Edit\" href=\"javascript:void(0);\" " + unmap + ">"
                    + "<span class=\"action-icon\">"
                        + "<btn class=\"btn btn-xs btn-primary\" onclick=\"return ProcessData('" + rowId + "','unmap')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"UnMap Deposit\">"
                            + "<i class=\"fa fa-save\"></i>"
                        + "</btn>"
                    + "</span>"
                + "</a>";
                }
                else
                {
                    return "";
                }
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }
        protected string GetFromDate()
        {
            return GetStatic.ReadQueryString("from", "");
        }
        protected string GetToDate()
        {
            return GetStatic.ReadQueryString("to", "");
        }
        protected string GetStatus()
        {
            return GetStatic.ReadQueryString("status", "");
        }
    }
}