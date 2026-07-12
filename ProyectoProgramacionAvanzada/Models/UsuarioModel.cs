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
        [Display(Name = "Cédula")]
        public string Cedula { get; set; }

        [StringLength(20)]
        [Display(Name = "Teléfono")]
        public string Telefono { get; set; }

        [Required(ErrorMessage = "El correo electrónico es obligatorio.")]
        [StringLength(150)]
        [EmailAddress(ErrorMessage = "Ingrese un correo electrónico válido.")]
        [Display(Name = "Correo electrónico")]
        public string Email { get; set; }

        [StringLength(
            255,
            MinimumLength = 8,
            ErrorMessage = "La contraseña debe tener al menos 8 caracteres."
        )]
        [DataType(DataType.Password)]
        [Display(Name = "Nueva contraseña")]
        public string Contrasenna { get; set; }

        [DataType(DataType.Password)]
        [Compare(
            "Contrasenna",
            ErrorMessage = "Las contraseñas no coinciden."
        )]
        [Display(Name = "Confirmar contraseña")]
        public string ConfirmarContrasenna { get; set; }

        public int IdRol { get; set; }

        public string NombreRol { get; set; }

        public int IdEstado { get; set; }

        public string NombreEstado { get; set; }

        public DateTime FechaRegistro { get; set; }
    }
}