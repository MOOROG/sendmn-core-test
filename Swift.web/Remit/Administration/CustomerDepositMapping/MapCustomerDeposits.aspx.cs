using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.CustomerDeposits;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerDepositMapping
{
    public partial class MapCustomerDeposits : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly CustomerDepositDao _dao = new CustomerDepositDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20194000";
        private const string AssignFunctionId = "20194010";
        private const string ViewFunctionIdAgent = "20199000";
        private const string AssignFunctionIdAgent = "20199010";
        private const string SendFunctionIdAgent = "20199020";

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "MapCustomerDeposits")
            {
                MapCustomerDeposit();
            }
            if (MethodName == "MapCustomerSkipped")
            {
                MapCustomerSkipped();
            }
            if (MethodName == "GetCustomerDetails")
            {
                GetCustomerDetails();
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
            string logId = Request.Form["logId"];
            string customerId = Request.Form["customerId"];
            //string bankId = Request.Form["bankId"];
            string bankId = "11064";
            DbResult _dbRes = _dao.SaveCustomerDeposit(GetStatic.GetUser(), logId, customerId, bankId);
            GetStatic.JsonResponse(_dbRes, Page);
        }

        public void MapCustomerSkipped()
        {
            string logId = Request.Form["logId"];
            string isSkipped = Request.Form["isSkipped"];
            DbResult _dbRes = _dao.CustomerSkipped(GetStatic.GetUser(), logId, isSkipped);
            GetStatic.JsonResponse(_dbRes, Page);
        }

        private void PopulateData()
        {
            DataTable dt = _dao.GetDataForMapping(GetStatic.GetUser(),"");
            StringBuilder sb = new StringBuilder();

            if (null == dt || dt.Rows.Count == 0)
            {
                sb.AppendLine("<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>");
                customerDepositMapping.InnerHtml = sb.ToString();
                return;
            }

            int sNo = 1;

            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["particulars"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["tranDate"].ToString() + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["depositAmount"].ToString()) + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["paymentAmount"].ToString()) + "</td>");
                //if (isSkipped.SelectedValue != "0")
                //{
                //    sb.AppendLine("<td></td>");
                //}
                //else
                //{
                //    sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["tranId"].ToString(), "'category' : 'remit-CustomerName'") + "</td>");
                //}
                sb.AppendLine("<td>" + GetLinkText(item["tranId"].ToString(), item["bankName"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
                sb.AppendLine("<tr id=\"addModel" + item["tranId"].ToString() + "\"></tr>");
                sNo++;
            }
            customerDepositMapping.InnerHtml = sb.ToString();
        }

        private string GetLinkText(string rowId, string bankname)
        {
            if (true)
            {
                var hasAssignRole = sl.HasRight(GetFunctionIdByUserType(AssignFunctionIdAgent, AssignFunctionId));
                var hasSendRole = sl.HasRight(SendFunctionIdAgent);

                string showSendMoney = (GetStatic.GetUserType() == "HO") ? "N" : "Y";

                string disp = (hasAssignRole == true) ? "" : "style=\"display: none;\"";
                string disp1 = (hasSendRole == true && showSendMoney == "Y") ? "" : "style=\"display: none;\"";

                return "<a title=\"View\" href=\"javascript:void(0);\">"
                            + "<span class=\"action-icon\">"
                                + "<btn class=\"btn btn-xs btn-success\" onclick=\"return ValidateData('" + rowId + "', 'view','')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"View\">"
                                    + "<i class=\"fa fa-eye\"></i>"
                                + "</btn>"
                            + "</span>"
                        + "</a>"
                + "&nbsp;<a title=\"Edit\" href=\"javascript:void(0);\" " + disp + ">"
                            + "<span class=\"action-icon\">"
                                + "<btn class=\"btn btn-xs btn-primary\" onclick=\"return ValidateData('" + rowId + "', 'save','" + bankname + "')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Update\">"
                                    + "<i class=\"fa fa-save\"></i>"
                                + "</btn>"
                            + "</span>"
                        + "</a>"

                + "&nbsp;<a title=\"Edit\" href=\"javascript:void(0);\">"
                            + "<span class=\"action-icon\">"
                                + "<btn class=\"btn btn-xs btn-primary\" onclick=\"return IsSkippedData('" + rowId + "', 'skipped','1')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Skipped\">"
                                    + "<i class=\"fa fa-times\"></i>"
                                + "</btn>"
                            + "</span>"
                        + "</a> ";
            }
            else
            {
                return "<a title=\"View\" href=\"javascript:void(0);\">"
                         + "<span class=\"action-icon\">"
                             + "<btn class=\"btn btn-xs btn-success\" onclick=\"return IsSkippedData('" + rowId + "', 'skipped','0')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Skipped\">"
                                 + "<i class=\"fa fa-check - circle\"></i>"
                             + "</btn>"
                         + "</span>"
                     + "</a>&nbsp;";
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

        private void GetCustomerDetails()
        {
            var customerId = Request.Form["customerId"];
            var dr = _dao.GetCustomerDetail(customerId, GetStatic.GetUser());
            OnlineCustomerModel _customerModel = new OnlineCustomerModel
            {
                fullName = dr["fullName"].ToString(),
                mobile = dr["mobile"].ToString(),
                idType = dr["IdTypeName"].ToString(),
                idNumber = dr["idNumber"].ToString(),
                state = dr["state"].ToString(),
                city = dr["city"].ToString(),
                street = dr["street"].ToString(),
                membershipId = dr["membershipId"].ToString(),
                email = dr["email"].ToString(),
                dob = dr["dob"].ToString(),
            };

            GetStatic.JsonResponse(_customerModel, Page);
        }

        private string populateModel(DataRow data)
        {
            var sb = new StringBuilder();
            sb.AppendLine("<div id = \"myModal\" class=\"modal fade\" style=\"margin - top: 100px;\"><div class=\"modal-dialog\"><div class=\"modal-content\"><div class=\"modal-header\">");
            sb.AppendLine("<button type = \"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button><h4 class=\"modal-title\">Confirmation</h4></div>");
            sb.AppendLine("<div class=\"modal-body\"><div class=\"row\"><div class=\"col-md-6\"><div class=\"form-group<label>Name: &nbsp; <span><strong>" + data["fullName"].ToString() + "</strong></span></label></div></div>");
            sb.AppendLine("<div class=\"col-md-6\"><div class=\"form-group\"><label>Mobile No: &nbsp; <span><strong>" + data["mobile"].ToString() + "</strong></span></label></div></div>");
            sb.AppendLine("<div class=\"col-md-6\"><div class=\"form-group\"><label>Id Type: &nbsp; <span><strong>" + data["idType"].ToString() + "</strong></span></label></div></div>");
            sb.AppendLine("<div class=\"col-md-6\"><div class=\"form-group\"><label>Id NO: &nbsp; <span><strong>" + data["idNumber"].ToString() + "</strong></span></label></div></div>");
            sb.AppendLine("<div class=\"col-md-6\"><div class=\"form-group\"><label>Address: &nbsp; <span><strong>" + data["address"].ToString() + "</strong></span></label></div></div></div></div>");
            sb.AppendLine("<div class=\"modal-footer\"><button type = \"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button></div></div></div></div>");
            return sb.ToString();
        }

        protected void isSkipped_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateData();
        }
    }
}