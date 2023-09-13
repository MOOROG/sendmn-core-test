using System;
using System.Data;
using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity;
using Swift.web.Library;
using Swift.DAL.BL.Remit.Reconciliation;
using Swift.DAL.BL.System.GeneralSettings;

namespace Swift.web
{
    public partial class ShowFile : System.Web.UI.Page
    {
        
        private const string AgentFunctionId = "40121000";
        private const string BranchFunctionId = "20101000";
        private const string CustomerFunctionId = "20821800,20822000";
        private const string CustomerAgentFunctionId = "20101100";
        private const string CreditSecurityFunctionId = "20181400";
        private const string KycCustomerFunctionId = "20832000";
        private const string KycCustomerAgentFunctionId = "40134000";
        private const string ReconTxnUploadFunctionId = "20182130";
        private const string PopupMessage = "10111100";
        protected void Page_Load(object sender, EventArgs e)
        {
            DisplayFile();
        }

        private static string GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id").ToString();
        }

        private static string GetFunctionId()
        {
            return GetStatic.ReadQueryString("functionId", "");
        }

        private void DisplayFile()
        {
            try
            {
                var thisFunctionId = GetFunctionId();

                var url = GetStatic.GetUrlRoot();
                if (thisFunctionId == AgentFunctionId)
                {
                    var obj = new AgentDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == BranchFunctionId)
                {
                    var obj = new AgentDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == CustomerFunctionId)
                {
                    var obj = new CustomerDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == KycCustomerFunctionId)
                {
                    var obj = new CustomerDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == KycCustomerAgentFunctionId)
                {
                    var obj = new CustomerDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == CreditSecurityFunctionId)
                {
                    //var obj = new CreditSecurityDocDao();
                    //var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    //if (dr == null)
                    //    return;
                    //url = "img.ashx?functionId=20181400&id=" + dr["fileName"].ToString();
                    //Response.Redirect(url);
                    var obj = new CreditSecurityDocDao();
                    DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    Response.Redirect(url + "/doc/" + dr["fileName"].ToString());
                }
                if (thisFunctionId == CustomerAgentFunctionId)
                {
                    var obj = new CustomerDocumentDao();
                    var dr = obj.SelectById(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString();
                    Response.Redirect(url);
                }
                if (thisFunctionId == ReconTxnUploadFunctionId)
                {
           
                    var obj = new TxnDocumentsDao();
                    var dr = obj.SelectByIdTxn(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;                    
                    url = "img.ashx?id=" + dr["fileName"].ToString() + "&functionId=" + ReconTxnUploadFunctionId + "&year=" + dr["year"].ToString() + "&agent=" + dr["agentId"].ToString(); 
                    Response.Redirect(url);

                }
                if (thisFunctionId == PopupMessage)
                {
                    var _obj = new DynamicPopupMessageDao();
                    var dr = _obj.SelectByIdTxn(GetStatic.GetUser(), GetId());
                    if (dr == null)
                        return;
                    url = "img.ashx?id=" + dr["fileName"].ToString() + "&functionId=" + PopupMessage;
                    Response.Redirect(url);
                }
            }
            catch (Exception ex)
            {

            }
        }
    }
}