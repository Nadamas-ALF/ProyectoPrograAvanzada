using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProyectoProgramacionAvanzada.Services
{
    public class UsuarioService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public UsuarioService()
        {
            Contexto = new BD_LENEntities();
        }

        public SP_ConsultarUsuarioInicioSesion_Result ValidarCredenciales(
            InicioSesionModel Modelo)
        {
            string EmailNormalizado = Modelo.Email.Trim();

            var Usuario = Contexto
                .SP_ConsultarUsuarioInicioSesion(EmailNormalizado)
                .FirstOrDefault();

            if (Usuario == null)
            {
                return null;
            }

            if (!string.Equals(
                Usuario.NombreEstado,
                "Activo",
                StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            bool ContrasennaValida = BCrypt.Net.BCrypt.Verify(
                Modelo.Contrasenna,
                Usuario.Contrasenna
            );

            if (!ContrasennaValida)
            {
                return null;
            }

            return Usuario;
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}