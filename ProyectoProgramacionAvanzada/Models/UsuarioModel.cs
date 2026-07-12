using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace ProyectoProgramacionAvanzada.Models
{
    public class UsuarioModel
    {

        public int IdUsuario { get; set; }

        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(100)]
        [Display(Name = "Nombre")]
        public string Nombre { get; set; }

        [Required(ErrorMessage = "El apellido es obligatorio.")]
        [StringLength(100)]
        [Display(Name = "Apellido")]
        public string Apellido { get; set; }

        [StringLength(20)]
        [Display(Name = "Cedula")]
        public string Cedula { get; set; }

        [StringLength(20)]
        [Display(Name = "Telefono")]
        public string Telefono { get; set; }

        [Required(ErrorMessage = "El correo electronico es obligatorio.")]
        [StringLength(150)]
        [EmailAddress(ErrorMessage = "Ingrese un correo electronico valido.")]
        [Display(Name = "Correo electronico")]
        public string Email { get; set; }

        [Required(ErrorMessage = "La contrasenna es obligatoria.")]
        [StringLength(255)]
        [DataType(DataType.Password)]
        [Display(Name = "Contrasenna")]
        public string Contrasenna { get; set; }

        public int IdRol { get; set; }

        public int IdEstado { get; set; }

        public DateTime FechaRegistro { get; set; }
    }
}