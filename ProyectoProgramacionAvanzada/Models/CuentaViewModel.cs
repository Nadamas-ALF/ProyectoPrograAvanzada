using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class CuentaViewModel
    {
        public CuentaViewModel()
        {
            Usuario = new UsuarioModel();
            Direcciones = new List<DireccionModel>();
        }

        public UsuarioModel Usuario { get; set; }

        public List<DireccionModel> Direcciones { get; set; }
    }
}
