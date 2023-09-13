using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.GridAutoDemo
{
    public class EmployeeModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string Email { get; set; }
        public string MobileNo { get; set; }
        public string DepartName { get; set; }
        public DateTime DOB { get; set; }
        public DateTime CompanyJoinDate { get; set; }
        public int WorkDayOnWeek { get; set; }
        public string Description { get; set; }
        public string Flag { get; set; }
    }
}