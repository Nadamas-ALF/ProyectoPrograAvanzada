using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
    /// <summary>
    /// Servicio del módulo administrativo para la gestión
    /// de categorías del catálogo (apoyo a RF-11).
    /// </summary>
    public class CategoriaAdminService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public CategoriaAdminService()
        {
            Contexto = new BD_LENEntities();
        }

        public List<CategoriaAdminViewModel> ConsultarCategorias()
        {
            return Contexto.Database
                .SqlQuery<CategoriaAdminViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarCategorias"
                )
                .ToList();
        }

        public OperacionAdminResult InsertarCategoria(CategoriaFormViewModel Categoria)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_InsertarCategoria @NombreCategoria, @Descripcion",
                    new SqlParameter("@NombreCategoria", Categoria.NombreCategoria),
                    new SqlParameter("@Descripcion", (object)Categoria.Descripcion ?? DBNull.Value)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult ActualizarCategoria(CategoriaFormViewModel Categoria)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_ActualizarCategoria @IdCategoria, @NombreCategoria, @Descripcion",
                    new SqlParameter("@IdCategoria", Categoria.IdCategoria),
                    new SqlParameter("@NombreCategoria", Categoria.NombreCategoria),
                    new SqlParameter("@Descripcion", (object)Categoria.Descripcion ?? DBNull.Value)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult CambiarEstadoCategoria(int IdCategoria)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_CambiarEstadoCategoria @IdCategoria",
                    new SqlParameter("@IdCategoria", IdCategoria)
                )
                .FirstOrDefault() ?? ResultadoNulo();
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
