using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Dent_Oil_Canning2.ViewModels
{
    public class DrCalcViewModel
    {
        public int grade_key { get; set; }

        public int R1 { get; set; }

        public string R2 { get; set; }

        public int thickness { get; set; }

        public int MajStrain { get; set; }

        public int MinStrain { get; set; }
    }
}