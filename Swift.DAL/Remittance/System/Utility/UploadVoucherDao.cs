using System.Collections.Generic;
using Swift.DAL.BL.System.Utility.Helper;
using Swift.DAL.SwiftDAL;
using System.Data;


namespace Swift.DAL.BL.System.Utility
{
   public class UploadVoucherDao:SwiftDao
    {
        readonly XmlGenerator xmlUtil = new XmlGenerator();

        private static List<FieldName> TextToXmlColumn(string fieldList)
        {
            var list = new List<FieldName>();
            var i = 0;
            foreach (var c in fieldList.Split(','))
            {
                list.Add(new FieldName(i++, c.Trim()));
            }
            return list;
        }

        public DbResult UploadVoucher(string filePath, string user)
        {
            var dbResult = new DbResult();
            xmlUtil.FilePath = filePath;
            xmlUtil.FirstLineIsHeader = true;
            xmlUtil.CheckFirstLineHeader = true;
            xmlUtil.ColSeperator = ",";
            xmlUtil.RowSeperator = "\r\n";
            xmlUtil.IgnoreInvalidRow = false;
            xmlUtil.FieldList = TextToXmlColumn("agentCode,dot,amount,currencyType,xRate,mode,dollar_rate,branch_code,session_id,update_ts");

            var xml = xmlUtil.GenerateXML();
            if (xmlUtil.Dr.ErrorCode != "0")
                return xmlUtil.Dr;
            var sql = "EXEC proc_uploadVoucher @flag='upload'";
            sql += ", @user=" + FilterString(user);
            sql += ", @xml ='" + xml + "'";

            return ParseDbResult(sql);
        }
        
       public DataTable ShowData(string user)
       {
           var sql = "EXEC proc_uploadVoucher @flag='s'";
            sql += ", @user=" + FilterString(user);
           return ExecuteDataTable(sql);
       }
    }
}
