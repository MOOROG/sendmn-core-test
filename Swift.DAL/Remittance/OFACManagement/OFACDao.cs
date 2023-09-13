
using System.Data;
using Swift.DAL.SwiftDAL;
using System.IO;
using System.Text;
using System;

namespace Swift.DAL.BL.Remit.OFACManagement
{
    public class OFACDao : RemittanceDao
    {
        private string GetXml(string filePath)
        {
            var streamReader = new StreamReader(filePath);
            if (streamReader.EndOfStream)
                return "";

            var contents = streamReader.ReadToEnd().Replace(@"""", "").Replace("'", "").Replace("&","amp").Replace("<","lt").Replace(">","gt");
            
    

            contents = contents.TrimEnd('\r', '\n');
            streamReader.Close();
            streamReader.Dispose();

            var rowSeperator = new[] { "\r\n" };
            var rows = contents.Split(rowSeperator, StringSplitOptions.None);
            var colSeperator = new[] { "|" };

            var sb = new StringBuilder("<root>");

            foreach(var row in rows)
            {
                var cols = row.Split(colSeperator, StringSplitOptions.None);
                sb.Append("<row");
                var f = 0;
                foreach (var col in cols)
                {
                    f++;
                    sb.Append(" f" + f.ToString() + "=\"" + col.Trim() + "\"");
                }                
                sb.Append(" />");
            }
            sb.Append("</root>");
            return sb.ToString();
        }

        public DbResult Update(string user, string sdnFilePath, string altFilePath, string addFilePath)
        {
            var sql = "EXEC proc_ofacManagement @flag = 'sdn'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sdnXML = " + FilterString(GetXml(sdnFilePath));
            sql += ", @altXML = " + FilterString(GetXml(altFilePath));
            sql += ", @addXML = " + FilterString(GetXml(addFilePath));


            return ParseDbResultV2(sql);
        }
        public DbResult UpdateOther(string user)
        {
            var sql = "EXEC proc_ofacOtherDataManagement @flag = 'other'";
            sql += ", @user = " + FilterString(user);
            return ParseDbResultV2(sql);
        }

        public DbResult UpdateAQList(string user, string xmlFile,string xmlFileName)
        {
            var sql = "EXEC Proc_unscrManagement @flag = 'unscr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xmlFile = " + FilterString(xmlFile);
            sql += ", @xmlFileName = " + FilterString(xmlFileName);

            return ParseDbResultV2(sql);
        }
        public DataTable LoadLog(string user)
        {
            var sql = "EXEC proc_ofacManagement @flag = 's'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable LoadSourceWiseData(string user)
        {
            var sql = "EXEC proc_ofacManagement @flag = 'swLog'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataset(sql).Tables[0];
        }
            
        public DataTable SearchSDN(string user, string name)
        {
            var sql = "EXEC proc_ofacTracker @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @name = N" + FilterString(name);

            return ExecuteDataset(sql).Tables[0];
        }
        public DataRow SelectOFACSetting(string user)
        {
            string sql = "EXEC proc_ofacSetting";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }


        public DbResult UpdateOFACSetting(string user, string OFACTracker, string OFACTran)
        {
            string sql = "EXEC proc_ofacSetting";
            sql += " @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ofacTracker = " + FilterString(OFACTracker);
            sql += ", @ofacTran = " + FilterString(OFACTran);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
