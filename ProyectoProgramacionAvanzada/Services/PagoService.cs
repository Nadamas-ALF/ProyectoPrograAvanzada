using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
    public class PagoService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public PagoService()
        {
            Contexto = new BD_LENEntities();
        }

        public PagoViewModel ConsultarPagos()
        {
            PagoViewModel Modelo =
                new PagoViewModel();

            ConsultarResumen(Modelo);
            ConsultarDetalle(Modelo);

            return Modelo;
        }

        private void ConsultarResumen(
            PagoViewModel Modelo)
        {
            SP_Admin_ConsultarResumenPagos_Result Resultado =
                Contexto
                    .SP_Admin_ConsultarResumenPagos()
                    .FirstOrDefault();

            if (Resultado == null)
            {
                return;
            }

            Modelo.TotalPagos =
                Resultado.TotalPagos ?? 0;

            Modelo.TotalRecaudado =
                Resultado.TotalRecaudado ?? 0;

            Modelo.PagosHoy =
                Resultado.PagosHoy ?? 0;

            Modelo.RecaudadoHoy =
                Resultado.RecaudadoHoy ?? 0;
        }

        private void ConsultarDetalle(
            PagoViewModel Modelo)
        {
            List<SP_Admin_ConsultarPagos_Result>
                Resultados =
                    Contexto
                        .SP_Admin_ConsultarPagos()
                        .ToList();

            foreach (
                SP_Admin_ConsultarPagos_Result Resultado
                in Resultados)
            {
                Modelo.Pagos.Add(
                    new PagoDetalleModel
                    {
                        IdPago =
                            Resultado.IdPago,

                        IdPedido =
                            Resultado.IdPedido,

                        NombreCliente =
                            Resultado.NombreCliente
                            ?? string.Empty,

                        EmailCliente =
                            Resultado.EmailCliente
                            ?? string.Empty,

                        NombreMetodoPago =
                            Resultado.NombreMetodoPago
                            ?? string.Empty,

                        Monto =
                            Resultado.Monto,

                        FechaPago =
                            Resultado.FechaPago,

                        Comprobante =
                            Resultado.Comprobante
                            ?? string.Empty,

                        NombreEstado =
                            Resultado.NombreEstado
                            ?? string.Empty
                    }
                );
            }
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}