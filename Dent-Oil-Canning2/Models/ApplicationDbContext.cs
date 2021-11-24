using Dent_Oil_Canning2.Models.db_models;
using System;
using System.ComponentModel.DataAnnotations;
using System.Data.Entity;

namespace Dent_Oil_Canning2.Models
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext()
            : base("DefaultConnection")
        {
        }

        public virtual DbSet<dr_Formulas> dr_Formulas { get; set; }
        public virtual DbSet<dr_Grades> dr_Grades { get; set; }
    }
}