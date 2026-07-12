using System.ComponentModel.DataAnnotations;

namespace ProyectoProgramacionAvanzada.Models
{
    public class DireccionModel
    {
        public int IdDireccion { get; set; }

        public int IdUsuario { get; set; }

        public int IdProvincia { get; set; }

        public string NombreProvincia { get; set; }

        public int IdCanton { get; set; }

        public string NombreCanton { get; set; }

        [Required(ErrorMessage = "El distrito es obligatorio.")]
        [Display(Name = "Distrito")]
        public int IdDistrito { get; set; }

        public string NombreDistrito { get; set; }

        [Required(ErrorMessage = "La dirección exacta es obligatoria.")]
        [StringLength(300)]
        [Display(Name = "Dirección exacta")]
        public string DireccionExacta { get; set; }

        [StringLength(300)]
        [Display(Name = "Referencia")]
        public string Referencia { get; set; }

        [Required(ErrorMessage = "El teléfono de contacto es obligatorio.")]
        [StringLength(20)]
        [Display(Name = "Teléfono de contacto")]
        public string TelefonoContacto { get; set; }

        [Required(ErrorMessage = "El destinatario es obligatorio.")]
        [StringLength(150)]
        [Display(Name = "Nombre del destinatario")]
        public string NombreDestinatario { get; set; }

        [Display(Name = "Dirección principal")]
        public bool EsPrincipal { get; set; }

        public int IdEstado { get; set; }

        public string NombreEstado { get; set; }
    }
}