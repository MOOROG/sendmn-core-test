using Swift.API.Common;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.Remit.Transaction.PayTransaction;
using Swift.DAL.BL.System.Notification;
using Swift.DAL.SwiftDAL;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Collections.Generic;
using System.Web.Script.Serialization;

using Swift.DAL.Common;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using Swift.DAL.Library;

//using SelectPdf;

namespace Swift.web.Library
{
    public static class GetStatic
    {
        public static DbResult LogError(HttpException lastError, string page)
        {
            Exception err = lastError;
            if (lastError.InnerException != null)
                err = lastError.InnerException;

            RemittanceDao db = new RemittanceDao();

            var errPage = db.FilterString(page);
            var errMsg = db.FilterString(err.Message);
            var errDetails = db.FilterString(lastError.GetHtmlErrorMessage());

            var user = string.IsNullOrWhiteSpace(GetUser()) ? "'UNKNOWN'" : GetUser();
            string sql = string.Format(@"EXEC proc_ErrorLogs @flag = 'i', @errorPage={0}, @errorMsg={1}, @errorDetails={2}, @user = {3}", errPage, errMsg, errDetails, user);

            return db.ParseDbResult(sql);
        }

        internal static void AttachConfirmMsg(ref object btnApprove, string v)
        {
            throw new NotImplementedException();
        }

        public static void EmailNotificationLog(SmtpMailSetting smtpMail)
        {
            RemittanceDao db = new RemittanceDao();

            string sql = "";
            sql = "EXEC proc_emailNotes @flag = 'i'";
            sql += ", @sendFrom=" + db.FilterString(smtpMail.SendEmailId);
            sql += ", @sendTo=" + db.FilterString(smtpMail.ToEmails);
            sql += ", @sendCc=" + db.FilterString(smtpMail.CcEmails);
            sql += ", @sendBcc=" + db.FilterString(smtpMail.BccEmails);
            sql += ", @subject=" + db.FilterString(smtpMail.MsgSubject);
            sql += ", @user=''";
            sql += ", @sendStatus=" + db.FilterString(smtpMail.Status);
            sql += ", @errorMsg=" + db.FilterString(smtpMail.MsgBody);
            db.ExecuteDataRow(sql);
        }

        public static int ToInt(this string val)
        {
            int myval;
            if (int.TryParse(val.Trim(), out myval))
            {
                return myval;
            }
            else
                return 0;
        }

        public static decimal ToDecimal(this string val)
        {
            decimal myval;
            if (decimal.TryParse(val.Trim(), out myval))
            {
                return myval;
            }
            else
                return 0;
        }

        public static string ToDate(this string val)
        {
            DateTime myval;
            if (DateTime.TryParse(val.Trim(), out myval))
            {
                return myval.ToString("yyyy-MM-dd");
            }
            else
                return "";
        }

        public static string RemoveComaFromMoney(string amt)
        {
            try
            {
                var Split = amt.Split('.');
                amt = Split[0];
            }
            catch (Exception e)
            {
                amt = "";
            }
            return amt.Replace(",", "");
        }

        public static DbResult CheckSlab(string pcnt, string minAmt, string maxAmt)
        {
            //bool PreError = false;
            var dbResult = new DbResult();
            if ((pcnt == "" ? "0" : pcnt) != "0")
            {
                if ((minAmt == "" ? "0" : minAmt) == "0" || (maxAmt == "" ? "0" : maxAmt) == "0")
                {
                    dbResult.Id = "1";
                    dbResult.Msg = "Please set Min or Max Amt ..";
                    //PreError = true;
                }
            }
            else if ((pcnt == "" ? "0" : pcnt) == "0" && (minAmt == "" ? "0" : minAmt) == "0")
            {
                dbResult.Id = "1";
                dbResult.Msg = "Please set Min Amt ..";
                //PreError = true;
            }

            return dbResult;
        }

        public static void Process(ref Button ctl)
        {
            var function = "return Process();";
            ctl.Attributes.Add("onclick", function);
        }

        public static double GetPayAmountLimit(string controlNo)
        {
            var pay = new PayDao();
            var limitAmount = pay.GetPayAmountLimit(GetStatic.GetUser(), controlNo);
            return limitAmount;
        }

        public static string GetSendingCountryBySCurr(string sCurr)
        {
            //var db = new SwiftDao();
            RemittanceDao db = new RemittanceDao();
            var sql = "EXEC proc_transactionUtility @flag='sCountry', @user=" + db.FilterString(GetUser()) + ", @curr=" + db.FilterString(sCurr);
            return db.GetSingleResult(sql);
        }

        public static string GetOFACSDN()
        {
            return ReadWebConfig("OFAC_SDN");
        }

        public static string GetOFACALT()
        {
            return ReadWebConfig("OFAC_ALT");
        }

        public static string GetOFACADD()
        {
            return ReadWebConfig("OFAC_ADD");
        }

        public static string GetOFACUNSCR()
        {
            return ReadWebConfig("OFAC_UNSCR");
        }

        public static string RemoveAllTags(string html)
        {
            var loop = true;
            var pFrom = 0;
            var pTo = 0;
            var refined = html;
            while (loop)
            {
                pFrom = refined.IndexOf("<");
                pTo = refined.IndexOf(">");

                var t = refined.Substring(pFrom, pTo + 1 - pFrom);
                if (string.IsNullOrWhiteSpace(t))
                {
                    return refined.Trim();
                }
                refined = refined.Replace(t, "");
                loop = refined.Contains("<") || refined.Contains(">");
            }

            return refined.Trim();
        }

        public static string RemoveHtmlTagsRegex(string input)
        {
            return Regex.Replace(input, "<.*?>", string.Empty);
        }

        public static String ShowFormatedCommaAmt(string strVal)
        {
            if (strVal != "")
            {
                var amt = double.Parse(strVal);
                amt = (amt < 0 ? amt * -1 : amt);
                return amt.ToString("C", System.Globalization.CultureInfo.CreateSpecificCulture("ko-KR"));
            }
            //return String.Format("{0:c}", double.Parse(strVal));
            else
                return strVal;
        }

        //public static string ReplaceFirst(string text, string search, string replace)
        //{
        //    int pos = text.IndexOf(search);
        //    if (pos < 0)
        //    {
        //        return text;
        //    }
        //    return text.Substring(0, pos) + replace + text.Substring(pos + search.Length);
        //}

        public static void GetPDF(string data)
        {
            //string newData = ReplaceFirst(data, "<table", "<table border='1' ");
            //string htmlData = newData;
            //SelectPdf.HtmlToPdf converter = new SelectPdf.HtmlToPdf();
            //converter.Options.PdfPageSize = PdfPageSize.A4;
            //converter.Options.PdfPageOrientation = PdfPageOrientation.Landscape;
            //converter.Options.WebPageWidth = 1024;
            //converter.Options.WebPageHeight = 0;
            //PdfDocument doc = converter.ConvertHtmlString(data);
            //doc.Save(HttpContext.Current.Response, true, "Report.pdf");
            //doc.Close();
        }

        public static string TXNDocumentUploadPath()
        {
            return ReadWebConfig("txnDocumentUploadPath");
        }

        public static string GetUserDateTime()
        {
            var db = new RemittanceDao();
            var sql = "EXEC proc_MatrixReport @flag = 'udt', @user = '" + GetUser() + "'";
            return db.GetSingleResult(sql);
        }

        public static string GetBranchName()
        {
            return ReadSession("branchName", "");
        }

        public static string GetAgentName()
        {
            return ReadSession("agentName", "");
        }

        public static string GetSuperAgent()
        {
            return ReadSession("superAgent", "");
        }

        public static string GetSuperAgentName()
        {
            return ReadSession("superAgentName", "");
        }

        public static string GetAgentType()
        {
            return ReadSession("agentType", "");
        }

        public static string GetSettlingAgent()
        {
            return ReadSession("settlingAgent", "");
        }

        public static string GetTranNoName()
        {
            return ReadWebConfig("tranNoName");
        }

        public static string GetAgentNameByMapCodeInt(string mapCodeInt)
        {
            var db = new SwiftDao();
            var sql = "SELECT agent_name FROM " + GetUtilityDAO.AccountDbName() + ".dbo.agentTable with(nolock) where map_code = '" + mapCodeInt + "'";
            return db.GetSingleResult(sql);
        }

        public static string GetMapCodeInt()
        {
            return ReadSession("mapCodeInt", "");
        }

        public static string GetIsApiFlag()
        {
            return ReadWebConfig("isAPI");
        }

        public static string GetMapCodeDom()
        {
            return ReadSession("mapCodeDom", "");
        }

        public static string GetIsActAsBranch()
        {
            return ReadSession("isActAsBranch", "");
        }

        public static string GetParentMapCodeInt()
        {
            return ReadSession("parentMapCodeInt", "");
        }

        public static string GetFundDepositVoucherPath()
        {
            return ReadWebConfig("fundDepositVoucher");
        }

