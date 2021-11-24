using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Dent_Oil_Canning2.Models;
using Dent_Oil_Canning2.Models.db_models;

namespace Dent_Oil_Canning2.Controllers
{
    public class dentResistanceModelController : Controller
    {
        private ApplicationDbContext _context = new ApplicationDbContext();

        // GET: dentResistanceModel
        public ActionResult Index()
        {
            List<SelectListItem> grades = new List<SelectListItem>();
            List<dr_Grades> gradesList = _context.dr_Grades.OrderBy(o => o.grade_name).ToList();

            foreach (dr_Grades grade in gradesList)
            {
                if (grade.model == 1)
                {
                    var tempText = grade.grade_name.ToString();

                    SelectListItem temp = new SelectListItem
                    {
                        Text = tempText,
                        Value = tempText
                    };
                    grades.Add(temp);
                }
            }

            ViewBag.gradesList = grades;

            //dr_Grades drGrades = new dr_Grades();

            return View();
            //return View(drGrades);
        }

        [HttpPost]
        public ActionResult Calculate()
        {
            

            return View();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _context.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
