using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel.City
{
	public 	class CityResponse
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public string StateId { get; set; }
		public string StateName { get; set; }
		public string CountryIsoCode { get; set; }
	}
}
