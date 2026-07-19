using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
    public class FavoritoService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public FavoritoService()
        {
            Contexto = new BD_LENEntities();
        }

        public OperacionAdminResult AgregarFavorito(int IdUsuario, int IdProducto)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_AgregarFavorito @IdUsuario, @IdProducto",
                    new SqlParameter("@IdUsuario", IdUsuario),
                    new SqlParameter("@IdProducto", IdProducto)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult EliminarFavorito(int IdUsuario, int IdProducto)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_EliminarFavorito @IdUsuario, @IdProducto",
                    new SqlParameter("@IdUsuario", IdUsuario),
                    new SqlParameter("@IdProducto", IdProducto)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public List<FavoritoViewModel> ConsultarFavoritos(int IdUsuario)
        {
            return Contexto.Database
                .SqlQuery<FavoritoViewModel>(
                    "EXEC dbo.SP_ConsultarFavoritos @IdUsuario",
                    new SqlParameter("@IdUsuario", IdUsuario)
                )
                .ToList();
        }

        private static OperacionAdminResult ResultadoNulo()
        {
            return new OperacionAdminResult
            {
                Exitoso = false,
                Mensaje = "No fue posible completar la operación. Intente de nuevo."
            };
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
