using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace ProyectoProgramacionAvanzada.Models
{
    public class InicioSesionModel
    {

        [Required(ErrorMessage = "El correo electronico es obligatorio.")]
        [EmailAddress(ErrorMessage = "Ingrese un correo electronico valido.")]
        [StringLength(150)]
        [Display(Name = "Correo electronico")]
        public string Email { get; set; }

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [DataType(DataType.Password)]
        [Display(Name = "Contrasenna")]
        public string Contrasenna { get; set; }

    }
}