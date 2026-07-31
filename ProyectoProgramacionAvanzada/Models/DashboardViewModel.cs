using System;
using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class DashboardViewModel
    {
        public decimal TotalVentas { get; set; }

        public int TotalPedidos { get; set; }

        public int TotalClientesActivos { get; set; }

        public int TotalProductosAgotados { get; set; }

        public List<VentaMensualModel> VentasMensuales
        {
            get;
            set;
        }

        public List<ActividadRecienteModel> ActividadesRecientes
        {
            get;
            set;
        }

        public DashboardViewModel()
        {
            VentasMensuales =
                new List<VentaMensualModel>();

            ActividadesRecientes =
                new List<ActividadRecienteModel>();
        }
    }

    public class VentaMensualModel
    {
        public int NumeroMes { get; set; }

        public string NombreMes { get; set; }

        public decimal TotalVentas { get; set; }

        public decimal Porcentaje { get; set; }
    }

    public class ActividadRecienteModel
    {
        public int IdPedido { get; set; }

        public string Titulo { get; set; }

        public string Descripcion { get; set; }

        public DateTime Fecha { get; set; }

        public string Tipo { get; set; }
    }
}