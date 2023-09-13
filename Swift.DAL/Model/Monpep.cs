using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.Model {
  public class Monpep {
    public class SearchEntityResponse {
      public string status { get; set; }
      public string message { get; set; }
      public List<Result> results { get; set; }
      public int total { get; set; }
      public string total_type { get; set; }
      public int page { get; set; }
      public int limit { get; set; }
      public int offset { get; set; }
      public int pages { get; set; }
      public string next { get; set; }
      public object previous { get; set; }
      public Facets facets { get; set; }
      public string query_text { get; set; }
    }
    public class Properties {
      //public List<string> mpdtag { get; set; }
      //public List<string> lastName { get; set; }
      //public List<string> firstName { get; set; }
      //public List<string> notes { get; set; }
      //public List<string> name { get; set; }
      //public List<string> birthDate { get; set; }
      //public List<string> rd { get; set; }
      //public List<string> program { get; set; }
      public List<string> sourceUrl { get; set; }
      public List<string> birthPlace { get; set; }
      public List<string> gender { get; set; }
      public List<string> name { get; set; }
      public List<string> position { get; set; }
      public List<string> birthDate { get; set; }
    }

    public class Links {
      public string self { get; set; }
      public string ui { get; set; }
    }

    public class Collection {
      public DateTime created_at { get; set; }
      public DateTime updated_at { get; set; }
      public string category { get; set; }
      public string frequency { get; set; }
      public string collection_id { get; set; }
      public string foreign_id { get; set; }
      public string label { get; set; }
      public string summary { get; set; }
      public bool casefile { get; set; }
      public bool secret { get; set; }
      public bool xref { get; set; }
      public bool restricted { get; set; }
      public int count { get; set; }
      public string id { get; set; }
      public bool writeable { get; set; }
      public Links links { get; set; }
      public bool shallow { get; set; }
    }

    public class Result {
      public string schema { get; set; }
      public DateTime updated_at { get; set; }
      public int user_id { get; set; }
      public DateTime created_at { get; set; }
      public Properties properties { get; set; }
      public double score { get; set; }
      public string id { get; set; }
      public bool writeable { get; set; }
      public Links links { get; set; }
      public Collection collection { get; set; }
      public bool shallow { get; set; }
    }

    public class Value {
      public string id { get; set; }
      public string label { get; set; }
      public int count { get; set; }
      public bool active { get; set; }
      public string category { get; set; }
    }

    public class CollectionId {
      public List<object> filters { get; set; }
      public List<Value> values { get; set; }
    }

    public class Facets {
      public CollectionId collection_id { get; set; }
    }

    public class MergedMdl {
      public string mpdtag { get; set; }
      public string lastName { get; set; }
      public string firstName { get; set; }
      public string name { get; set; }
      public string notes { get; set; }
      public string birthDate { get; set; }
      public string label { get; set; }
      public string summary { get; set; }
      public string restricted { get; set; }
    }

    public class SingleProperties {
      public string sourceUrl { get; set; }
      public string birthPlace { get; set; }
      public string gender { get; set; }
      public string name { get; set; }
      public string position { get; set; }
      public string birthDate { get; set; }
    }

    public class Apeplist {
      public int id { get; set; }
      public string name { get; set; }
      public string nameorg { get; set; }
      public string title { get; set; }
      public string designation { get; set; }
      public string dob { get; set; }
      public string pob { get; set; }
      public string gquality { get; set; }
      public string lquality { get; set; }
      public string nationality { get; set; }
      public string passportNo { get; set; }
      public string nationalId { get; set; }
      public string address { get; set; }
      public string listedOn { get; set; }
      public string others { get; set; }
    }
  }
}
