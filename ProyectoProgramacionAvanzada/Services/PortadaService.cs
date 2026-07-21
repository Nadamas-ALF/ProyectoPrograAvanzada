using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
 
    public class PortadaService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public PortadaService()
        {
            Contexto = new BD_LENEntities();
        }

        public List<ProductoDestacadoViewModel> ConsultarDestacados(int Top)
        {
            return Contexto.Database
                .SqlQuery<ProductoDestacadoViewModel>(
                    "EXEC dbo.SP_ConsultarProductosDestacados @Top",
                    new SqlParameter("@Top", Top)
                )
                .ToList();
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
