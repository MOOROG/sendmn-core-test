using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Text;
using System.Web;
using System.Collections;

namespace Swift.DAL.SwiftDAL
{
    public class SwiftDao
    {
        private SqlConnection _connection;
        private int connectionCode = 0;

        public SwiftDao()
        {
            Init();
        }

        private void Init()
        {
            _connection = new SqlConnection(GetConnectionString());
        }

        private void OpenConnection()
        {
            if (_connection.State == ConnectionState.Open)
                _connection.Close();

            try
            {
                _connection.Open();
            }
            catch (Exception)
            {
                //DbResult conError = new DbResult();
                //conError.SetError("999999", "Connection to db Fails.", null);
                connectionCode = 9999;
            }
            // _connection.Open();
        }

        private void CloseConnection()
        {
            if (_connection.State == ConnectionState.Open)
                this._connection.Close();
        }

        private string GetConnectionString()
        {
            return ConfigurationSettings.AppSettings["connectionString"].ToString();
        }

        public DataSet ExecuteDataset(string sql)
        {
            var ds = new DataSet();
            SqlDataAdapter da;

            OpenConnection();
            if (connectionCode.Equals(9999))
            {
                DataSet dss = new DataSet();
                DataTable dt = new DataTable();
                dt.Columns.Add("ErrorCode");
                dt.Columns.Add("Msg");
                dt.Columns.Add("Id");

                DataRow msg = dt.NewRow();
                msg["ErrorCode"] = "9999";
                msg["Msg"] = "Could not connect to db.";
                msg["Id"] = null;
                dt.Rows.Add(msg);
                ds.Tables.Add(dt);
                return ds;
            }

            try
            {
                da = new SqlDataAdapter(sql, _connection);
                da.SelectCommand.CommandTimeout = 230;

                da.Fill(ds);
                da.Dispose();
                CloseConnection();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                da = null;
                CloseConnection();
            }
            return ds;
        }

        public DataTable ExecuteDataTable(string sql)
        {
            using (var ds = ExecuteDataset(sql))
            {
                if (ds == null || ds.Tables.Count == 0)
                    return null;

                return ds.Tables[0];
            }
        }

        public DataRow ExecuteDataRow(string sql)
        {
            using (var ds = ExecuteDataset(sql))
            {
                if (ds == null || ds.Tables.Count == 0)
                    return null;

                if (ds.Tables[0].Rows.Count == 0)
                    return null;

                return ds.Tables[0].Rows[0];
            }
        }

        public String GetSingleResult(string sql)
        {
            try
            {
                var ds = ExecuteDataset(sql);
                if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                    return "";

                return ds.Tables[0].Rows[0][0].ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                CloseConnection();
            }
        }

        public String FilterStringForXml(string strVal)
        {
            var str = FilterQuote(strVal);

            if (str.ToLower() == "null")
                str = "";

            //str = "'" + str + "'";

            return str;
        }

        public String FilterString(string strVal)
        {
            var str = FilterQuote(strVal);

            if (str.ToLower() != "null")
                str = "'" + str + "'";

            return str;
        }

        public string SingleQuoteToDoubleQuote(string strVal)
        {
            strVal = strVal.Replace("\"", "");
            return strVal.Replace("'", "\"");
        }

        public String FilterQuote(string strVal)
        {
            if (string.IsNullOrEmpty(strVal))
            {
                strVal = "";
            }
            var str = strVal/*.Trim()*/;

            if (!string.IsNullOrEmpty(str))
            {
                str = str.Replace(";", "");
                //str = str.Replace(",", "");
                str = str.Replace("--", "");
                str = str.Replace("'", "");

                str = str.Replace("/*", "");
                str = str.Replace("*/", "");

                str = str.Replace(" select ", "");
                str = str.Replace(" insert ", "");
                str = str.Replace(" update ", "");
                str = str.Replace(" delete ", "");

                str = str.Replace(" drop ", "");
                str = str.Replace(" truncate ", "");
                str = str.Replace(" create ", "");

                str = str.Replace(" begin ", "");
                str = str.Replace(" end ", "");
                str = str.Replace(" char(", "");

                str = str.Replace(" exec ", "");
                str = str.Replace(" xp_cmd ", "");

                str = str.Replace("<script", "");

                str = str.Replace("<", "");
                str = str.Replace(">", "");
            }
            else
            {
                str = "null";
            }
            return str;
        }

        public DbResult ParseDbResult(DataTable dt)
        {
            var res = new DbResult();
            if (dt.Rows.Count > 0)
            {
                res.ErrorCode = dt.Rows[0][0].ToString();
                res.Msg = dt.Rows[0][1].ToString();
                res.Id = dt.Rows[0][2].ToString();
            }
            return res;
        }

