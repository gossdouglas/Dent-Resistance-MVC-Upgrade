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

            dr_Grades drGrades = new dr_Grades();

            return View(drGrades);
            //return View(_context.dr_Grades.ToList());
        }

        // GET: dentResistanceModel/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            dr_Grades dr_Grades = _context.dr_Grades.Find(id);
            if (dr_Grades == null)
            {
                return HttpNotFound();
            }
            return View(dr_Grades);
        }

        // GET: dentResistanceModel/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: dentResistanceModel/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "grade_key,model,grade_name,publish,normal_anisotropy,constants,constants_1,date_created,created_by,date_updated,updated_by")] dr_Grades dr_Grades)
        {
            if (ModelState.IsValid)
            {
                _context.dr_Grades.Add(dr_Grades);
                _context.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(dr_Grades);
        }

        // GET: dentResistanceModel/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            dr_Grades dr_Grades = _context.dr_Grades.Find(id);
            if (dr_Grades == null)
            {
                return HttpNotFound();
            }
            return View(dr_Grades);
        }

        // POST: dentResistanceModel/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "grade_key,model,grade_name,publish,normal_anisotropy,constants,constants_1,date_created,created_by,date_updated,updated_by")] dr_Grades dr_Grades)
        {
            if (ModelState.IsValid)
            {
                _context.Entry(dr_Grades).State = EntityState.Modified;
                _context.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(dr_Grades);
        }

        // GET: dentResistanceModel/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            dr_Grades dr_Grades = _context.dr_Grades.Find(id);
            if (dr_Grades == null)
            {
                return HttpNotFound();
            }
            return View(dr_Grades);
        }

        // POST: dentResistanceModel/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            dr_Grades dr_Grades = _context.dr_Grades.Find(id);
            _context.dr_Grades.Remove(dr_Grades);
            _context.SaveChanges();
            return RedirectToAction("Index");
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
