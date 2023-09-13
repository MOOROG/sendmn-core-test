using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using Swift.DAL.SwiftDAL;
namespace Swift.DAL.BL.System.Utility.Helper
{
    public class XmlGenerator
    {
        public string FilePath{get;set;}
        public List<FieldName> FieldList { get; set; }
        public bool FirstLineIsHeader { get; set; }
        public bool CheckFirstLineHeader { get; set; }
        public bool UseHearderAsColumn { get; set; }
        public string RowSeperator { get; set; }
        public string ColSeperator { get; set; }
        public bool IgnoreInvalidRow { get; set; }
        public  int TotalRecords { get; set; }
        public  int InvalidRecords { get; set; }
        public DbResult Dr { get; set; }
        public string InvalidCharList { get; set; }
        

        private DbResult CheckHeader(string fileName)
        {
            var res = new DbResult();
            res.SetError("0", "Success", "");
            var streamReader = new StreamReader(fileName);
            if (streamReader.EndOfStream)
            {
                res.SetError("1", "Invalid file. Please check the data in the file", "");
                return res;
            }
            var firstLine = streamReader.ReadLine();
            if(firstLine.Length < 2)
            {
                res.SetError("1", "Invalid data found. Please check the first line", "");
                return res;
            }
            if(IsNumeric(firstLine.Substring(0,2)))
            {
                res.SetError("1", "Header should be included. Please include header in the file.", "");
                return res;
            }
            return res;
        }

        public static Boolean IsNumeric(string stringToTest)
        {
            int result;
            return int.TryParse(stringToTest, out result);
        }

        public string GenerateXML()
        {
            var dr = new DbResult();
            var errorRecordNumber = "";
            if (!UseHearderAsColumn && FieldList == null || FieldList.Count==0)
            {
                if (FirstLineIsHeader)
                {
                    UseHearderAsColumn = true;
                }
            }
            
            var sb = new StringBuilder();

            var contents = "";
            if (UseHearderAsColumn && FirstLineIsHeader)
            {
                contents = ReadFileContent(FilePath, false);
            }
            else
            {
                if (CheckFirstLineHeader)
                {
                    var res = CheckHeader(FilePath);
                    if (res.ErrorCode != "0")
                    {
                        Dr = res;
                        return "";
                    }
                }
                contents = ReadFileContent(FilePath, true);
            }
            var icl = InvalidCharList.Split(',');

            foreach (var itm in icl) {
                contents = contents.Replace(itm, "");
            }
     

            var rowSeperator = new[] { RowSeperator };
            var rows = contents.Split(rowSeperator, StringSplitOptions.None);
            var colSeperator = new[] { ColSeperator };
            int start = UseHearderAsColumn ? 1 : 0;
            if (rows.Length > 0 && (UseHearderAsColumn || FieldList == null || FieldList.Count == 0))
            {
                var cols = rows[0].Split(colSeperator, StringSplitOptions.None);
                if (UseHearderAsColumn)
                {                    
                    var list = new List<FieldName>();
                    var i = 0;
                    foreach (var col in cols)
                    {
                        list.Add(new FieldName(i++, col));
                    }

                    FieldList = list;
                }
                else
                {
                    var list = new List<FieldName>();
                    var i = 0;
                    foreach (var col in cols)
                    {
                        list.Add(new FieldName(i++, "field" + i.ToString()));
                    }

                    FieldList = list;
                }
            }

            var end = rows.Length;
            TotalRecords = end - start;
            var invalidRecords = 0;

            sb.Append("<root>");
            for (var i = start; i < end; i++)
            {                
                var cols = rows[i].Split(colSeperator, StringSplitOptions.None);
                var colLengh = cols.Length;

                if (FieldList != null && colLengh == FieldList.Count)
                {
                    sb.Append("<row");
                    foreach (var fld in FieldList)
                    {
                        sb.Append(" " + fld.Name.ToLower().Replace(" ", "_") + "=\"" + cols[fld.Index] + "\"");
                    }
                    //sb.Append(" has_error=\"N\"");
                    sb.Append("/>");
                }
                else
                {                   
                    if (IgnoreInvalidRow)
                    {
                        sb.Append("<row");
                        foreach (var fld in FieldList)
                        {
                            if (fld.Index <= colLengh)
                            {
                                sb.Append(" " + fld.Name.ToLower().Replace(" ", "_") + "=\"" + cols[fld.Index] + "\"");
                            }
                            else
                            {
                                sb.Append(" " + fld.Name.ToLower().Replace(" ", "_") + "=\"\"");
                            }
                        }
                        //sb.Append(" has_error=\"Y\"");
                        sb.Append("/>");
                        errorRecordNumber += ", " + i.ToString();
                        invalidRecords++;
                    }
                    else
                    {
                        dr.Msg = "Invalid data found. Please check data at row: " + i.ToString();
                        dr.ErrorCode = "1";
                        Dr = dr;
                        return "";
                    }
                }                   
            }

            sb.Append("</root>");
            if (errorRecordNumber != "")
            {
                dr.Msg = "Error records found at row(s) : " + errorRecordNumber;
                dr.ErrorCode = "101";
            }
            else
            {
                dr.Msg = "xml generated successfully.";
                dr.ErrorCode = "0";
            }

            InvalidRecords = invalidRecords;
            Dr = dr;           
            return sb.ToString();
        }


        protected string ReadFileContent(string fileName)
        {
            return ReadFileContent(fileName, false);
        }

        protected string ReadFileContent(string fileName, bool ignoreFirstLine)
        {
            var streamReader = new StreamReader(fileName);
            if (streamReader.EndOfStream)
                return "";
            if (ignoreFirstLine)
            {
                streamReader.ReadLine();
                if (streamReader.EndOfStream)
                    return "";
            }
            var contents = streamReader.ReadToEnd();
            contents = contents.TrimEnd('\r', '\n');
            streamReader.Close();
            streamReader.Dispose();
            return contents;
        }

        public List<FieldName> TextToXmlColumn(string fieldList)
        {
            var list = new List<FieldName>();
            var i = 0;
            foreach (var c in fieldList.Split(','))
            {
                list.Add(new FieldName(i++, c.Trim()));
            }
            return list;
        }
    }
    public class FieldName
    {
        public int Index { get; set; }
        public string Name { get; set; }

        public FieldName(int index, string name)
        {
            Index = index;
            Name = name;
        }
    }
}
