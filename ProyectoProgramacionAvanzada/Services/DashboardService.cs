using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
    public class DashboardService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public DashboardService()
        {
            Contexto = new BD_LENEntities();
        }

        public DashboardViewModel ConsultarDashboard()
        {
            DashboardViewModel Modelo =
                new DashboardViewModel();

            ConsultarResumen(Modelo);

            ConsultarVentasMensuales(
                Modelo,
                DateTime.Now.Year
            );

            ConsultarActividadReciente(
                Modelo,
                5
            );

            return Modelo;
        }

        private void ConsultarResumen(
            DashboardViewModel Modelo)
        {
            SP_Dashboard_ConsultarResumen_Result Resultado =
                Contexto
                    .SP_Dashboard_ConsultarResumen()
                    .FirstOrDefault();

            if (Resultado == null)
            {
                return;
            }

            Modelo.TotalVentas =
                Resultado.TotalVentas ?? 0;

            Modelo.TotalPedidos =
                Resultado.TotalPedidos ?? 0;

            Modelo.TotalClientesActivos =
                Resultado.TotalClientesActivos ?? 0;

            Modelo.TotalProductosAgotados =
                Resultado.TotalProductosAgotados ?? 0;
        }

        private void ConsultarVentasMensuales(
            DashboardViewModel Modelo,
            int Anno)
        {
            List<SP_Dashboard_ConsultarVentasMensuales_Result>
                Resultados =
                    Contexto
                        .SP_Dashboard_ConsultarVentasMensuales(
                            Anno
                        )
                        .ToList();

            decimal VentaMayor = 0;

            foreach (
                SP_Dashboard_ConsultarVentasMensuales_Result Resultado
                in Resultados)
            {
                decimal TotalVentas =
                    Resultado.TotalVentas ?? 0;

                if (TotalVentas > VentaMayor)
                {
                    VentaMayor =
                        TotalVentas;
                }
            }

            foreach (
                SP_Dashboard_ConsultarVentasMensuales_Result Resultado
                in Resultados)
            {
                decimal TotalVentas =
                    Resultado.TotalVentas ?? 0;

                decimal Porcentaje = 0;

                if (VentaMayor > 0)
                {
                    Porcentaje =
                        TotalVentas
                        / VentaMayor
                        * 100;
                }

                VentaMensualModel Venta =
                    new VentaMensualModel
                    {
                        NumeroMes =
                            Resultado.NumeroMes,

                        NombreMes =
                            Resultado.NombreMes
                            ?? string.Empty,

                        TotalVentas =
                            TotalVentas,

                        Porcentaje =
                            Math.Round(
                                Porcentaje,
                                2
                            )
                    };

                Modelo.VentasMensuales.Add(
                    Venta
                );
            }
        }

        private void ConsultarActividadReciente(
            DashboardViewModel Modelo,
            int Cantidad)
        {
            List<SP_Dashboard_ConsultarActividadReciente_Result>
                Resultados =
                    Contexto
                        .SP_Dashboard_ConsultarActividadReciente(
                            Cantidad
                        )
                        .ToList();

            foreach (
                SP_Dashboard_ConsultarActividadReciente_Result Resultado
                in Resultados)
            {
                ActividadRecienteModel Actividad =
                    new ActividadRecienteModel
                    {
                        IdPedido =
                            Resultado.IdPedido,

                        Titulo =
                            Resultado.Titulo
                            ?? "Actividad registrada",

                        Descripcion =
                            Resultado.Descripcion
                            ?? string.Empty,

                        Fecha =
                            Resultado.Fecha,

                        Tipo =
                            Resultado.Tipo
                            ?? string.Empty
                    };

                Modelo.ActividadesRecientes.Add(
                    Actividad
                );
            }
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}