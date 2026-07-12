using ProyectoProgramacionAvanzada.EF;
using System;

namespace ProyectoProgramacionAvanzada.Services
{
    public class ErrorService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public ErrorService()
        {
            Contexto = new BD_LENEntities();
        }

        public void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion,
            string UsuarioSistema,
            string Url)
        {
            string DetalleError = null;

            if (Excepcion.InnerException != null)
            {
                DetalleError = Excepcion.InnerException.Message;
            }

            Contexto.SP_RegistrarError(
                Origen,
                Metodo,
                Excepcion.Message,
                DetalleError,
                null,
                UsuarioSistema,
                Url,
                Excepcion.StackTrace
            );
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}