using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library.Remittance;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Library
{
    public class RemittanceLibrary : RemittanceDao
    {
        private RemittanceDao obj = new RemittanceDao();

        public string CreateDynamicDropDownBox(string name, string sql, string valueField, string textField, string defaultValue)
        {
            var html = new StringBuilder("");
            var width = ""; //string.IsNullOrEmpty(width.Trim()) ? "" : " width = \"" + width + "\"";

            var dt = obj.ExecuteDataset(sql).Tables[0];
            html.Append("<select " + width + " name=\"" + name + "\" id =\"" + name + "\" class = \"form-control\">");

            foreach (DataRow row in dt.Rows)
            {
                html.Append("<option value=\"" + row[valueField].ToString() + "\"" + obj.AutoSelect(row[valueField].ToString(), defaultValue) + ">" + row[textField].ToString() + "</option>");
            }

            html.Append("</select>");

            return html.ToString();
        }

        public void SetExchangeDDL(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var exDao = obj;
            var ds = exDao.ExecuteDataset(sql);
            ListItem item = null;
            if (ds.Tables.Count == 0)
            {
                if (label != "")
                {
                    item = new ListItem(label, "");
                    ddl.Items.Add(item);
                }
                return;
            }
            var dt = ds.Tables[0];

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[valueField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SelectByTextDdl(ref DropDownList ddl, string text)
        {
            ListItem li = ddl.Items.FindByText(text);
            if (li != null)
            {
                li.Selected = true;
            }
        }

        public void SetStaticDDL(ref DropDownList ddl, string staticId, string valueField, string textField, string valueToBeSelected, string label)
        {
            if (string.IsNullOrWhiteSpace(staticId))
                return;
            var dt = ExecuteDataset("exec proc_dropDownList @FLAG = 'staticDdl',@typeId=" + FilterString(staticId)).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public string CreateDynamicDropDownBox(string name, DataTable dt, string defaultValue)
        {
            var html = new StringBuilder("");
            var width = "";
            if (dt == null || dt.Columns.Count == 0)
                return "";

            var valueField = dt.Columns[0].ColumnName;
            var textField = valueField;
            if (dt.Columns.Count > 1)
            {
                textField = dt.Columns[1].ColumnName;
            }

            html.Append("<select " + width + " name=\"" + name + "\" id =\"" + name + "\" class = \"formText\">");

            foreach (DataRow row in dt.Rows)
            {
                html.Append("<option value=\"" + row[valueField].ToString() + "\"" + AutoSelect(row[valueField].ToString(), defaultValue) + ">" + row[textField].ToString() + "</option>");
            }

            html.Append("</select>");

            return html.ToString();
        }

        public void ManageInvalidControlNoAttempt(Page page, string user, string isNewAttempt)
        {
            var ppDao = new PasswordPolicyDao();
            var dbResult = ppDao.ManageInvalidControlNoAttempt(user, isNewAttempt);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.SetMessage(dbResult);
                GetStatic.AlertMessage(page);
                GetStatic.CallBackJs1(page, "Logout", "window.location.replace('" + GetStatic.GetUrlRoot() + "/Logout.aspx');");
            }
        }

        public string CreateDynamicDropDownBox(string name, string sql, string defaultValue)
        {
            var dt = ExecuteDataTable(sql);
            return CreateDynamicDropDownBox(name, dt, defaultValue);
        }

        public void SetDefaultDdl(ref DropDownList ddl, string label, bool isClearItem)
        {
            if (isClearItem)
                ddl.Items.Clear();
            var item = new ListItem(label, "");
            ddl.Items.Add(item);
        }

        public void SetList(ref ListBox ddl, string sql, string valueField, string textField)
        {
            var dt = ExecuteDataset(sql).Tables[0];

            ddl.Items.Clear();

            foreach (DataRow row in dt.Rows)
            {
                ListItem item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();
                ddl.Items.Add(item);
            }

            dt.Dispose();
        }

        public void SetPayStatusDdl(ref DropDownList ddl, string valueToBeSelected, string label)
        {
            var sql = "EXEC proc_dropDownLists @flag= 'ps'";
            SetDDL(ref ddl, sql, "detailTitle", "detailDesc", valueToBeSelected, label);
        }

        public void SetTranStatusDdl(ref DropDownList ddl, string payStatus, string valueToBeSelected, string label)
        {
            var sql = "EXEC proc_dropDownLists @flag= 'ts', @param1=" + FilterString(payStatus);
            SetDDL(ref ddl, sql, "detailTitle", "detailDesc", valueToBeSelected, label);
        }

        public void SetDDL(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var ds = ExecuteDataset(sql);
            ListItem item = null;
            if (ds.Tables.Count == 0)
            {
                if (label != "")
                {
                    item = new ListItem(label, "");
                    ddl.Items.Add(item);
                }
                return;
            }
            var dt = ds.Tables[0];

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[valueField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SetDDL2(ref DropDownList ddl, string sql, string textField, string valueToBeSelected, string label)
        {
            var dt = ExecuteDataset(sql).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[textField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public string GetBranchEmail(string branchId, string user)
        {
            return GetSingleResult("SELECT DBO.FNAGetBranchEmail(" + FilterString(branchId) + "," + FilterString(user) + ")");
        }

        public void SetDDL3(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var dt = ExecuteDataset(sql).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SetRadioButton(ref RadioButtonList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var dt = ExecuteDataset(sql).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public bool CheckAuthentication(string functionId)
        {
            CheckSession();

            if (!HasRight(functionId))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetAuthenticationPage());
            }

            return true;
        }

        public void CheckSession()
        {
            var user = GetStatic.GetUser();
            if (string.IsNullOrWhiteSpace(user))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }

            UserPool userPool = UserPool.GetInstance();
            var loggedUser = GetStatic.GetLoggedInUser();
            if (string.IsNullOrWhiteSpace(loggedUser.UserName))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }

            if (!userPool.IsUserExists(GetStatic.GetUser()))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }
        }

        public void CheckSendTransactionAllowedTime()
        {
            if (!IsDate(RemittanceStatic.GetFromSendTrnTime()))
            {
                var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                HttpContext.Current.Response.Redirect(url);
            }
            else if (!IsDate(RemittanceStatic.GetToSendTrnTime()))
            {
                var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                HttpContext.Current.Response.Redirect(url);
            }
            else
            {
                DateTime frmSendTrnTime = Convert.ToDateTime(RemittanceStatic.GetFromSendTrnTime());
                DateTime toSendTrnTime = Convert.ToDateTime(RemittanceStatic.GetToSendTrnTime());

                if (RemittanceStatic.GetDateInNepalTz() < frmSendTrnTime || RemittanceStatic.GetDateInNepalTz() > toSendTrnTime)
                {
                    var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                    HttpContext.Current.Response.Redirect(url);
                }
            }
        }

        private bool IsDate(string sdate)
        {
            DateTime dt;
            bool isDate = true;

            try
            {
                dt = DateTime.Parse(sdate);
            }
            catch
            {
                isDate = false;
            }

            return isDate;
        }

        public void CheckPayTransactionAllowedTime()
        {
            if (!IsDate(RemittanceStatic.GetFromPayTrnTime()))
            {
                var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                HttpContext.Current.Response.Redirect(url);
            }
            else if (!IsDate(RemittanceStatic.GetToPayTrnTime()))
            {
                var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                HttpContext.Current.Response.Redirect(url);
            }
            else
            {
                DateTime frmPayTrnTime = Convert.ToDateTime(RemittanceStatic.GetFromPayTrnTime());
                DateTime toPayTrnTime = Convert.ToDateTime(RemittanceStatic.GetToPayTrnTime());
                if (RemittanceStatic.GetDateInNepalTz() < frmPayTrnTime || RemittanceStatic.GetDateInNepalTz() > toPayTrnTime)
                {
                    var url = GetStatic.GetUrlRoot() + "/OTExceed.aspx";
                    HttpContext.Current.Response.Redirect(url);
                }
            }
        }

        public bool HasRight(string functionId)
        {
            var applicationUserDao = new ApplicationUserDao();
            return applicationUserDao.HasRight(functionId, GetStatic.GetUser());
        }

        public static string ShowVoucherType(string vType)
        {
            string Voucher;
            vType.ToLower();

            if (vType == "j")
                Voucher = "Journal Voucher";
            else if (vType == "c")
                Voucher = "Contra Voucher";
            else if (vType == "r")
                Voucher = "Receipt Voucher";
            else if (vType == "y")
                Voucher = "Payment Voucher";
            else
                Voucher = "Voucher Type not defined";
            return Voucher;
        }

        public void BeginForm(string formCaption)
        {
            var htmlCode = new StringBuilder("");

            htmlCode.AppendLine("<table class=\"container\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"40%\">");
            htmlCode.AppendLine("<tbody>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td width=\"1%\" class=\"container_tl\"><div></div></td>");
            htmlCode.AppendLine("<td width=\"91%\" class=\"container_tmid\"><div>" + formCaption + "</div></td>");
            htmlCode.AppendLine("<td width=\"8%\" class=\"container_tr\"><div></div></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td class=\"container_l\"></td>");
            htmlCode.AppendLine("<td class=\"container_content\">");

            HttpContext.Current.Response.Write(htmlCode.ToString());
            htmlCode.Clear();
        }

        public void EndForm()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("<td class=\"container_r\"></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td class=\"container_bl\"></td>");
            htmlCode.AppendLine("<td class=\"container_bmid\"></td>");
            htmlCode.AppendLine("<td class=\"container_br\"></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</tbody>");
            htmlCode.AppendLine("</table>");
            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public void BeginHeaderForGrid(string headerCaption, string childAlign)
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("<table width=\"100%\" border=\"0\">");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td valign=\"bottom\" class=\"\" valign=\"buttom\">");
            htmlCode.AppendLine("<div class=\"BredCurm\">" + headerCaption + "</div>");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td valign=\"top\" align=\"" + childAlign + "\">");

            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public void BeginHeaderForGrid(string headerCaption)
        {
            BeginHeaderForGrid(headerCaption, "left");
        }

        public void EndHeaderForGrid()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</table>");

            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public string GetAuditLog(DataRow dr)
        {
            return GetAuditLog(dr, 1, false);
        }

        public string GetAuditLog(DataRow dr, int inputPerRow)
        {
            return GetAuditLog(dr, inputPerRow, false);
        }

        public string GetAuditLog(DataRow dr, int inputPerRow, bool isMakerChecker)
        {
            var htmlCode = new StringBuilder("");
            htmlCode.Append("<div style=\"font-size: 12px; font-weight: bold; font-style: italic; color: black;\">");
            htmlCode.Append("Created By : " + GetStatic.PutYellowBackGround("<b>[" + dr["createdBy"] + "]</b>"));
            htmlCode.Append(" On " + GetStatic.PutYellowBackGround("<b>[" + dr["createdDate"] + "]</b>&nbsp;"));
            if (inputPerRow > 1)
                htmlCode.Append("<br/>");
            htmlCode.Append("Last Modified By : " + GetStatic.PutYellowBackGround("<b>[" + dr["modifiedBy"] + "]</b>"));
            htmlCode.Append(" On " + GetStatic.PutYellowBackGround("<b>[" + dr["modifiedDate"] + "]</b>&nbsp;"));
            if (isMakerChecker)
            {
                if (inputPerRow > 2)
                    htmlCode.Append("<br/>");
                htmlCode.Append("Last Approved By : " + GetStatic.PutYellowBackGround("<b>[" + dr["approvedBy"] + "]</b>"));
                htmlCode.Append(" On " + GetStatic.PutYellowBackGround("<b>[" + dr["approvedDate"] + "]</b>&nbsp;"));
            }
            htmlCode.Append("</div>");
            return htmlCode.ToString();
        }

        public string GetTypeTitle(string typeId)
        {
            return obj.GetSingleResult("SELECT typeTitle FROM staticDataType WHERE typeId = " + obj.FilterString(typeId));
        }

        public string GetLoginUserName(string userId)
        {
            return obj.GetSingleResult("SELECT userName FROM applicationUsers WHERE userId = " + obj.FilterString(userId));
        }

        public string GetUserName(string userId)
        {
            return
                obj.GetSingleResult("SELECT name = ISNULL(firstName, '') + ISNULL( ' ' + middleName, '')+ ISNULL( ' ' + lastName, '') FROM applicationUsers WITH(NOLOCK) WHERE userId = " +
                                    obj.FilterString(userId));
        }

        public string GetAgentName(string agentId)
        {
            return obj.GetSingleResult("SELECT agentName FROM AgentMaster WITH(NOLOCK) WHERE agentId  = " +
                                    obj.FilterString(agentId));
        }

        public string GetAcNoByRemitCard(string remitCard)
        {
            return obj.GetSingleResult("select accountNo from kycMaster with(nolock) where remitCardNo = " +
                                    obj.FilterString(remitCard));
        }

        public string GetPackageName(string packageId)
        {
            return obj.GetSingleResult("select ltrim(rtrim(dbo.[FNAGetDataValue](" + packageId + ")))");
        }

        public string GetServiceTypeCategory(string serviceTypeId)
        {
            return obj.GetSingleResult("select category from serviceTypeMaster with(nolock) where serviceTypeId=" + serviceTypeId + "");
        }

        public string GetGroupName(string groupId)
        {
            return obj.GetSingleResult("select ltrim(rtrim(dbo.[FNAGetDataValue](" + groupId + ")))");
        }

        public string GetAgentBreadCrumb(string agentId)
        {
            return obj.GetSingleResult("EXEC proc_agentMaster @flag='bc', @agentId=" + FilterString(agentId) + ", @urlRoot = " + FilterString(GetStatic.GetUrlRoot()));
        }

        public string GetCountryName(string countryId)
        {
            return obj.GetSingleResult("SELECT countryName FROM countryMaster WITH(NOLOCK) WHERE countryId  = " +
                           obj.FilterString(countryId));
        }

        public string GetAgentCountryName(string agentId)
        {
            return obj.GetSingleResult(@"SELECT countryName FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId  IN (
                           SELECT agentCountry FROM AgentMaster WITH(NOLOCK) WHERE agentId  = " + obj.FilterString(agentId) + ")");
        }

        public string GetCustomerName(string customerId)
        {
            return obj.GetSingleResult("EXEC proc_customerMaster @flag='sn', @customerId=" + obj.FilterString(customerId));
        }

        public string GetAgentCountryId(string agentId)
        {
            return obj.GetSingleResult("SELECT agentCountry FROM AgentMaster WITH(NOLOCK) WHERE agentId  = " +
                                    obj.FilterString(agentId));
        }

        public string GetAgentCurrencyCode(string agentId)
        {
            return obj.GetSingleResult(@"SELECT currCode FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId  IN (
                           SELECT agentCountry FROM AgentMaster WITH(NOLOCK) WHERE agentId  = " + obj.FilterString(agentId) + ")");
        }

        public string GetEnableCashCollection(string agentId)
        {
            return obj.GetSingleResult(@"SELECT enableCashCollection FROM agentBusinessFunction WITH(NOLOCK) WHERE agentId  = " + obj.FilterString(agentId));
        }

        public string GetAgentRole(string agentId)
        {
            return obj.GetSingleResult(@"SELECT agentRole FROM agentMaster WITH(NOLOCK) WHERE agentId = " + obj.FilterString(agentId));
        }

        public double GetMaxAmount(string masterIdName, string masterId, string tableName)
        {
            var res = obj.GetSingleResult(@"SELECT MAX(toAmt) FROM " + tableName + " WHERE ISNULL(isDeleted, 'N') <> 'Y' AND " + masterIdName + " = " + obj.FilterString(masterId));
            if (res == "")
                res = "0";
            return Convert.ToDouble(res);
        }

        public string GetAgentGroup(string userId)
        {
            return obj.GetSingleResult("SELECT agentgrp  FROM agentmaster WITH(NOLOCK) WHERE agentid = " + obj.FilterString(userId));
        }

        public int GetSessionTimeOutPeriod()
        {
            var res =
                obj.GetSingleResult(@"SELECT sessionTimeOutPeriod FROM applicationUsers WITH(NOLOCK) WHERE userName = " + obj.FilterString(GetStatic.GetUser()));
            return (Convert.ToInt32(res));
        }

        public DataRow GetSessionUserDetail(string username)
        {
            var sql = @"EXEC proc_applicationUsers @flag = 'userDetail', @userName = " + obj.FilterString(username);
            var ds = obj.ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public void SetGenderDDL(ref DropDownList ddl, string valueToBeSelected, string label)
        {
            ddl.Items.Clear();
            if (label != "")
            {
                ddl.Items.Add(MakeItem("", label, ""));
            }
            ddl.Items.Add(MakeItem("Male", "Male", valueToBeSelected));
            ddl.Items.Add(MakeItem("Female", "Female", valueToBeSelected));
        }

        private ListItem MakeItem(string value, string text, string valueToBeSelected)
        {
            var item = new ListItem(text, value);

            if (string.IsNullOrWhiteSpace(valueToBeSelected))
                return item;

            if (valueToBeSelected.ToUpper().Equals(value.ToUpper()))
                item.Selected = true;

            return item;
        }

        public DbResult TranViewLog(
                          string user
                        , string tranId
                        , string controlNo
                        , string remarks
                        , string tranViewType
                    )
        {
            string sql = "EXEC proc_tranViewHistory";
            sql += "  @flag = 'i1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string GetAgentCancelType(string user)
        {
            return obj.GetSingleResult(@"SELECT ISNULL(B.isInternal,'N') isInternal FROM agentMaster a WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK)
                                        ON A.parentId=B.agentId
                                        WHERE A.agentId=(SELECT DISTINCT agentId
                                        FROM applicationUsers WITH(NOLOCK) WHERE userName='" + user + "')");
        }

        public string GetAgentCancelTypeAdmin(string controlNo)
        {
            return obj.GetSingleResult(@"SELECT ISNULL(B.isInternal,'N') isInternal
                        FROM agentMaster a WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK)
                        ON A.parentId=B.agentId
                        WHERE A.agentId=(SELECT sBranch FROM vwRemitTran WITH(NOLOCK) WHERE controlNo=DBO.FNAEncryptString('" + controlNo + "'))");
        }

        public string GetAgentNameByMapCodeInt(string mapCodeInt)
        {
            return obj.GetSingleResult("SELECT agentName FROM AgentMaster WITH(NOLOCK) WHERE mapcodeint  = " +
                                    obj.FilterString(mapCodeInt));
        }

        #region SMS

        private string SendSMS(string mobileNo, string msg, bool sendInBulk)
        {
            var apiid = GetStatic.ReadWebConfig("apiid");
            var userid = GetStatic.ReadWebConfig("userid");
            var pwd = GetStatic.ReadWebConfig("pwd");
            var senderName = GetStatic.ReadWebConfig("senderName");

            var client = new WebClient();
            client.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR1.0.3705;)");
            client.QueryString.Add("apiid", apiid);
            client.QueryString.Add("userid", userid);
            client.QueryString.Add("pwd", pwd);
            client.QueryString.Add("senderName", senderName);
            client.QueryString.Add("MobileNo", mobileNo);
            client.QueryString.Add("text", msg);
            var baseurl = sendInBulk ? GetStatic.ReadWebConfig("smsBulkURL") : GetStatic.ReadWebConfig("smsURL");
            var data = client.OpenRead(baseurl);
            var reader = new StreamReader(data);
            var s = reader.ReadToEnd();
            data.Close();
            reader.Close();
            return s;
        }

        public DbResult SendSMS(string mobileNo, string msg)
        {
            //var apiid = "47575";
            //var userid = "imesms";
            //var pwd = "Ktmnepal@1";
            //var senderName = "IMESYSTEM";
            //var MobileNo = number.Text;
            //var text = msg.Text;

            //"EXRATE FOR NEPAL 1 USD = 86.6 NPR, UPDATED ON (NST): 2013-04-02 17:53:27.643";

            var res = SendSMS(mobileNo, msg, false);
            return ParseSMSResponse(res, false);
        }

        public DbResult SendBulkSMS(string mobileNo, string msg)
        {
            var res = SendSMS(mobileNo, msg, true);
            return ParseSMSResponse(res, true);
        }

        private DbResult ParseSMSResponse(string res, Boolean sendInBulk)
        {
            var dr = new DbResult();
            dr.SetError("0", res, "");
            return dr;
        }

        #endregion SMS

        #region Grid

        public string CreateGrid(string gridName, string gridWidth, string sql, string rowIdField, bool showCheckBox, bool multiSelect, string columns, string cssClass, string callBackFunction)//, string editPage, bool allowEdit, bool allowDelete, bool allowApprove, string customLink, string customVariableList)
        {
            if (string.IsNullOrEmpty(cssClass))
                cssClass = "TBLReport";

            var html = new StringBuilder();

            var dt = ExecuteDataset(sql).Tables[0];
            var columnList = columns.Split(',');

            html.AppendLine(
                "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\" class=\"" + cssClass + "\" width = \"" +
                gridWidth + "px\" id =\"" + gridName + "_body\">");

            if (showCheckBox)
            {
                var headerFuntion = "SelectAll(this, '" + gridName + "'," + (multiSelect ? "true" : "false") + ");" + callBackFunction;
                html.AppendLine("<th Class=\"" + cssClass + "\" nowrap style = \"cursor:pointer;text-align: center\" onclick =\"" + headerFuntion + "\">" + (multiSelect ? "√" : "×") + "</th>");
            }

            var columnIndexArray = new ArrayList();

            foreach (var str in columnList)
            {
                columnIndexArray.Add(str);
            }

            var columnArray = new ArrayList();
            foreach (DataColumn col in dt.Columns)
            {
                columnArray.Add(col);
            }

            for (var i = 0; i < columnArray.Count; i++)
            {
                if (columns.Trim().Equals(""))
                {
                    html.AppendLine("<th align=\"left\" nowrap >" + columnArray[i] + "</th>");
                }
                else
                {
                    if (columnIndexArray.Contains(i.ToString()))
                    {
                        html.AppendLine("<th align=\"left\" nowrap >" + columnArray[i] + "</th>");
                    }
                }
            }

            html.AppendLine("</tr>");

            var checkBoxFunction = "";

            if (showCheckBox)
            {
                checkBoxFunction = "ManageSelection(this, '" + gridName + "'," + (multiSelect ? "true" : "false") + ");" +
                                   callBackFunction;
            }

            foreach (DataRow row in dt.Rows)
            {
                html.AppendLine("<tr>");
                if (showCheckBox)
                {
                    html.AppendLine("<td align=\"center\"><input type = \"checkbox\" value = \"" +
                                    row[rowIdField.ToLower()] + "\" name =\"" + gridName + "_rowId\" onclick = \"" +
                                    checkBoxFunction + "\"></td>");
                }

                for (var i = 0; i < dt.Columns.Count; i++)
                {
                    var data = row[i].ToString();
                    if (columns.Trim().Equals(""))
                    {
                        html.AppendLine("<td align=\"left\">" + GetStatic.FormatData(data, "") + "</td>");
                    }
                    else
                    {
                        if (columnIndexArray.Contains(i.ToString()))
                        {
                            html.AppendLine("<td align=\"left\">" + GetStatic.FormatData(data, "") + "</td>");
                        }
                    }
                }
                html.AppendLine("</tr>");
            }

            html.AppendLine("</table>");

            return html.ToString();
        }

        #endregion Grid

        public void SetYearDdl(ref DropDownList ddl, int low, int high, string label)
        {
            ListItem item = null;
            if (!string.IsNullOrWhiteSpace(label))
            {
                item = new ListItem { Value = "", Text = label };
                ddl.Items.Add(item);
            }
            for (int i = low; i <= high; i++)
            {
                item = new ListItem { Value = i.ToString(), Text = i.ToString() };
                ddl.Items.Add(item);
            }
        }

        public void SetMonthDdl(ref DropDownList ddl, string label)
        {
            ListItem item = null;
            if (!string.IsNullOrWhiteSpace(label))
            {
                item = new ListItem { Value = "", Text = label };
                ddl.Items.Add(item);
            }

            DateTime mnth = Convert.ToDateTime("1/1/2000");
            for (int i = 0; i < 12; i++)
            {
                DateTime nextMnth = mnth.AddMonths(i);
                item = new ListItem { Text = nextMnth.ToString("MMMM"), Value = nextMnth.ToString("MMMM") };
                ddl.Items.Add(item);
            }
        }
        public void AddOptionToDDL(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var ds = ExecuteDataset(sql);
            ListItem item = null;
            if (ds.Tables.Count == 0)
            {
                if (label != "")
                {
                    item = new ListItem(label, "");
                    ddl.Items.Add(item);
                }
                return;
            }
            var dt = ds.Tables[0];

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[valueField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        /*
        public DataTable GetData(string sql)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
        }
        public int UpdateData(String sql)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
        }
        public int DeleteData(String sql)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
        }
        public int AddUser(String sql)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                return cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
        }
        public DataTable SearchData(string sql)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
        }

        */
    }
}