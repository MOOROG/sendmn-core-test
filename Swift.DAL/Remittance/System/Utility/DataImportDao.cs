using System.Collections.Generic;
using System.Data;
using Swift.DAL.BL.System.Utility.Helper;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Utility
{
    public class DataImportDao: SwiftDao 
    {
        XmlGenerator xmlUtil = new XmlGenerator();
        public DataSet ImportPaidTransaction(string xml, string user)
        {           
            var sql = @"EXEC proc_ImportFile @flag='pt', @user=" + FilterString(user) +
                      @", @xml='" + xml + "'";

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet LoadIncorrectDataFromFile(string xml, string user)
        {
            var sql = @"EXEC proc_ImportFile @flag='s', @user=" + FilterString(user) +
                      @", @xml='" + xml + "'";

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult ImportPaidTransactionAdmin(string xml, string xmlErrorDataId, string user, string pAgent, string fileFormatType)
        {
            var sql = "EXEC proc_importFileApiAdmin @flag = 'ptApi'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xml = " + FilterString(xml);
            sql += ", @xmlErrorDataId = " + FilterString(xmlErrorDataId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fileFormatType = " + FilterString(fileFormatType);

            return ParseDbResult(sql);
        }

        public DataRow ImportPaidTransactionApi(string xml, string xmlErrorDataId, string user, string pBranch, string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string mapCode, string parentMapCode, string pCountryId)
        {
            var sql = "EXEC proc_importFileApi @flag = 'ptApi'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xml = " + FilterString(xml);
            sql += ", @xmlErrorDataId = " + FilterString(xmlErrorDataId);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @parentMapCode = " + FilterString(parentMapCode);
            sql += ", @pCountryId = " + FilterString(pCountryId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet ImportPaidTransactionLocal(string xml, string xmlErrorDataId, string user, string pBranch, string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string uploadLogId)
        {
            var sql = "EXEC proc_importFileApi @flag = 'pt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xml = " + FilterString(xml);
            sql += ", @xmlErrorDataId = " + FilterString(xmlErrorDataId);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @uploadLogId = " + FilterString(uploadLogId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet LoadIncorrectDataFromFileAdmin(string xml, string user, string pAgent, string fileFormatType)
        {
            var sql = "EXEC proc_ImportFileAPIAdmin @flag='s'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xml = '" + xml + "'";
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fileFormatType = " + FilterString(fileFormatType);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet LoadIncorrectDataFromFileApi(string xml, string user)
        {
            var sql = @"EXEC proc_ImportFileAPI @flag='s', @user=" + FilterString(user) +
                      @", @xml='" + xml + "'";

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult GetXmlFromFileCustom(string filePath, bool useFirstLineAsHeader, string fileFormatType)
        {
            var dbResult = new DbResult();
            xmlUtil.FilePath = filePath;
            xmlUtil.FirstLineIsHeader = useFirstLineAsHeader;
            xmlUtil.CheckFirstLineHeader = useFirstLineAsHeader;
            xmlUtil.ColSeperator = ",";
            xmlUtil.RowSeperator = "\r\n";
            xmlUtil.IgnoreInvalidRow = false;

            if(fileFormatType.ToLower() == "tranid")
                xmlUtil.FieldList = TextToXmlColumn("tranid,amount");
            else
                xmlUtil.FieldList = TextToXmlColumn("controlno,amount");

            var xml = xmlUtil.GenerateXML();
            if (xmlUtil.Dr.ErrorCode != "0")
                return xmlUtil.Dr;

            xmlUtil = null;
            dbResult.SetError("0", xml, "");
            return dbResult;
        }

        public DbResult GetXmlFromFile(string filePath)
        {
            var dbResult = new DbResult();
            xmlUtil.FilePath = filePath;
            xmlUtil.FirstLineIsHeader = true;
            xmlUtil.CheckFirstLineHeader = true;
            xmlUtil.ColSeperator = ",";
            xmlUtil.RowSeperator = "\r\n";
            xmlUtil.IgnoreInvalidRow = false;
            xmlUtil.FieldList = TextToXmlColumn("controlno,amount");

            var xml = xmlUtil.GenerateXML();
            if (xmlUtil.Dr.ErrorCode != "0")
                return xmlUtil.Dr;

            xmlUtil = null;
            dbResult.SetError("0", xml, "");
            return dbResult;
        }

        private List<FieldName> TextToXmlColumn(string fieldList)
        {
            var list = new List<FieldName>();
            var i = 0;
            foreach (var c in fieldList.Split(','))
            {
                list.Add(new FieldName(i++, c.Trim()));
            }
            return list;
        }

        public DbResult UploadCouponNo(string filePath,string schemeId, string user)
        {
            var dbResult = new DbResult();
            xmlUtil.FilePath = filePath;
            xmlUtil.FirstLineIsHeader = true;
            xmlUtil.CheckFirstLineHeader = true;
            xmlUtil.ColSeperator = ",";
            xmlUtil.RowSeperator = "\r\n";
            xmlUtil.IgnoreInvalidRow = false;
            xmlUtil.FieldList = TextToXmlColumn("f1,f2");

            var xml = xmlUtil.GenerateXML();
            if (xmlUtil.Dr.ErrorCode != "0")
                return xmlUtil.Dr;

            var sql = @"EXEC proc_uploadCoupon @flag='upload', @user=" + FilterString(user) +
                      ", @xml ='" + xml + "',@schemeId="+FilterString(schemeId);

            return ParseDbResult(sql);
        }

    }
}
