using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Dent_Oil_Canning2.ViewModels
{
    public class DrGradesViewModel
    {
        public int grade_key { get; set; }

        public int model { get; set; }

        public string grade_name { get; set; }

        public int publish { get; set; }

        public double normal_anisotropy { get; set; }

        public double constants { get; set; }

        public string constants_1 { get; set; }

        public DateTime date_created { get; set; }

        public string created_by { get; set; }

        public DateTime date_updated { get; set; }

        public string updated_by { get; set; }
    }
}