        public DbResult ParseDbResult(string sql)
        {
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public UserDetails ParseLoginResult(DataTable dt)
        {
            var res = new UserDetails();

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                res.ErrorCode = (row["ErrorCode"] ?? "").ToString();
                res.Msg = (row["msg"] ?? "").ToString();

                if (dt.Columns.Count > 3)
                {
                    res.UserId = (row["UserId"] ?? "").ToString();
                    res.FullName = (row["fullName"] ?? "").ToString();
                    res.Address = (row["address"] ?? "").ToString();
                    res.LastLoginTs = (row["LastLoginTs"] ?? "").ToString();
                    res.UserAccessLevel = (row["accessMode"] ?? "").ToString();
                    res.Branch = (row["branchId"] ?? "").ToString();
                    res.BranchName = (row["BRANCH_NAME"] ?? "").ToString();
                    res.UserType = (row["UserType"] ?? "").ToString();
                    res.isForcePwdChanged = (row["isForcePwdChanged"] ?? "").ToString();
                }
            }
            return res;
        }

        #region ParseReportResult

        public ReportResult ParseReportResult(DataSet ds, string sql)
        {
            var res = new ReportResult();

            res.Sql = sql;
            res.Result = ds;

            if (ds == null || ds.Tables.Count == 0)
                return res;

            var tableCount = ds.Tables.Count;

            if (tableCount > 3)
            {
                res.ReportHead = ds.Tables[tableCount - 1].Rows[0][0].ToString();
            }

            if (tableCount > 2)
            {
                var html = new StringBuilder("");
                var hasFilters = false;
                foreach (DataRow dr in ds.Tables[tableCount - 2].Rows)
                {
                    html.Append(" | " + dr[0] + "=" + dr[1]);
                    hasFilters = true;
                }

                res.Filters = hasFilters ? html.ToString().Substring(2) : "";
            }

            if (tableCount > 1)
            {
                var pos = tableCount - 3;
                if (pos < 1)
                    pos = 1;

                var dbresult = ParseDbResult(ds.Tables[pos]);
                res.ErrorCode = dbresult.ErrorCode;
                res.Msg = dbresult.Msg;
                res.Id = dbresult.Id;
                res.ResultSet = ds.Tables[0];
            }

            return res;
        }

        public ReportResult ParseReportResult(string sql)
        {
            var ds = ExecuteDataset(sql);
            return ParseReportResult(ds, sql);
        }

        public ReportResult ParseReportResult(DataSet ds)
        {
            return ParseReportResult(ds, "");
        }

        #endregion ParseReportResult

        public DataTable GetTable2(string sql)
        {
            return ExecuteDataset(sql).Tables[1];
        }

        protected string ParseData(string data)
        {
            return data.Replace("\"", "").Replace("'", "").Trim();
        }

        public string AutoSelect(string str1, string str2)
        {
            if (str1.ToLower() == str2.ToLower())
                return "selected=\"selected\"";

            return "";
        }

        protected string ParseDate(string data)
        {
            data = FilterString(data);
            if (data.ToUpper() == "NULL")
                return data;
            data = data.Replace("'", "");
            var dateParts = data.Split('/');
            if (dateParts.Length < 3)
                return "NULL";
            var m = dateParts[0];
            var d = dateParts[1];
            var y = dateParts[2];

            return "'" + y + "-" + (m.Length == 1 ? "0" + m : m) + "-" + (d.Length == 1 ? "0" + d : d) + "'";
        }

        public DataTable GetTable(string sql)
        {
            var ds = new DataSet();
            SqlDataAdapter da;

            try
            {
                OpenConnection();
                da = new SqlDataAdapter(sql, _connection);

                da.Fill(ds);
                da.Dispose();
                CloseConnection();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                da = null;
                CloseConnection();
            }
            return ds.Tables[0];
        }

        public void ExecuteProcedure(string spName, SqlParameter[] param)
        {
            try
            {
                OpenConnection();
                SqlCommand command = new SqlCommand(spName, _connection);
                command.CommandType = CommandType.StoredProcedure;

                foreach (SqlParameter p in param)
                {
                    command.Parameters.Add(p);
                }
                command.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                CloseConnection();
            }
        }

