using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
    public class DataExportDao:SwiftDao
    {
        public DataSet ExportFile(string user, string flFormatId, string dateFrom, string dateTo, string agentId, string ipdr
            , string asOnDate, string asOntime, string fromTime, string toTime)
        {
            var sql = "EXEC proc_GenerateFile @flag='export'";
            sql += ", @flFormatId=" + FilterString(flFormatId);
            sql += ", @agentId=" + FilterString(agentId);
            sql += ", @dateFrom=" + FilterString(dateFrom);
            sql += ", @dateTo=" + FilterString(dateTo);
            sql += ", @ipdr=" + FilterString(ipdr);
            sql += ", @user=" + FilterString(user);
            sql += ", @asOnDate=" + FilterString(asOnDate);
            sql += ", @asOntime=" + FilterString(asOntime);
            sql += ", @fromTime=" + FilterString(fromTime);
            sql += ", @toTime=" + FilterString(toTime);

            DataSet ds = ExecuteDataset(sql);
            return ds;

        }

        public DataSet ExportFileProc(string dataSource, string user, string flFormatId, string dateFrom, string dateTo, string agentId, string ipdr
           , string asOnDate, string asOntime, string fromTime, string toTime, string sCountry)
        {
            var sql = "EXEC "+ dataSource + " @flag='export'";
            sql += ", @flFormatId=" + FilterString(flFormatId);
            sql += ", @agentId=" + FilterString(agentId);
            sql += ", @dateFrom=" + FilterString(dateFrom);
            sql += ", @dateTo=" + FilterString(dateTo);
            sql += ", @ipdr=" + FilterString(ipdr);
            sql += ", @user=" + FilterString(user);
            sql += ", @asOnDate=" + FilterString(asOnDate);
            sql += ", @asOntime=" + FilterString(asOntime);
            sql += ", @fromTime=" + FilterString(fromTime);
            sql += ", @toTime=" + FilterString(toTime);
            sql += ", @sCountry=" + FilterString(sCountry);

            DataSet ds = ExecuteDataset(sql);
            return ds;

        }
        public DataRow CheckFileType(string flFormatId)
        {
            var sql = "EXEC proc_fileFormat @flag='sourceType'";
            sql += ", @flFormatId=" + FilterString(flFormatId);
            return ExecuteDataRow(sql);
            
        }

    }
}
