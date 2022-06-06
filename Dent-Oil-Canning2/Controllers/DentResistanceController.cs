using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Dent_Oil_Canning2.Models;

namespace Dent_Oil_Canning2.Controllers
{
    public class DentResistanceController : ApiController
    {
        [HttpPost]
        public ReturnObject<Calculation> CalculateModelOne(Calculation model)
        {
            bool bCalculated;
            DRFormula.Formula objDRCalc = new DRFormula.Formula();

            bCalculated = objDRCalc.Calculate(model.GradeKey, model.R1, model.R2, model.Thickness, model.MajorStrain, model.MinorStrain);

            if (bCalculated)
            {
                model.FootPounds = Math.Round(objDRCalc.LBF, 2);
                model.RunningTotal = Math.Round(objDRCalc.Newtons, 2);

                return new ReturnObject<Calculation>() { success = true, data = model, validated = true };
            }
            else
            {
                return new ReturnObject<Calculation>() { success = false, data = model, validated = true };
            }
        }

        [HttpPost]
        public ReturnObject<Calculation> CalculateModelTwo(Calculation model)
        {
            bool bCalculated;
            double dblResultIntercept, dblResultSlope;
            DRFormula.Formula objDRCalc = new DRFormula.Formula();

            bCalculated = objDRCalc.CalculateM2(model.GradeKey, model.R1, model.R2, model.Thickness, model.MajorStrain, model.MinorStrain, "INTERCEPT");

            if (bCalculated)
            {
                dblResultIntercept = objDRCalc.Result;
                bCalculated = objDRCalc.CalculateM2(model.GradeKey, model.R1, model.R2, model.Thickness, model.MajorStrain, model.MinorStrain, "SLOPE");

                if (bCalculated)
                {
                    dblResultSlope = objDRCalc.Result;
                    model.Result = Math.Round((model.PoundsForce - dblResultIntercept) / dblResultSlope, 3);

                    return new ReturnObject<Calculation>() { success = true, data = model, validated = true };
                }
                else
                {
                    return new ReturnObject<Calculation>() { success = false, data = model, validated = true };
                }
            }
            else
            {
                return new ReturnObject<Calculation>() { success = false, data = model, validated = true };
            }
        }
    }
}