        public string DataTableToText(ref DataTable dt, string delemeter, Boolean includeColHeader)
        {
            var sb = new StringBuilder();
            var del = "";
            var rowcnt = 0;
            if (includeColHeader)
            {
                foreach (DataColumn col in dt.Columns)
                {
                    sb.Append(del);
                    sb.Append(col.ColumnName);
                    del = delemeter;
                }
                rowcnt++;
            }

            foreach (DataRow row in dt.Rows)
            {
                if (rowcnt > 0)
                {
                    sb.AppendLine();
                }
                del = "";
                foreach (DataColumn col in dt.Columns)
                {
                    sb.Append(del);
                    sb.Append(row[col.ColumnName].ToString());
                    del = delemeter;
                }
                rowcnt++;
            }
            return sb.ToString();
        }

        public string DataTableToText(ref DataTable dt, string delemeter)
        {
            return DataTableToText(ref dt, delemeter, true);
        }

        public string DataTableToHTML(ref DataTable dt, Boolean includeColHeader)
        {
            var sb = new StringBuilder("<table>");

            if (includeColHeader)
            {
                sb.AppendLine("<tr>");
                foreach (DataColumn col in dt.Columns)
                {
                    sb.Append("<th>" + col.ColumnName + "</th>");
                }
                sb.AppendLine("</tr>");
            }

            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine("<tr>");
                foreach (DataColumn col in dt.Columns)
                {
                    sb.Append("<td>" + row[col.ColumnName].ToString() + "</td>");
                }
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("</table>");
            return sb.ToString();
        }

        public string DataTableToHTML(ref DataTable dt)
        {
            return DataTableToHTML(ref dt, true);
        }

        public DbResult TryParseSQL(string sql)
        {
            var dr = new DbResult();
            try
            {
                OpenConnection();
                using (SqlCommand command = new SqlCommand())
                {
                    command.Connection = _connection;
                    command.CommandType = CommandType.Text;
                    command.CommandText = "SET NOEXEC ON " + sql + " SET NOEXEC OFF"; ;
                    command.ExecuteNonQuery();
                    dr.ErrorCode = "0";
                    dr.Msg = "Success";
                }
                return dr;
            }
            catch (Exception ex)
            {
                dr.ErrorCode = "1";
                dr.Msg = FilterQuote(ex.Message);
                return dr;
            }
            finally
            {
                CloseConnection();
            }
        }

        public DataTable DecodeLogData(DataTable logTable)
        {
            var data = GetDataTemplete(logTable);
            if (string.IsNullOrWhiteSpace(data))
            {
                return null;
            }

            var fieldList = new ArrayList();
            fieldList.Add("Table");
            fieldList.Add("ChangedDate");
            fieldList.Add("ChangedBy");
            fieldList.Add("ChangedType");
            fieldList.Add("DataID");

            var dt = CreateDataTableFromLogData(data, fieldList);

            foreach (DataRow row in logTable.Rows)
            {
                DataRow newRow = dt.NewRow();
                newRow["Table"] = row["tableName"].ToString();
                newRow["ChangedDate"] = row["createdDate"].ToString();
                newRow["ChangedBy"] = row["createdBy"].ToString();
                newRow["ChangedType"] = row["logType"].ToString();
                newRow["DataID"] = row["dataId"].ToString();

                CreateDataRowFromLogData(ref newRow, row["newData"].ToString());
                dt.Rows.Add(newRow);
            }

            return dt;
        }

        #region Helper

        private string GetDataTemplete(DataTable dt)
        {
            var data = "";
            foreach (DataRow row in dt.Rows)
            {
                data = row["OldData"].ToString();
                if (string.IsNullOrWhiteSpace(data))
                {
                    data = row["OldData"].ToString();
                }
                if (!string.IsNullOrWhiteSpace(data))
                {
                    return data;
                }
            }
            return data;
        }

        private DataTable CreateDataTableFromLogData(string data, ArrayList defaultFields)
        {
            var dt = new DataTable();

            foreach (var fld in defaultFields)
            {
                dt.Columns.Add(fld.ToString());
            }

            var stringSeparators = new[] { "-:::-" };
            var dataList = data.Split(stringSeparators, StringSplitOptions.None);
            const string seperator = "=";
            foreach (var itm in dataList)
            {
                var seperatorPos = itm.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    var field = itm.Substring(0, seperatorPos - 1).Trim();
                    dt.Columns.Add(field);
                }
            }
            return dt;
        }

        private void CreateDataRowFromLogData(ref DataRow row, string data)
        {
            var stringSeparators = new[] { "-:::-" };
            var dataList = data.Split(stringSeparators, StringSplitOptions.None);

            const string seperator = "=";
            foreach (var itm in dataList)
            {
                var seperatorPos = itm.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    var field = itm.Substring(0, seperatorPos - 1).Trim();
                    var value = itm.Substring(seperatorPos + 1).Trim();

                    row[field] = value;
                }
            }
        }

        #endregion Helper
    }
}