        public static void AddTroubleTicket(Page page, string controlNo, string message, int successMessageType)
        {
            var obj = new TranViewDao();
            if (successMessageType == 1)
                PrintSuccessMessage(page, "Ticket Added Successfully");
            else if (successMessageType == 2)
                AlertMessage(page, "Ticket Added Successfully");
            ResizeFrame(page);
        }

        public static string GetFromSendTrnTime()
        {
            return ReadSession("fromSendTrnTime", "");
        }

        public static string GetToSendTrnTime()
        {
            return ReadSession("toSendTrnTime", "");
        }

        public static string GetFromPayTrnTime()
        {
            return ReadSession("fromPayTrnTime", "");
        }

        public static string GetToPayTrnTime()
        {
            return ReadSession("toPayTrnTime", "");
        }

        public static string GetCountryFlag(string countryCode)
        {
            var html = "<img src=\"" + GetUrlRoot() + "/images/countryflag/" + countryCode + ".png" + "\" border=\"0\">";
            return html;
        }

        public static void DataTable2ExcelDownload(ref DataTable table, string fileName)
        {
            string fileName_forSave = fileName + "_" + DateTime.Now.Year + "_" + DateTime.Now.Month + "_" + DateTime.Now.Day + "_" + DateTime.Now.ToString("hhmmss");

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.ClearContent();
            HttpContext.Current.Response.ClearHeaders();
            HttpContext.Current.Response.Buffer = true;
            HttpContext.Current.Response.ContentType = "application/ms-excel";
            HttpContext.Current.Response.Write(@"<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"">");
            HttpContext.Current.Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName_forSave + ".xls");

            HttpContext.Current.Response.Charset = "utf-8";
            HttpContext.Current.Response.ContentEncoding = System.Text.Encoding.GetEncoding("windows-1250");
            //sets font
            HttpContext.Current.Response.Write("<font style='font-size:10.0pt; font-family:Calibri;'>");
            HttpContext.Current.Response.Write("<br/><br/><br/>");
            //sets the table border, cell spacing, border color, font of the text, background, foreground, font height
            HttpContext.Current.Response.Write("<table border='1' bgColor='#ffffff' " +
              "borderColor='#000000' cellSpacing='0' cellPadding='0' " +
              "style='font-size:10.0pt; font-family:Calibri; background:white;'> <tr>");
            //am getting my grid's column headers
            int columnscount = table.Columns.Count;

            for (int j = 0; j < columnscount; j++)
            {      //write in new column
                HttpContext.Current.Response.Write("<td>");
                //Get column headers  and make it as bold in excel columns
                HttpContext.Current.Response.Write("<strong>");
                HttpContext.Current.Response.Write(table.Columns[j].ColumnName.ToString());
                HttpContext.Current.Response.Write("</strong>");
                HttpContext.Current.Response.Write("</td>");
            }
            HttpContext.Current.Response.Write("</tr>");

            int rowNum = 0, totalBorderRows = table.Rows.Count - 5;
            foreach (DataRow row in table.Rows)
            {//write in new row
                HttpContext.Current.Response.Write("<tr>");
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    if (fileName == "AccountStatement" && rowNum > totalBorderRows)
                    {
                        HttpContext.Current.Response.Write("<td style='border:0;'>");
                    }
                    else
                    {
                        HttpContext.Current.Response.Write("<td style='textmode'>");
                    }
                    //HttpContext.Current.Response.Write("");
                    HttpContext.Current.Response.Write(row[i].ToString());
                    HttpContext.Current.Response.Write("</td>");
                }

