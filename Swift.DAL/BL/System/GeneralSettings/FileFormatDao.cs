using System.Data;
using Swift.DAL.SwiftDAL;
namespace Swift.DAL.BL.System.GeneralSettings
{
    public class FileFormatDao : SwiftDao
    {
        public DbResult Update(string user, string flFormatId, string formatCode, string formatType, string flDescription, string fldSeperator, string fixDataLength, string dataSourceCode, string includeColHeader, string recordSeperator, string isActive, string filterClause, string includeSerialNo, string headerFormatCode, string sourceType)
        {
            var sql = "EXEC proc_fileFormat";
            sql += " @flag = " + (flFormatId == "0" || flFormatId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @flFormatId = " + FilterString(flFormatId);
            sql += ", @formatCode = " + FilterString(formatCode);
            sql += ", @formatType = " + FilterString(formatType);
            sql += ", @flDescription = " + FilterString(flDescription);
            sql += ", @fldSeperator = '" + fldSeperator + "'";
            sql += ", @fixDataLength = " + FilterString(fixDataLength);
            sql += ", @dataSourceCode = " + FilterString(dataSourceCode);
            sql += ", @includeColHeader = " + FilterString(includeColHeader);
            sql += ", @recordSeperator = '" + recordSeperator + "'";
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @filterClause = " + FilterString(SingleQuoteToDoubleQuote(filterClause));
            sql += ", @includeSerialNo = " + FilterString(includeSerialNo);
            sql += ", @headerFormatCode = " + FilterString(headerFormatCode);
            sql += ", @sourceType = " + FilterString(sourceType); 

            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string flFormatId)
        {
            var sql = "EXEC proc_fileFormat";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @flFormatId = " + FilterString(flFormatId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string flFormatId)
        {
            var sql = "EXEC proc_fileFormat";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @flFormatId = " + FilterString(flFormatId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DUpdate(string user, string ffdId, string flFormatId, string name, string replaceByValue, string alias, string fldDescription, string size, string position, string isActive, string dataType, string dataFormat)
        {
            var sql = "EXEC proc_fileFormatDetails";
            sql += " @flag = " + (ffdId == "0" || ffdId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @ffdId = " + FilterString(ffdId);

            sql += ", @flFormatId = " + FilterString(flFormatId);
            sql += ", @name = " + FilterString(name);
            sql += ", @replaceByValue = " + FilterString(replaceByValue);
            sql += ", @alias = " + FilterString(alias);
            sql += ", @fldDescription = " + FilterString(fldDescription);
            sql += ", @size = " + FilterString(size);
            sql += ", @position = " + FilterString(position);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @dataType = " + FilterString(dataType);
            sql += ", @dataFormat = " + FilterString(dataFormat);            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DDelete(string user, string ffdId)
        {
            var sql = "EXEC proc_fileFormatDetails";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ffdId = " + FilterString(ffdId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow DSelectById(string user, string ffdId)
        {
            var sql = "EXEC proc_fileFormatDetails";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ffdId = " + FilterString(ffdId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];

        }

        public DbResult AFFSave(string user, string agentId, string fileFormatIds)
        {
            var sql = "EXEC proc_fileFormat";
            sql += " @flag = 'ff-insert'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @fileFormatIds = " + FilterString( fileFormatIds);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult AFFDelete(string user, string agentFfId)
        {
            var sql = "EXEC proc_fileFormat";
            sql += "  @flag = 'ff-delete'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentFfId = " + FilterString(agentFfId);
            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult CheckFilterClause(string dataSourceCode, string filterClause)
        {
            var sql = "SELECT 'x' FROM vw_Export_" + dataSourceCode  + " WHERE " + filterClause;
            return TryParseSQL(sql);
        }
        
    }

}
