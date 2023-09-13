using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;

namespace Swift.DAL.Library
{
    public static class Mapper
    {
        public static IList<T> DataTableToClass<T>(DataTable Table) where T : class, new()
        {
            var dataList = new List<T>(Table.Rows.Count);
            Type classType = typeof(T);
            IList<PropertyInfo> propertyList = classType.GetProperties();
            if (propertyList.Count == 0)
                return new List<T>();
            List<string> columnNames = Table.Columns.Cast<DataColumn>().Select(column => column.ColumnName).ToList();
            try
            {
                foreach (DataRow dataRow in Table.AsEnumerable().ToList())
                {
                    var classObject = new T();
                    foreach (PropertyInfo property in propertyList)
                    {

                        if (property != null && property.CanWrite)
                        {
                            if (columnNames.Contains(property.Name))
                            {
                                if (dataRow[property.Name] != System.DBNull.Value)
                                {
                                    object propertyValue = System.Convert.ChangeType(
                                            dataRow[property.Name],
                                            property.PropertyType
                                        );
                                    property.SetValue(classObject, propertyValue, null);
                                }

                            }
                        }
                    }
                    dataList.Add(classObject);
                }
                return dataList;
            }

            catch
            {
                return new List<T>();
            }
        }
    }
}