                HttpContext.Current.Response.Write("</tr>");
                rowNum++;
            }
            HttpContext.Current.Response.Write("</table>");
            HttpContext.Current.Response.Write("</font>");
            HttpContext.Current.Response.Flush();
            HttpContext.Current.Response.End();
        }

        public static DataTable ConvertHTMLTableToDataSet(string HTML)
        {
            // Declarations
            DataSet ds = new DataSet();
            DataTable dt = null;
            DataRow dr = null;
            string TableExpression = "<table[^>]*>(.*?)</table>";
            string HeaderExpression = "<th[^>]*>(.*?)</th>";
            string RowExpression = "<tr[^>]*>(.*?)</tr>";
            string ColumnExpression = "<td[^>]*>(.*?)</td>";
            bool HeadersExist = false;
            int iCurrentColumn = 0;
            int iCurrentRow = 0;

            // Get a match for all the tables in the HTML
            MatchCollection Tables = Regex.Matches(HTML, TableExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase);

            // Loop through each table element
            foreach (Match Table in Tables)
            {
                // Reset the current row counter and the header flag
                iCurrentRow = 0;
                HeadersExist = false;

                // Add a new table to the DataSet
                dt = new DataTable();
                // Create the relevant amount of columns for this table (use the headers if they
                // exist, otherwise use default names)
                if (Table.Value.Contains("<th"))
                {
                    // Set the HeadersExist flag
                    HeadersExist = true;

                    // Get a match for all the rows in the table
                    MatchCollection Headers = Regex.Matches(Table.Value, HeaderExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase);

                    // Loop through each header element
                    foreach (Match Header in Headers)
                    {
                        if (!dt.Columns.Contains(Header.Groups[1].ToString()))
                            dt.Columns.Add(Header.Groups[1].ToString().Replace("&nbsp;", ""));
                    }
                }
                else
                {
                    for (int iColumns = 1; iColumns <= Regex.Matches(Regex.Matches(Regex.Matches(Table.Value, TableExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase).ToString(), RowExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase).ToString(), ColumnExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase).Count; iColumns++)
                    {
                        dt.Columns.Add("Column " + iColumns);
                    }
                }
                // Get a match for all the rows in the table
                MatchCollection Rows = Regex.Matches(Table.Value, RowExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase);
                // Loop through each row element
                foreach (Match Row in Rows)
                {
                    // Only loop through the row if it isn't a header row
                    if (!(iCurrentRow == 0 & HeadersExist == true))
                    {
                        // Create a new row and reset the current column counter
                        dr = dt.NewRow();
                        iCurrentColumn = 0;
                        // Get a match for all the columns in the row
                        MatchCollection Columns = Regex.Matches(Row.Value, ColumnExpression, RegexOptions.Multiline | RegexOptions.Singleline | RegexOptions.IgnoreCase);
                        // Loop through each column element
                        foreach (Match Column in Columns)
                        {
                            if (Columns.Count - 1 != iCurrentColumn)
                                // Add the value to the DataRow
                                dr[iCurrentColumn] = Regex.Replace(Convert.ToString(Column.Groups[1]).Replace("&nbsp;", ""), "<.*?>", string.Empty);

                            // Increase the current column
                            iCurrentColumn += 1;
                        }
                        // Add the DataRow to the DataTable
                        dt.Rows.Add(dr);
                    }
                    // Increase the current row counter
                    iCurrentRow += 1;
                }
                // Add the DataTable to the DataSet
                ds.Tables.Add(dt);
            }
            return ds.Tables[0];
        }

        public static string GetCSVFileInTable(string path, bool hasHeader, int numberOfObjects = 0)
        {
            var dt = new DataTable();
            var columnList = new ArrayList();

            var sb = new StringBuilder("<root>");
            using (CsvReader reader = new CsvReader(path))
            {
                foreach (string[] values in reader.RowEnumerator)
                {
                    if (hasHeader)
                    {
                        dt.Columns.Clear();
                        dt.Clear();
                        foreach (var itm in values)
                        {
                            var data = itm.Replace(" ", "_").Replace("\"", "");
                            columnList.Add(data.ToUpper());
                        }
                        hasHeader = false;
                        continue;
                    }
                    if (values.Length > 0)
                    {
                        sb.Append("<row");
                        for (int i = 0; i < ((numberOfObjects == 0) ? values.Length : numberOfObjects); i++)
                        {
                            sb.Append(string.Format(" {0}=\"{1}\"", columnList[i].ToString().Trim(), values[i].ToString().Trim()));
                        }
                        sb.Append(" />");
                    }
                }
            }
            sb.Append("</root>");
            return sb.ToString();
        }

        public static string GetCSVFileInTableForTxnSyncInficare(string path, bool hasHeader, int numberOfObjects = 0)
        {
            var dt = new DataTable();
            var columnList = new ArrayList();

            var sb = new StringBuilder("<root>");
            using (CsvReader reader = new CsvReader(path))
            {
                foreach (string[] values in reader.RowEnumerator)
                {
                    if (hasHeader)
                    {
                        dt.Columns.Clear();
                        dt.Clear();
                        foreach (var itm in values)
                        {
                            var data = itm.Replace(" ", "_").Replace("\"", "").Replace(".", "");
                            if (string.IsNullOrEmpty(data))
                            {
                                data = "AgentName";
                            }
                            columnList.Add(data.ToUpper());
                        }
                        hasHeader = false;
                        continue;
                    }
                    if (values.Length > 0)
                    {
                        sb.Append("<row");
                        for (int i = 0; i < ((numberOfObjects == 0) ? values.Length : numberOfObjects); i++)
                        {
                            sb.Append(string.Format(" {0}=\"{1}\"", columnList[i].ToString().Trim(), values[i].ToString().Trim()));
                        }
                        sb.Append(" />");
                    }
                }
            }
            sb.Append("</root>");
            return sb.ToString();
        }

        public static DataTable GetHistoryChangedList(string logType, string oldData, string newData)
        {
            var stringSeparators = new[] { "-:::-" };

            var oldDataList = oldData.Split(stringSeparators, StringSplitOptions.None);
            var newDataList = newData.Split(stringSeparators, StringSplitOptions.None);

            var dt = new DataTable();
            var col1 = new DataColumn("Field");
            var col2 = new DataColumn("Old Value");
            var col3 = new DataColumn("New Value");
            var col4 = new DataColumn("hasChanged");

            dt.Columns.Add(col1);
            dt.Columns.Add(col2);
            dt.Columns.Add(col3);
            dt.Columns.Add(col4);

            var colCount = newData == "" ? oldDataList.Length : newDataList.Length;

            for (var i = 0; i < colCount; i++)
            {
                var changeList = ParseChangesToArray(logType, (oldData == "") ? "" : oldDataList[i], (newData == "") ? "" : newDataList[i]);

                var row = dt.NewRow();
                row[col1] = changeList[0];
                row[col2] = changeList[1];
                row[col3] = changeList[2];

                if (changeList[1] == changeList[2])
                {
                    row[col4] = "N";
                }
                else
                {
                    row[col4] = "Y";
                }
                dt.Rows.Add(row);
            }
            return dt;
        }

        //
        //public static string ToFilterStringNativeTrim(this string strVal)
        //{
        //    var db = new RemittanceDao();

        // var str = db.FilterQuoteNative(strVal);

        // if (str.ToLower() != "null") str = "'" + str + "'"; else str = "";

        //    return str;
        //}
        private static string[] ParseChangesToArray(string logType, string oldData, string newData)
        {
            const string seperator = "=";
            var oldValue = "";
            var newValue = "";
            var field = "";

            if (logType.ToLower() == "insert" || logType.ToLower() == "i" || logType.ToLower() == "update" || logType.ToLower() == "u" || logType.ToLower() == "login fails" || logType.ToLower() == "log in")
            {
                var seperatorPos = newData.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    field = newData.Substring(0, seperatorPos - 1).Trim();
                    newValue = newData.Substring(seperatorPos + 1).Trim();
                }
            }

            if (logType.ToLower() == "delete" || logType.ToLower() == "d" || logType.ToLower() == "update" || logType.ToLower() == "u")
            {
                var seperatorPos = oldData.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    if (field == "")
                        field = oldData.Substring(0, seperatorPos - 1).Trim();

                    oldValue = oldData.Substring(seperatorPos + 1).Trim();
                }
            }
            return new[] { field, oldValue, newValue };
        }

        public static DataTable GetHistoryChangedListForAgent(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForAgent(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForFunction(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForFunction(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForRole(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForRole(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForRuleCriteria(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForRuleCriteria(oldData, newData);
        }

        public static double RoundOff(double num, int place, int currDecimal)
        {
            if (currDecimal != 0)
                return Math.Round(num, currDecimal);
            else if (place != 0)
                return (Math.Round(num / place)) * place;
            return Math.Round(num, 0);
        }

        public static Boolean IsNumeric(string stringToTest)
        {
            int result;
            return int.TryParse(stringToTest, out result);
        }

        #region Userpool

        public static string GetFullName(string firstName, string middleName, string lastName1, string lastName2)
        {
            var fullName = firstName;
            if (!string.IsNullOrWhiteSpace(middleName))
                fullName += " " + middleName;
            if (!string.IsNullOrWhiteSpace(lastName1))
                fullName += " " + lastName1;
            if (!string.IsNullOrEmpty(lastName2))
                fullName += " " + lastName2;

            return fullName;
        }

        public static string GetAgent()
        {
            return ReadSession("agent", "");
        }

        public static string GetCountry()
        {
            return ReadSession("country", "");
        }

        public static string GetUser()
        {
            var user = ReadSession("admin", "");
            WriteSession("admin", user);
            //WriteSession("lastActiveTS", DateTime.Now.ToString());
            return user;
        }

        public static string GetAgentId()
        {
            var branchId = ReadSession("branchId", "");
            //WriteSession("lastActiveTS", DateTime.Now.ToString());
            return branchId;
        }

        public static string GetUserType()
        {
            var userType = ReadSession("userType", "");
            //WriteSession("lastActiveTS", DateTime.Now.ToString());
            return userType;
        }

    public static string GetUserAccessLevel() {
      return ReadSession("userAccessLevel", "");
    }

        public static void RemoveUserSession()
        {
            WriteSession("admin", "");
        }

        #endregion Userpool

        public static string GetBranch()
        {
            return ReadSession("branch", "");
        }

        public static string GetDcInfo()
        {
            return GetLoggedInUser().DcInfo;
            return HttpContext.Current.Request.ClientCertificate["SERIALNUMBER"] + ":" + HttpContext.Current.Request.ClientCertificate["SUBJECTCN"];
        }

        public static string GetIp()
        {
            return GetLoggedInUser().IPAddress;
            return HttpContext.Current.Request.ClientCertificate["REMOTE_ADDR"];
        }

        public static string ToShortDate(string datetime)
        {
            try
            {
                DateTime dt;
                DateTime.TryParse(datetime, out dt);

                return dt.ToShortDateString();
            }
            catch
            {
                return "";
            }
        }

        public static string GetSessionId()
        {
            return HttpContext.Current.Session.SessionID;
        }

        public static string EncryptPassword(string pwd)
        {
            return pwd;
        }

        public static int GetSessionTimeOut()
        {
            return 0;
        }

        #region Read/Write Data

        public static string ReadCookie(string key, string defVal)
        {
            var cookie = HttpContext.Current.Request.Cookies[key];
            return cookie == null ? defVal : HttpContext.Current.Server.HtmlEncode(cookie.Value);
        }

        public static string ReadFormData(string key, string defVal)
        {
            return HttpContext.Current.Request.Form[key] ?? defVal;
        }

        public static string GetCountDownInSec()
        {
            return (ReadWebConfig("countDownInSec") ?? "0").ToString();
        }

        public static string ReadQueryString(string key, string defVal)
        {
            return HttpContext.Current.Request.QueryString[key] ?? defVal;
        }

        public static string ReadValue(string gridName, string key)
        {
            key = gridName + "_ck_" + key;
            var ck = ReadCookie(key, "");
            return ck;
        }

        public static void WriteValue(string gridName, ref DropDownList ddl, string key)
        {
            key = gridName + "_ck_" + key;
            WriteCookie(key, ddl.Text);
        }

        public static void WriteValue(string gridName, ref TextBox tb, string key)
        {
            key = gridName + "_ck_" + key;
            WriteCookie(key, tb.Text);
        }

        #endregion Read/Write Data

        public static string ReadSession(string key, string defVal)
        {
            try
            {
                return HttpContext.Current.Session[key] == null ? defVal : HttpContext.Current.Session[key].ToString();
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        public static DataTable ReadSessionAsTable(string key)
        {
            try
            {
                return HttpContext.Current.Session[key] == null ? null : HttpContext.Current.Session[key] as DataTable;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public static void WriteSessionAsDataTable(string key, DataTable dt)
        {
            HttpContext.Current.Session[key] = dt;
        }

        public static void WriteSession(string key, string value)
        {
            HttpContext.Current.Session[key] = value;
        }

        public static void RemoveSession(string key)
        {
            if (HttpContext.Current.Session[key] == null)
            {
                return;
            }
            HttpContext.Current.Session.Remove(key);
        }

        public static void DeleteCookie(string key)
        {
            if (HttpContext.Current.Request.Cookies[key] != null)
            {
                var aCookie = new HttpCookie(key);
                aCookie.Expires = DateTime.Now.AddDays(-1);
                HttpContext.Current.Response.Cookies.Add(aCookie);
            }
        }

        public static void AttachJSFunction(ref Button ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachConfirmMsg(ref Button ctl)
        {
            AttachConfirmMsg(ref ctl, "Are you sure?");
        }

        public static void AttachJSFunction(ref DropDownList ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachJSFunction(ref TextBox ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachConfirmMsg(ref Button ctl, string confirmText)
        {
            var function = "return confirm('" + confirmText + "');";
            ctl.Attributes.Add("onclick", function);
        }

        public static LoggedInUser GetLoggedInUser()
        {
            var userPool = UserPool.GetInstance();
            return userPool.GetUser(GetUser());
        }

        public static void WriteCookie(string key, string value)
        {
            if (string.IsNullOrEmpty(value.Trim()))
            {
                DeleteCookie(key);
                return;
            }

            var httpCookie = new HttpCookie(key, value);
            httpCookie.Expires = DateTime.Now.AddDays(1);
            HttpContext.Current.Response.Cookies.Add(httpCookie);
        }

        public static string FormatData(string data)
        {
            if (string.IsNullOrEmpty(data))
                return "";
            decimal m;
            decimal.TryParse(data, out m);

            return m.ToString("F2");
        }

        public static string FormatData(string data, string dataType)
        {
            if (string.IsNullOrEmpty(data))
                return "&nbsp;";
            if (data == "-")
                return data;
            if (dataType == "D")
            {
                DateTime d;
                DateTime.TryParse(data, out d);
                return d.Year + "/" + d.Month.ToString("00") + "/" + d.Day.ToString("00");
            }

            if (dataType == "DT")
            {
                DateTime t;
                DateTime.TryParse(data, out t);
                return t.Year + "/" + t.Month.ToString("00") + "/" + t.Day.ToString("00") + " " + t.Hour.ToString("00") + ":" + t.Minute.ToString("00");
            }

            if (dataType == "M")
            {
                decimal m;
                decimal.TryParse(data, out m);

                return m.ToString("N");
            }
            return data;
        }

        public static string FormatDataForForm(string data, string dataType)
        {
            if (string.IsNullOrEmpty(data))
                return "";
            if (data == "-")
                return data;
            if (dataType == "D")
            {
                DateTime d;
                DateTime.TryParse(data, out d);
                return d.Year + "/" + d.Month.ToString("00") + "/" + d.Day.ToString("00");
            }

            if (dataType == "DT")
            {
                DateTime t;
                DateTime.TryParse(data, out t);
                return t.Year + "/" + t.Month.ToString("00") + "/" + t.Day.ToString("00") + " " + t.Hour.ToString("00") + ":" + t.Minute.ToString("00");
            }

            if (dataType == "M")
            {
                decimal m;
                decimal.TryParse(data, out m);

                return m.ToString("N");
            }
            return data;
        }

        public static string NumberToWord(string data)
        {
            var str = data.Split('.');
            int number = Convert.ToInt32(str[0]);
            int dec = 0;
            if (str.Length > 1)
                dec = Convert.ToInt32(str[1].Substring(0, 2));

            if (number == 0) return "Zero";

            if (number == -2147483648)
                return                    
                    ReadWebConfig("minusTwoHundred", "");

            int[] num = new int[4];
            int first = 0;
            int u, h, t;
            StringBuilder sb = new System.Text.StringBuilder();

            if (number < 0)
            {
                sb.Append("Minus ");
                number = -number;
            }

            string[] words0 = {
                                  "", "One ", "Two ", "Three ", "Four ",
                                  "Five ", "Six ", "Seven ", "Eight ", "Nine "
                              };

            string[] words1 = {
                                  "Ten ", "Eleven ", "Twelve ", "Thirteen ", "Fourteen ",
                                  "Fifteen ", "Sixteen ", "Seventeen ", "Eighteen ", "Nineteen "
                              };

            string[] words2 = {
                                  "Twenty ", "Thirty ", "Forty ", "Fifty ", "Sixty ",
                                  "Seventy ", "Eighty ", "Ninety "
                              };

            string[] words3 = { "Thousand ", "Lakh ", "Crore " };

            num[0] = number % 1000;               // units
            num[1] = number / 1000;
            num[2] = number / 100000;
            num[1] = num[1] - 100 * num[2];       // thousands
            num[3] = number / 10000000;           // crores
            num[2] = num[2] - 100 * num[3];       // lakhs

            for (int i = 3; i > 0; i--)
            {
                if (num[i] != 0)
                {
                    first = i;
                    break;
                }
            }

            for (int i = first; i >= 0; i--)
            {
                if (num[i] == 0) continue;

                u = num[i] % 10;  // ones
                t = num[i] / 10;
                h = num[i] / 100; // hundreds
                t = t - 10 * h;   // tens

                if (h > 0) sb.Append(words0[h] + "Hundred ");

                if (u > 0 || t > 0)
                {
                    if (h > 0 && i == 0) sb.Append("and ");

                    if (t == 0)
                        sb.Append(words0[u]);
                    else if (t == 1)
                        sb.Append(words1[u]);
                    else
                        sb.Append(words2[t - 2] + words0[u]);
                }

                if (i != 0) sb.Append(words3[i - 1]);
            }

            //sb.Append(" Rupees ");

            int d1 = dec / 10;
            int d2 = dec % 10;
            if (d1 == 0)
                sb.Append(words0[d1]);
            else if (d1 == 1)
                sb.Append(words1[d2]);
            else
                sb.Append(words2[d1 - 2] + words0[d2]);

            //if (dec > 0)
            //    sb.Append(" Paisa");
            return sb.ToString().TrimEnd() + " only";
        }

        public static string NumberToWord(string data, string currName, string currDecimal)
        {
            var str = data.Split('.');
            int number = Convert.ToInt32(str[0]);
            int dec = 0;
            if (str.Length > 1)
                dec = Convert.ToInt32(str[1].Substring(0, 2));

            if (number == 0) return "Zero";

            if (number == -2147483648)
                return
                    ReadWebConfig("minusTwoHundred", "");

            int[] num = new int[4];
            int first = 0;
            int u, h, t;
            StringBuilder sb = new System.Text.StringBuilder();

            if (number < 0)
            {
                sb.Append("Minus ");
                number = -number;
            }

            string[] words0 = {
                                  "", "One ", "Two ", "Three ", "Four ",
                                  "Five ", "Six ", "Seven ", "Eight ", "Nine "
                              };

            string[] words1 = {
                                  "Ten ", "Eleven ", "Twelve ", "Thirteen ", "Fourteen ",
                                  "Fifteen ", "Sixteen ", "Seventeen ", "Eighteen ", "Nineteen "
                              };

            string[] words2 = {
                                  "Twenty ", "Thirty ", "Forty ", "Fifty ", "Sixty ",
                                  "Seventy ", "Eighty ", "Ninety "
                              };

            //string[] words3 = { "Thousand ", "Lakh ", "Crore " };

            string[] words3 = { "Thousand ", "Million ", "Billion " };
            num[0] = number % 1000;           // units
            num[1] = number / 1000;
            num[2] = number / 1000000;
            num[1] = num[1] - 1000 * num[2];  // thousands
            num[3] = number / 1000000000;     // billions
            num[2] = num[2] - 1000 * num[3];  // millions
            for (int i = 3; i > 0; i--)
            {
                if (num[i] != 0)
                {
                    first = i;
                    break;
                }
            }

            //for (int i = first; i >= 0; i--)
            //{
            //    if (num[i] == 0) continue;
            //    u = num[i] % 10;              // ones
            //    t = num[i] / 10;
            //    h = num[i] / 100;             // hundreds
            //    t = t - 10 * h;               // tens
            //    if (h > 0) sb.Append(words0[h] + "Hundred ");
            //    if (u > 0 || t > 0)
            //    {
            //        if (h > 0 || i < first) sb.Append("and ");
            //        if (t == 0)
            //            sb.Append(words0[u]);
            //        else if (t == 1)
            //            sb.Append(words1[u]);
            //        else
            //            sb.Append(words2[t - 2] + words0[u]);
            //    }
            //    if (i != 0) sb.Append(words3[i - 1]);
            //}

            //num[0] = number % 1000;               // units
            //num[1] = number / 1000;
            //num[2] = number / 100000;
            //num[1] = num[1] - 100 * num[2];       // thousands
            //num[3] = number / 10000000;           // crores
            //num[2] = num[2] - 100 * num[3];       // lakhs

            //for (int i = 3; i > 0; i--)
            //{
            //    if (num[i] != 0)
            //    {
            //        first = i;
            //        break;
            //    }
            //}

            for (int i = first; i >= 0; i--)
            {
                if (num[i] == 0) continue;

                u = num[i] % 10;  // ones
                t = num[i] / 10;
                h = num[i] / 100; // hundreds
                t = t - 10 * h;   // tens

                if (h > 0) sb.Append(words0[h] + "Hundred ");

                if (u > 0 || t > 0)
                {
                    if (h > 0 && i == 0) sb.Append("and ");
                    //if (h > 0 || i < first) sb.Append("and ");
                    //if (h > 0) sb.Append("and ");
                    if (t == 0)
                        sb.Append(words0[u]);
                    else if (t == 1)
                        sb.Append(words1[u]);
                    else
                        sb.Append(words2[t - 2] + words0[u]);
                }

                if (i != 0) sb.Append(words3[i - 1]);
            }

            sb.Append(" " + currName + " ");

            int d1 = dec / 10;
            int d2 = dec % 10;
            if (d1 == 0)
                sb.Append(words0[d1]);
            else if (d1 == 1)
                sb.Append(words1[d2]);
            else
                sb.Append(words2[d1 - 2] + words0[d2]);

            if (dec > 0 && !string.IsNullOrEmpty(currDecimal))
                sb.Append(" " + currDecimal);
            return sb.ToString().TrimEnd() + " only";
        }

        #region Read From Web Config

        public static string GetAppRoot()
        {
            return ReadWebConfig("root");
        }

        public static string GetFilePath()
        {
            return ReadWebConfig("filePath");
        }

        public static string GetCustomerFilePath()
        {
            return ReadWebConfig("customerDocPath");
        }

        public static string GetUrlRoot()
        {
            return ReadWebConfig("urlRoot");
        }

        public static string GetVirtualDirName()
        {
            return ReadWebConfig("virtualDirName");
        }

        public static string GetDBUrlRoot()
        {
            return ReadWebConfig("dbUrlRoot");
        }

        public static string GetDBRoot()
        {
            return ReadWebConfig("dbRoot");
        }

        public static string GetReportPagesize()
        {
            return ReadWebConfig("reportPageSize");
        }

        public static string GetUploadFileSize()
        {
            return ReadWebConfig("fileSize");
        }

        #endregion Read From Web Config

        public static DataTable GetStringToTable(string data)
        {
            var stringSeparators = new[] { "-:::-" };

            var dataList = data.Split(stringSeparators, StringSplitOptions.None);

            var dt = new DataTable();
            var col1 = new DataColumn("field1");
            var col2 = new DataColumn("field2");
            var col3 = new DataColumn("field3");

            dt.Columns.Add(col1);
            dt.Columns.Add(col2);
            dt.Columns.Add(col3);

            var colCount = dataList.Length;

            for (var i = 0; i < colCount; i++)
            {
                var changeList = dataList[i].Split('=');
                var changeListCout = changeList.Length;
                var value1 = changeListCout > 0 ? changeList[0].Trim() : "";
                var value2 = changeListCout > 1 ? changeList[1].Trim() : "";
                var value3 = changeListCout > 2 ? changeList[2].Trim() : "";

                var row = dt.NewRow();
                row[col1] = value1;
                row[col2] = value2;
                row[col3] = value3;

                dt.Rows.Add(row);
            }
            return dt;
        }

        public static DbResult GetPasswordStatus()
        {
            DbResult dr = null;
            if (HttpContext.Current.Session["passwordStatus"] != null)
            {
                dr = (DbResult)HttpContext.Current.Session["passwordStatus"];
            }
            return dr;
        }

        public static void SetPasswordStatus(DbResult dr)
        {
            HttpContext.Current.Session["passwordStatus"] = dr;
        }

        public static string GetUserName()
        {
            var identityArray = HttpContext.Current.User.Identity.Name.Split('\\');
            return identityArray.Length > 1 ? identityArray[1] : identityArray[0];
        }

        public static string GetLogoutPage()
        {
            return GetUrlRoot() + "/Logout.aspx";
        }

        public static string GetErrorPage()
        {
            return GetUrlRoot() + "/Error.aspx";
        }

        public static string GetAuthenticationPage()
        {
            return GetUrlRoot() + "/Authentication.aspx";
        }

        public static string NoticeMessage
        {
            get { return ReadSession("message", ""); }
            set { WriteSession("message", value); }
        }

        public static bool ToImage(this string value)
        {
            value = value.ToLower();
            if (!value.Contains("."))
            {
                value = "." + value;
            }
            if (value == ".jpeg" || value == ".jpg" || value == ".png" || value == ".gif" || value == ".bmp")
                return true;
            else
            {
                return false;
            }
        }

        public static string DataTable2ExcelXML(ref DataTable dt)
        {
            var date = DateTime.Now.Date.ToString("yyyy-MM-dd");
            var header = new StringBuilder("");

            header.AppendLine("<?xml version=\"1.0\"?>");
            header.AppendLine("<?mso-application progid=\"Excel.Sheet\"?>");
            header.AppendLine("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"");
            header.AppendLine("xmlns:o=\"urn:schemas-microsoft-com:office:office\"");
            header.AppendLine("xmlns:x=\"urn:schemas-microsoft-com:office:excel\"");
            header.AppendLine("xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"");
            header.AppendLine("xmlns:html=\"http://www.w3.org/TR/REC-html40\">");
            header.AppendLine("<DocumentProperties xmlns=\"urn:schemas-microsoft-com:office:office\">");
            header.AppendLine("<Created>" + date + "</Created>");
            header.AppendLine("<LastSaved>" + date + "</LastSaved>");
            header.AppendLine("<Version>12.00</Version>");
            header.AppendLine("</DocumentProperties>");
            header.AppendLine("<OfficeDocumentSettings xmlns=\"urn:schemas-microsoft-com:office:office\">");
            header.AppendLine("<RemovePersonalInformation/>");
            header.AppendLine("</OfficeDocumentSettings>");
            header.AppendLine("<ExcelWorkbook xmlns=\"urn:schemas-microsoft-com:office:excel\">");
            header.AppendLine("<WindowHeight>8010</WindowHeight>");
            header.AppendLine("<WindowWidth>14805</WindowWidth>");
            header.AppendLine("<WindowTopX>240</WindowTopX>");
            header.AppendLine("<WindowTopY>105</WindowTopY>");
            header.AppendLine("<ProtectStructure>False</ProtectStructure>");
            header.AppendLine("<ProtectWindows>False</ProtectWindows>");
            header.AppendLine("</ExcelWorkbook>");
            header.AppendLine("<Styles>");
            header.AppendLine("<Style ss:ID=\"Default\" ss:Name=\"Normal\">");
            header.AppendLine("<Alignment ss:Vertical=\"Bottom\"/>");
            header.AppendLine("<Borders/>");
            header.AppendLine("<Font ss:FontName=\"Calibri\" x:Family=\"Swiss\" ss:Size=\"11\" ss:Color=\"#000000\"/>");
            header.AppendLine("<Interior/>");
            header.AppendLine("<NumberFormat/>");
            header.AppendLine("<Protection/>");
            header.AppendLine("</Style>");
            header.AppendLine("<Style ss:ID=\"s16\">");
            header.AppendLine(" <NumberFormat ss:Format=\"@\"/>");
            header.AppendLine("</Style>");
            header.AppendLine("</Styles>");
            header.AppendLine("<Worksheet ss:Name=\"Sheet1\">");
            header.AppendLine("<Table  ss:ExpandedColumnCount=\"{columns}\" ss:ExpandedRowCount=\"{rows}\" x:FullColumns=\"1\" x:FullRows=\"1\" ss:DefaultRowHeight=\"15\">");

            var footer = new StringBuilder("");
            footer.AppendLine("</Table>");
            footer.AppendLine("<WorksheetOptions xmlns=\"urn:schemas-microsoft-com:office:excel\">");
            footer.AppendLine("<PageSetup>");
            footer.AppendLine("<Header x:Margin=\"0.3\"/>");
            footer.AppendLine("<Footer x:Margin=\"0.3\"/>");
            footer.AppendLine("<PageMargins x:Bottom=\"0.75\" x:Left=\"0.7\" x:Right=\"0.7\" x:Top=\"0.75\"/>");
            footer.AppendLine("</PageSetup>");
            footer.AppendLine("<Print>");
            footer.AppendLine("<ValidPrinterInfo/>");
            footer.AppendLine("<HorizontalResolution>300</HorizontalResolution>");
            footer.AppendLine("<VerticalResolution>300</VerticalResolution>");
            footer.AppendLine("</Print>");
            footer.AppendLine("<Selected/>");
            footer.AppendLine("<Panes>");
            footer.AppendLine("<Pane>");
            footer.AppendLine("<Number>3</Number>");
            footer.AppendLine("<ActiveRow>1</ActiveRow>");
            footer.AppendLine("</Pane>");
            footer.AppendLine("</Panes>");
            footer.AppendLine("<ProtectObjects>False</ProtectObjects>");
            footer.AppendLine("<ProtectScenarios>False</ProtectScenarios>");
            footer.AppendLine("</WorksheetOptions>");
            footer.AppendLine("</Worksheet>");
            footer.AppendLine("</Workbook>");

            const string dataTemplate = "<Cell ss:StyleID=\"s16\"><Data ss:Type=\"String\">{data}</Data></Cell>";

            var body = new StringBuilder("");

            var columnCount = dt.Columns.Count;
            body.AppendLine("<Row>");
            for (var i = 0; i < columnCount; i++)
            {
                body.AppendLine(dataTemplate.Replace("{data}", dt.Columns[i].ColumnName));
            }
            body.AppendLine("</Row>");

            foreach (DataRow dr in dt.Rows)
            {
                body.AppendLine("<Row>");
                for (var i = 0; i < columnCount; i++)
                {
                    body.AppendLine(dataTemplate.Replace("{data}", dr[i].ToString()));
                }
                body.AppendLine("</Row>");
            }

            header.AppendLine(body.ToString());
            header.AppendLine(footer.ToString());

            return header.ToString().Replace("{rows}", (dt.Rows.Count + 1).ToString()).Replace("{columns}",
                                                                                         dt.Columns.Count.ToString());
        }

        public static string ReadWebConfig(string key)
        {
            return ReadWebConfig(key, "");
        }

        public static string ReadWebConfig(string key, string defValue)
        {
            return ConfigurationManager.AppSettings[key] ?? defValue;
        }

        public static string PutYellowBackGround(string mes)
        {
            return "<span style = \"background-color : yellow\">" + mes + "</span>";
        }

        public static string PutRedBackGround(string mes)
        {
            return "<span style = \"background-color : red\">" + mes + "</span>";
        }

        public static string PutBlueBackGround(string mes)
        {
            return "<span style = \"background-color : blue\">" + mes + "</span>";
        }

        public static string PutHalfYellowBackGround(string mes)
        {
            return "<span style = \"background-color : #FFA822\">" + mes + "</span>";
        }

        public static long ReadNumericDataFromQueryString(string key)
        {
            var tmpId = ReadQueryString(key, "0");
            long tmpIdLong;
            long.TryParse(tmpId, out tmpIdLong);
            return tmpIdLong;
        }

        public static decimal ReadDecimalDataFromQueryString(string key)
        {
            var tmpId = ReadQueryString(key, "0");
            decimal tmpIdDecimal;
            decimal.TryParse(tmpId, out tmpIdDecimal);
            return tmpIdDecimal;
        }

        public static void SetActiveMenu(string menuFunctionId)
        {
            HttpContext.Current.Session["activeMenu"] = menuFunctionId;
        }

        public static void ResizeFrame(Page page)
        {
            // CallBackJs1(page, "Resize Iframe", "window.parent.resizeIframe();");
        }

        /// <summary>
        /// Set DbResult in Session
        /// </summary>
        public static void SetMessage(DbResult value)
        {
            HttpContext.Current.Session["message"] = value;
        }

        /// <summary>
        /// Set Error Code and Message in Session
        /// </summary>
        /// <param name="errorCode">Error Code</param>
        /// <param name="msg">Message</param>
        public static void SetMessage(string errorCode, string msg)
        {
            var dbResult = new DbResult { ErrorCode = errorCode, Msg = msg };
            SetMessage(dbResult);
        }

        /// <summary>
        /// Jquery Print Message from session
        /// </summary>
        public static void PrintMessage(Page page)
        {
            if (HttpContext.Current.Session["message"] == null)
            {
                //CallBackJs1(page, "Remove Message", "window.parent.RemoveMessageBox();");
                return;
            }

            var dbResult = GetMessage();
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + dbResult.Msg + "\",\"" + dbResult.ErrorCode + "\");");
            HttpContext.Current.Session.Remove("message");
        }

        /// <summary>
        /// Jquery Print Message from session
        /// </summary>
        public static void PrintMessageAPI(Page page, JsonResponse apiResponse)
        {
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + apiResponse.Msg + "\",\"" + apiResponse.ResponseCode + "\");");
            HttpContext.Current.Session.Remove("message");
        }

        /// <summary>
        /// Jquery Print Message from DbResult
        /// </summary>
        public static void PrintMessage(Page page, DbResult dbResult)
        {
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + dbResult.Msg + "\",\"" + dbResult.ErrorCode + "\");");
        }

        /// <summary>
        /// Jquery Print Message directly passing Error Code and Message
        /// </summary>
        public static void PrintMessage(Page page, string errorCode, string msg)
        {
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + msg + "\",\"" + errorCode + "\");");
        }

        public static void PrintSuccessMessage(Page page, string msg)
        {
            PrintMessage(page, "0", msg);
        }

        public static void PrintErrorMessage(Page page, string msg)
        {
            PrintMessage(page, "1", msg);
        }

        /// <summary>
        /// Alert Message from session
        /// </summary>
        public static void AlertMessage(Page page)
        {
            if (HttpContext.Current.Session["message"] == null)
                return;
            var dbResult = GetMessage();
            if (dbResult.Msg == "")
                return;
            CallBackJs1(page, "Alert Message", "alert(\"" + FilterMessageForJs(dbResult.Msg) + "\");");
            HttpContext.Current.Session.Remove("message");
        }

        /// <summary>
        /// Alert Message directly passing Message
        /// </summary>
        public static void AlertMessage(Page page, string msg)
        {
            CallBackJs1(page, "Alert Message", "alert(\"" + FilterMessageForJs(msg) + "\");");
        }

        public static void ShowSuccessMessage(string msg)
        {
            HttpContext.Current.Server.Transfer(GetVirtualDirName() + "/PrintMessage.aspx?errorCode=0&msg=" + msg);
        }

        public static void ShowErrorMessage(string msg)
        {
            HttpContext.Current.Server.Transfer(GetVirtualDirName() + "/PrintMessage.aspx?errorCode=1&msg=" + msg);
        }

        public static string GetActiveMenu()
        {
            return ReadSession("activeMenu", "");
        }

        public static string GetBoolToChar(bool chk)
        {
            return chk ? "Y" : "N";
        }

        public static bool GetCharToBool(string value)
        {
            return value.ToUpper() == "Y" ? true : false;
        }

        public static DbResult GetMessage()
        {
            return (DbResult)HttpContext.Current.Session["message"];
        }

        public static void Redirect(Page page, string url)
        {
            page.ClientScript.RegisterStartupScript(typeof(string), "script", "<script language = 'javascript'>Redirect('" + url + "');</script>");
        }

        public static void CloseDialog(Page page, string returnValue)
        {
            page.ClientScript.RegisterStartupScript(typeof(string), "scriptClose", "<script language = 'javascript'>CloseDialog('" + returnValue + "');</script>");
        }

        public static bool VerifyMode()
        {
            return ReadQueryString("mode", "") == "verify" ? true : false;
        }

        public static string GetVoucherName(string vType)
        {
            switch (vType.ToLower())
            {
                case "j":
                    return "Journal Voucher";

                case "c":
                    return "Contra Voucher";

                case "y":
                    return "Payment Voucher";

                case "r":
                    return "Receipt Voucher";

                case "s":
                    return "Remittance Voucher";

                default:
                    return "";
            }
        }

        public static String ShowWithoutDecimal(String strVal)
        {
            if (strVal != "")
                return String.Format("{0:0,0}", double.Parse(strVal));
            else
                return strVal;
        }

        public static String ShowDecimal(String strVal)
        {
            if (strVal != "")
                return String.Format("{0:0,0.00}", double.Parse(strVal));
            else
                return strVal;
        }

        public static String ShowDecimalRate(String strVal)
        {
            if (strVal != "")
                return String.Format("{0:0,0.0000}", double.Parse(strVal));
            else
                return strVal;
        }

        public static String ShowAbsDecimal(String strVal)
        {
            if (strVal != "")
            {
                strVal = Math.Abs(ParseDouble(strVal)).ToString();
                return String.Format("{0:0,0.00}", double.Parse(strVal));
            }
            else
                return strVal;
        }

        public static string GetNegativeFigureOnBrac(string Amount)
        {
            var FIndex = Amount[0].ToString();
            if (FIndex.Equals("-"))
            {
                return "(" + ShowDecimal(Amount.Substring(1).ToString()) + ")";
            }
            else
                return ShowDecimal(Amount);
        }

        public static string ShowDecimal_Account(string Amount)
        {
            var FIndex = Amount[0].ToString();
            if (FIndex.Equals("-"))
            {
                return ShowAbsDecimal(Amount);
            }
            else
                return "(" + ShowDecimal(Amount.ToString()) + ")";
        }

        public static string GetRowData(DataRow dr, string fieldName, string defValue)
        {
            return dr == null ? defValue : dr[fieldName].ToString();
        }

        public static string GetRowData(DataRow dr, string fieldName)
        {
            return GetRowData(dr, fieldName, "");
        }

        public static string GetRowDataInShortDateFormat(DataRow dr, string fieldName)
        {
            return dr[fieldName].ToString() == "" ? "" : Convert.ToDateTime(dr[fieldName].ToString()).ToShortDateString();
        }

        public static string ParseResultJsPrint(DbResult dbResult)
        {
            return dbResult.ErrorCode + "-:::-" + dbResult.Msg.Replace("'", "").Replace("<br/>", "").Replace(System.Environment.NewLine, "") + "-:::-" + dbResult.Id;
        }

        public static void CallBackJs1(Page page, String scriptName, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), scriptName, functionName, true);
        }

        public static void CallJSFunction(Page page, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), "cb", functionName, true);
        }

        public static void CallBackJs2(Page page, string scriptName, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), scriptName, functionName, true);
        }

        public static double ParseDouble(string value)
        {
            double tmp;
            double.TryParse(value, out tmp);
            return tmp;
        }

        public static int ParseInt(string value)
        {
            int tmp;
            int.TryParse(value, out tmp);
            return tmp;
        }

        public static string DataTableToCheckBox(DataTable dt, string name, string valueField, string textField)
        {
            var sb = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine("<input type = \"checkbox\" name = \"" + name + "\" value = \"" + row[valueField] +
                              "\" "+ row["isChecked"] + " />" + row[textField] + " <br />");
            }

            return sb.ToString();
        }

        public static string ParseMinusValue(double data)
        {
            var retVal = Math.Abs(data).ToString("N");
            if (data < 0)
            {
                return "(" + retVal + ")";
            }
            return retVal;
        }

        public static string ParseMinusValue(string data)
        {
            var m = ParseDouble(data);

            return ParseMinusValue(m);
        }

        public static DataTable GetHistoryChangedListForIdCriteria(string oldData, string newData, string id)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForIdCriteria(oldData, newData, id);
        }

        public static DataTable GetHistoryChangedListForCommissionPackage(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            if (string.IsNullOrEmpty(oldData))
                oldData = newData;
            if (string.IsNullOrEmpty(newData))
                newData = oldData;
            return applicationLogsDao.GetAuditDataForCommissionPackage(oldData, newData);
        }

        public static FullName ParseName(string fullName)
        {
            var fn = new FullName();
            var name = fullName.Split(' ');
            var names = name.Length;
            fn.FirstName = name[0];
            fn.MiddleName = "";
            fn.LastName1 = "";
            fn.LastName2 = "";
            if (names > 1)
            {
                fn.LastName1 = name[1];
                if (names > 2)
                {
                    fn.MiddleName = name[1];
                    fn.LastName1 = name[2];
                    if (names > 3)
                        fn.LastName2 = name[3];
                    if (names > 4)
                        fn.LastName2 += " " + name[4];
                }
            }
            return fn;
        }

        //DateTime dt = GetStatic.GMTDatetime();
        public static DateTime GMTDatetime()
        {
            System.DateTime CurrTime = System.DateTime.Now;
            System.DateTime CurrUTCTime = CurrTime.ToUniversalTime();
            var dt1 = CurrUTCTime.AddMinutes(345);
            return dt1;
        }

        public static String FilterMessageForJs(string strVal)
        {
            if (strVal.ToLower() != "null")
            {
                strVal = strVal.Replace("\"", "");
            }

            return strVal;
        }

        public static void ReloadJQueryDatePicket(Page p, string textBoxName)
        {
            CallBackJs1(p, "ajax", "AsyncDone('#" + textBoxName + "');");
            //This script handles ajax postbacks, by registering the js to run at the end of *AJAX* requests
            //p.ClientScript.RegisterStartupScript(typeof(Page), "ajaxTrigger", "Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);", true);
            //p.ClientScript.RegisterClientScriptBlock(typeof(Page), "EndRequest", "function EndRequestHandler(sender, args){" + callBack + ";}", true);
        }

        public static String GetPopupHelpmsg()
        {
            var sb = new StringBuilder("<!-- Start to use Help Float-->");
            sb.AppendLine("<div id=\"dek\" onmouseout=\"kill()\"></div>");
            sb.AppendLine("<style type=\"text/css\">");
            sb.AppendLine("<!-- #dek {position:absolute;visibility:hidden;z-index:10;} //-->  </style>");
            sb.AppendLine("<script type=\"text/javascript\" language=\"javascript\">");
            sb.AppendLine("Xoffset = -60;");
            sb.AppendLine("Yoffset = 20;  ");
            sb.AppendLine("var old, skn, iex = (document.all), yyy = -1000;");
            sb.AppendLine("var ns4 = document.layers");
            sb.AppendLine("var ns6 = document.getElementById && !document.all");
            sb.AppendLine("var ie4 = document.all");
            sb.AppendLine("if (ns4) skn = document.dek");
            sb.AppendLine("else if (ns6) skn = document.getElementById(\"dek\").style");
            sb.AppendLine("else if (ie4) skn = document.all.dek.style");
            sb.AppendLine("if (ns4) document.captureEvents(Event.MOUSEMOVE);");
            sb.AppendLine("else {");
            sb.AppendLine("skn.visibility = \"visible\"; skn.display = \"none\"; }");
            sb.AppendLine("document.onmousemove = get_mouse;");
            //popup
            sb.AppendLine("function popup(msg, bak, control) {");
            sb.AppendLine("var pos = FindPos(GetElement(control));");
            sb.AppendLine("var left = pos[0] + 200;");
            sb.AppendLine("var top = pos[1];");
            sb.AppendLine("document.getElementById(\"dek\").style.left = left + \"px\";");
            sb.AppendLine("document.getElementById(\"dek\").style.top = top + \"px\";");
            sb.AppendLine("var content = \"<TABLE  WIDTH=250 BORDER=1 BORDERCOLOR=black CELLPADDING=2 CELLSPACING=0 BGCOLOR=\" + bak + \"><TD ALIGN=center><FONT COLOR=black SIZE=2>\" + msg + \"</FONT></TD></TABLE>\";");
            sb.AppendLine("yyy = Yoffset;");
            sb.AppendLine("if (ns4) { skn.document.write(content); skn.document.close(); skn.visibility = \"visible\" }");
            sb.AppendLine("if (ns6) { document.getElementById(\"dek\").innerHTML = content; skn.display = '' }");
            sb.AppendLine("if (ie4) { document.all(\"dek\").innerHTML = content; skn.display = '' }");
            sb.AppendLine("}");

            //function kill() {
            sb.AppendLine("function kill() {");
            sb.AppendLine("yyy = -1000;");
            sb.AppendLine("if (ns4) { skn.visibility = \"hidden\"; }");
            sb.AppendLine("else if (ns6 || ie4) skn.display = \"none\"");
            sb.AppendLine("}</script>");

            return sb.ToString();
        }

        public static string ToRomanNumeral(this int value)
        {
            if (value < 0)
            {
                // throw new ArgumentOutOfRangeException("Please use a positive integer greater than zero.");
                return "";
            }
            StringBuilder sb = new StringBuilder();
            int remain = value;
            while (remain > 0)
            {
                if (remain >= 1000) { sb.Append("M"); remain -= 1000; }
                else if (remain >= 900) { sb.Append("CM"); remain -= 900; }
                else if (remain >= 500) { sb.Append("D"); remain -= 500; }
                else if (remain >= 400) { sb.Append("CD"); remain -= 400; }
                else if (remain >= 100) { sb.Append("C"); remain -= 100; }
                else if (remain >= 90) { sb.Append("XC"); remain -= 90; }
                else if (remain >= 50) { sb.Append("L"); remain -= 50; }
                else if (remain >= 40) { sb.Append("XL"); remain -= 40; }
                else if (remain >= 10) { sb.Append("X"); remain -= 10; }
                else if (remain >= 9) { sb.Append("IX"); remain -= 9; }
                else if (remain >= 5) { sb.Append("V"); remain -= 5; }
                else if (remain >= 4) { sb.Append("IV"); remain -= 4; }
                else if (remain >= 1) { sb.Append("I"); remain -= 1; }
                else
                {
                    //throw new Exception("Unexpected error."); // <<-- shouldn't be possble to get here, but it ensures that we will never have an infinite loop (in case the computer is on crack that day).
                }
            }

            return sb.ToString();
        }

        public static string getCompanyHead()
        {
            var headerSplit = ReadWebConfig("companyName", "").Split('|');
            string header = "<strong>" + headerSplit[0].ToString() + "</strong>";
            header += "<br>" + headerSplit[1].ToString();
            return header;
        }

        public static string IntToLetter(this int value)
        {
            string result = string.Empty;
            while (--value >= 0)
            {
                result = (char)('a' + value % 26) + result;
                value /= 26;
            }
            return result + ".";
        }

        public static string GetVoucherType(string vType, string def)
        {
            string vt = "";
            if (vType.ToLower() == "s")
            {
                vt = "Sales";
            }
            else if (vType.ToLower() == "p")
            {
                vt = "Purchase";
            }
            else if (vType.ToLower() == "c")
            {
                vt = "Contra";
            }
            else if (vType.ToLower() == "y")
            {
                vt = "Payment";
            }
            else if (vType.ToLower() == "r")
            {
                vt = "Receipt";
            }
            else if (vType.ToLower() == "j")
            {
                vt = "Journal";
            }
            else
            {
                vt = def;
            }

            return vt;
        }

        /// <summary>
        /// </summary>
        /// <param name="page"></param>
        /// <param name="controlNo"></param>
        /// <param name="message"></param>
        /// <param name="successMessageType">1 - Jquery Message, 2 - Js Alert Message</param>

        #region for Remittance use only

        public static string GetDomesticSuperAgentId()
        {
            return ReadWebConfig("domesticSuperAgentId");
        }

        public static string GetHoAgentId()
        {
            return ReadWebConfig("hoAgentId");
        }

        #endregion for Remittance use only

        public static string GetDomesticCountryId()
        {
            return ReadWebConfig("domesticCountryId");
        }

        public static string GetCountryId()
        {
            return ReadSession("countryId", "");
        }

        public static string GetDefaultPage()
        {
            switch (ReadCookie("loginType", "").ToUpper())
            {
                case "ADMIN":
                    return GetUrlRoot() + "/admin";

                case "AGENT":
                    return GetUrlRoot() + "/agentlogin";
            }

            return GetUrlRoot();
        }

        internal static string GetDefaultDocPath()
        {
            switch (ReadCookie("loginType", "").ToUpper())
            {
                case "ADMIN":
                    return GetUrlRoot() + "/admin";

                case "AGENT":
                    return GetUrlRoot() + "/agentlogin";
            }

            return GetUrlRoot();
        }

        public static string GetDefaultDocPathMortgage()
        {
            return ReadWebConfig("defaultDocPath");
        }

        public static string GetSendEmailId()
        {
            return ReadWebConfig("SendEmailId");
        }

        public static string GetSendEmailPwd()
        {
            return ReadWebConfig("SendEmailPwd");
        }

        public static string GetSmtpPort()
        {
            return ReadWebConfig("SmtpPort");
        }

        public static string GetSmtpServer()
        {
            return ReadWebConfig("SmtpServer");
        }

        public static void JsonResponse<T>(T obk, Page page)
        {
            System.Web.Script.Serialization.JavaScriptSerializer jsonData = new System.Web.Script.Serialization.JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            page.Response.ContentType = "application/json";
            page.Response.Write(jsonString);
            page.Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }

        public static void DataTableToJson(DataTable table, Page page)
        {
            if (null == table)
            {
                page.Response.ContentType = "application/json";
                page.Response.Write("");
                page.Response.End();
            }
            else
            {
                var list = new List<Dictionary<string, object>>();

                foreach (DataRow row in table.Rows)
                {
                    var dict = new Dictionary<string, object>();

                    foreach (DataColumn col in table.Columns)
                    {
                        dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                    }
                    list.Add(dict);
                }
                var serializer = new JavaScriptSerializer();
                string json = serializer.Serialize(list);

                page.Response.ContentType = "application/json";
                page.Response.Write(json);
                page.Response.End();
            }
        }

        public static string ObjectToXML(object input)
        {
            try
            {
                StringWriter stringwriter = new StringWriter();
                XmlSerializer serializer = new XmlSerializer(input.GetType());
                serializer.Serialize(stringwriter, input);
                return stringwriter.ToString();
            }
            catch (Exception ex)
            {
                if (ex.InnerException != null)
                    ex = ex.InnerException;

                return "Could not convert: " + ex.Message;
            }
        }

        public static string MakeAutoCompleteControl(string uniqueKey, string category, string selectedValue = "", string selectedText = "")
        {
            var url = GetStatic.GetUrlRoot() + "/Component/AutoComplete/DataSource.asmx/GetList";

            var usr = GetStatic.GetUser();
            var sb = new StringBuilder();
            //var strClientID = rowId + "_" + f.Key;
            var ctlValue = uniqueKey + "_aValue";
            var ctlText = uniqueKey + "_aText";
            var ctlSearch = uniqueKey + "_aSearch";

            //grdRole_gl_code_aText_c_admin////grdRole_gl_code_aSearch
            sb.Append("<input type = 'hidden' id = '" + ctlValue + "' name = '" + ctlValue + "' value='" + selectedValue + "'/>");
            sb.Append("<input type = 'text' id = '" + ctlText + "' name = '" + ctlText + "' class='form-control' value='" + selectedText + "' />");
            sb.Append("<input style = 'background-color:#BBF;display:none' type = 'text' id = '" + ctlSearch + "' name = '" + ctlSearch + "' class='form-control' />");
            sb.Append("<script language = 'javascript' type ='text/javascript'>");
            sb.Append("$(document).ready(function () {");
            sb.Append("function Auto_" + uniqueKey + "() {");
            sb.Append(InitFunction(category, url, uniqueKey, "150px"));
            sb.Append("} Auto_" + uniqueKey + "();");
            sb.Append("});");
            sb.Append("</script>");

            return sb.ToString();
        }

        public static string MakeAutoCompleteControlNew(string uniqueKey, string category, string selectedValue = "", string selectedText = "")
        {
            var url = GetStatic.GetUrlRoot() + "/Component/AutoComplete/DataSource.asmx/GetList";

            var usr = GetStatic.GetUser();
            var sb = new StringBuilder();
            //var strClientID = rowId + "_" + f.Key;
            var ctlValue = uniqueKey + "_aValue";
            var ctlText = uniqueKey + "_aText";
            var ctlSearch = uniqueKey + "_aSearch";

            //grdRole_gl_code_aText_c_admin////grdRole_gl_code_aSearch
            sb.Append("<input type = 'hidden' id = '" + ctlValue + "' name = '" + ctlValue + "' value='" + selectedValue + "'/>");
            sb.Append("<input type = 'text' disabled id = '" + ctlText + "' name = '" + ctlText + "' class='form-control' value='" + selectedText + "' />");
            sb.Append("<input style = 'background-color:#BBF;display:none' type = 'text' id = '" + ctlSearch + "' name = '" + ctlSearch + "' class='form-control' />");
            sb.Append("<script language = 'javascript' type ='text/javascript'>");
            sb.Append("$(document).ready(function () {");
            sb.Append("function Auto_" + uniqueKey + "() {");
            sb.Append(InitFunction(category, url, uniqueKey, "150px"));
            sb.Append("} Auto_" + uniqueKey + "();");
            sb.Append("});");
            sb.Append("</script>");

            return sb.ToString();
        }

        public static Location GetLocation(string ipAddress)
        {
            if (ReadWebConfig("UseLocationAPI", "") == "N")
            {
                return new Location
                {
                    errorCode = "1",
                    errorMsg = "Called from DEV, so no API Called!"
                };
            }
            string apiKey = GetStatic.ReadWebConfig("GeoLocationIpInfoKey");
            string url = string.Format("http://api.ipinfodb.com/v3/ip-city/?key={0}&ip={1}", apiKey, ipAddress);

            JavaScriptSerializer serializer = new JavaScriptSerializer();

            try
            {
                var HttpWReq = (HttpWebRequest)WebRequest.Create(url);
                HttpWReq.Method = "GET";
                var HttpWResp = (HttpWebResponse)HttpWReq.GetResponse();

                System.IO.StreamReader reader = new System.IO.StreamReader(HttpWResp.GetResponseStream());
                string content = reader.ReadToEnd();

                var _arrLoc = content.Split(';');

                if (_arrLoc[0].ToUpper() == "OK")
                {
                    Location _loc = new Location
                    {
                        errorCode = "0",
                        IpAddress = _arrLoc[2],
                        CountryCode = _arrLoc[3],
                        CountryName = _arrLoc[4],
                        Region = _arrLoc[5],
                        City = _arrLoc[6],
                        ZipCode = _arrLoc[7],
                        Lat = _arrLoc[8],
                        Long = _arrLoc[9],
                        TimeZone = _arrLoc[10]
                    };

                    return _loc;
                }
                else
                {
                    Location _loc = new Location
                    {
                        errorCode = "1",
                        errorMsg = _arrLoc[0] + " : " + _arrLoc[1]
                    };
                    return _loc;
                }
            }
            catch (Exception ex)
            {
                return new Location
                {
                    errorCode = "1",
                    errorMsg = ex.Message
                };
            }
        }

        public static string GetSMSTextForTxn(DataRow sRow)
        {
            FullName _fullNameS = GetStatic.ParseName(sRow["senderName"].ToString());
            FullName _fullNameR = GetStatic.ParseName(sRow["receiverName"].ToString());

            string sms = "";
            if (sRow["paymentMethod"].ToString().ToLower() == "bank deposit")
            {
                FullName _bankName = GetStatic.ParseName(sRow["pBankName"].ToString());

                sms += "Dear Mr/Ms " + _fullNameS.FirstName + ", your money sent to account of Mr/Ms " + _fullNameR.FirstName + " in ";
                sms += _bankName.FirstName + "... Bank. Amt sent: JPY " + GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString());
                sms += ", Deposit Amt " + sRow["payoutCurr"].ToString() + " " + GetStatic.ShowWithoutDecimal(sRow["pAmt"].ToString()) + ". Thank you-"+ GetStatic.ReadWebConfig("jmeName", "") + ".";
            }
            else
            {
                sms += "Dear Mr/Ms " + _fullNameS.FirstName + ", your money sent to Mr/Ms " + _fullNameR.FirstName + ". Amt sent: JPY ";
                sms += GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + ", Payout Amt " + sRow["payoutCurr"].ToString() + " " + GetStatic.ShowWithoutDecimal(sRow["pAmt"].ToString()) + ". PIN NO: " + sRow["controlNo"].ToString() + ". Thank you-"+ GetStatic.ReadWebConfig("jmeName", "") + ".";
            }

            return sms;
        }

        public static string SendEmail(string msgSubject, string msgBody, string toEmailId)
        {
            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };
            return mail.SendSmtpMail(mail);
        }

        private static string InitFunction(string filter, string url, string rowId, string width)
        {
            var sb = new StringBuilder();
            sb.Append("LoadAutoCompleteTextBox(");
            sb.Append(@"""" + url + @"""");
            sb.Append(@",""#" + rowId + @"""");
            sb.Append(@",""" + width + @"""");
            sb.Append(@",""" + filter + @""");");
            return sb.ToString();
        }
    }
}